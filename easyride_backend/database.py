from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# Подключаемся к нашему Docker-контейнеру
DATABASE_URL = "postgresql://admin:password123@localhost:5432/easyride_db"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()