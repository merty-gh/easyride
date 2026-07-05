from fastapi import FastAPI, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import text
from database import engine, Base, get_db
import models
import requests # <--- Новый импорт

# Создаем таблицы в БД
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="EasyRide MVP API")

class TelemetryPayload(BaseModel):
    user_id: str
    latitude: float
    longitude: float
    speed_kmh: float
    bump_force: float

# Функция 1: Привязка координаты к ближайшей дороге (Snap-to-Road)
def get_snapped_coordinates(lat, lon):
    try:
        # Используем бесплатный публичный API OSRM для поиска ближайшей дороги
        url = f"http://router.project-osrm.org/nearest/v1/driving/{lon},{lat}"
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            data = response.json()
            if data.get("waypoints"):
                # OSRM возвращает массив [долгота, широта]
                snapped_lon = data["waypoints"][0]["location"][0]
                snapped_lat = data["waypoints"][0]["location"][1]
                return snapped_lat, snapped_lon
    except Exception as e:
        print(f"Ошибка OSRM: {e}")
    
    # Если OSRM недоступен, возвращаем исходные грязные координаты
    return lat, lon

# Функция 2: Нормализация силы ямы
def calculate_normalized_force(bump_force, speed_kmh):
    # Яма на 100 км/ч даст больший скачок, чем на 20 км/ч. 
    # Снижаем вес удара пропорционально скорости.
    speed = max(speed_kmh, 20.0)
    coefficient = speed / 20.0
    normalized = bump_force / coefficient
    return round(normalized, 2)

@app.post("/api/v1/telemetry")
async def receive_telemetry(data: TelemetryPayload, db: Session = Depends(get_db)):
    
    # 1. Привязываем координаты к асфальту
    snapped_lat, snapped_lon = get_snapped_coordinates(data.latitude, data.longitude)
    
    # 2. Нормализуем силу удара
    real_bump_force = calculate_normalized_force(data.bump_force, data.speed_kmh)

    # 3. Сохраняем в PostGIS
    point = f"POINT({snapped_lon} {snapped_lat})"
    
    new_record = models.TelemetryData(
        user_id=data.user_id,
        location=point,
        speed_kmh=data.speed_kmh,
        bump_force=real_bump_force # Сохраняем уже вычищенную силу удара
    )
    db.add(new_record)
    db.commit()
    
    return {"status": "success", "message": "Яма привязана к дороге и сохранена"}

@app.get("/api/v1/telemetry")
async def get_telemetry(db: Session = Depends(get_db)):
    # Используем алгоритм кластеризации DBSCAN прямо в базе данных PostGIS.
    # eps := 0.0002 — это примерно 20 метров в градусах (радиус объединения ям).
    query = """
    WITH clusters AS (
        SELECT 
            id, user_id, bump_force, location,
            ST_ClusterDBSCAN(location, eps := 0.0002, minpoints := 1) OVER() as cluster_id
        FROM telemetry
    )
    SELECT 
        cluster_id,
        COUNT(DISTINCT user_id) as unique_users,
        COUNT(id) as total_hits,
        MAX(bump_force) as max_force,
        ST_X(ST_Centroid(ST_Collect(location))) as lon,
        ST_Y(ST_Centroid(ST_Collect(location))) as lat
    FROM clusters
    GROUP BY cluster_id;
    """
    
    result = db.execute(text(query)).fetchall()

    bumps = []
    for row in result:
        # Подтверждаем яму, если 2 разных юзера ИЛИ 3 проезда одного
        is_confirmed = (row.unique_users >= 2) or (row.total_hits >= 3)
        
        bumps.append({
            "cluster_id": row.cluster_id,
            "lat": row.lat,
            "lon": row.lon,
            "max_force": row.max_force,  # Берем максимальную силу удара в этом кластере
            "unique_users": row.unique_users,
            "total_hits": row.total_hits,
            "is_confirmed": is_confirmed
        })
        
    return bumps