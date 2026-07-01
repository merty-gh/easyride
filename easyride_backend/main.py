from fastapi import FastAPI, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import text
from database import engine, Base, get_db
import models

# Создаем таблицы в БД
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="EasyRide MVP API")

# Схема (формат) данных, которые пришлет телефон
class TelemetryPayload(BaseModel):
    user_id: str
    latitude: float
    longitude: float
    speed_kmh: float
    bump_force: float

@app.post("/api/v1/telemetry")
async def receive_telemetry(data: TelemetryPayload, db: Session = Depends(get_db)):
    # Сохраняем скачок (яму) в базу данных
    # Формат POINT в PostGIS: 'POINT(ДОЛГОТА ШИРОТА)'
    point = f"POINT({data.longitude} {data.latitude})"
    
    new_record = models.TelemetryData(
        user_id=data.user_id,
        location=point,
        speed_kmh=data.speed_kmh,
        bump_force=data.bump_force
    )
    db.add(new_record)
    db.commit()
    
    return {"status": "success", "message": "Яма зафиксирована"}

@app.get("/api/v1/telemetry")
async def get_telemetry(db: Session = Depends(get_db)):
    # Вытаскиваем все ямы из БД. ST_X и ST_Y вытягивают долготу и широту из PostGIS
    query = "SELECT id, user_id, speed_kmh, bump_force, ST_X(location) as lon, ST_Y(location) as lat FROM telemetry;"
    result = db.execute(text(query)).fetchall()

    bumps = []
    for row in result:
        bumps.append({
            "id": row.id,
            "user_id": row.user_id,
            "speed_kmh": row.speed_kmh,
            "bump_force": row.bump_force,
            "lat": row.lat,
            "lon": row.lon
        })
    return bumps