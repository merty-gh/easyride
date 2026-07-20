from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import text
from geoalchemy2.elements import WKTElement
from database import engine, get_db
import models
import requests

# PostGIS extension + tables
with engine.begin() as conn:
    conn.execute(text("CREATE EXTENSION IF NOT EXISTS postgis"))

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="EasyRide MVP API")


class TelemetryPayload(BaseModel):
    user_id: str
    latitude: float
    longitude: float
    speed_kmh: float
    bump_force: float


def get_snapped_coordinates(lat, lon):
    try:
        url = f"http://router.project-osrm.org/nearest/v1/driving/{lon},{lat}"
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            data = response.json()
            if data.get("waypoints"):
                snapped_lon = data["waypoints"][0]["location"][0]
                snapped_lat = data["waypoints"][0]["location"][1]
                return snapped_lat, snapped_lon
    except Exception as e:
        print(f"Ошибка OSRM: {e}")

    return lat, lon


def calculate_normalized_force(bump_force, speed_kmh):
    speed = max(speed_kmh, 20.0)
    coefficient = speed / 20.0
    normalized = bump_force / coefficient
    return round(normalized, 2)


@app.get("/health")
def health(db: Session = Depends(get_db)):
    """Проверка, что API и БД живы."""
    try:
        db.execute(text("SELECT 1"))
        postgis = db.execute(text("SELECT PostGIS_Version()")).scalar()
        return {"status": "ok", "database": "ok", "postgis": postgis}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"DB error: {e}")


@app.post("/api/v1/telemetry")
async def receive_telemetry(data: TelemetryPayload, db: Session = Depends(get_db)):
    try:
        snapped_lat, snapped_lon = get_snapped_coordinates(data.latitude, data.longitude)
        real_bump_force = calculate_normalized_force(data.bump_force, data.speed_kmh)

        # GeoAlchemy2 требует WKTElement, не сырую строку
        point = WKTElement(f"POINT({snapped_lon} {snapped_lat})", srid=4326)

        new_record = models.TelemetryData(
            user_id=data.user_id,
            location=point,
            speed_kmh=data.speed_kmh,
            bump_force=real_bump_force,
        )
        db.add(new_record)
        db.commit()

        return {
            "status": "success",
            "message": "Яма привязана к дороге и сохранена",
            "snapped_lat": snapped_lat,
            "snapped_lon": snapped_lon,
            "bump_force": real_bump_force,
        }
    except Exception as e:
        db.rollback()
        print(f"POST /telemetry error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/telemetry")
async def get_telemetry(db: Session = Depends(get_db)):
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

    try:
        result = db.execute(text(query)).fetchall()

        bumps = []
        for row in result:
            is_confirmed = (row.unique_users >= 2) or (row.total_hits >= 3)
            bumps.append({
                "cluster_id": row.cluster_id,
                "lat": row.lat,
                "lon": row.lon,
                "max_force": row.max_force,
                "unique_users": row.unique_users,
                "total_hits": row.total_hits,
                "is_confirmed": is_confirmed,
            })

        return bumps
    except Exception as e:
        print(f"GET /telemetry error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
