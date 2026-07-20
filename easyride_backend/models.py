from sqlalchemy import Column, Integer, Float, DateTime, String
from geoalchemy2 import Geometry
from database import Base
import datetime

class TelemetryData(Base):
    __tablename__ = "telemetry"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, index=True)
    # PostGIS геометрия для хранения координат (Долгота, Широта)
    location = Column(Geometry('POINT', srid=4326)) 
    speed_kmh = Column(Float)
    # Ускорение (сила удара), нормализованное к вектору гравитации
    bump_force = Column(Float) 
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)