import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    # App Config
    PROJECT_NAME: str = os.getenv("PROJECT_NAME", "MediScan Ethiopia")
    API_PREFIX: str = os.getenv("API_PREFIX", "/api/v1")
    
    # Database Config
    MONGO_URL: str = os.getenv("MONGO_URL", "mongodb://localhost:27017")
    DATABASE_NAME: str = os.getenv("DATABASE_NAME", "mediscan_db")
    
    # Origins (for CORS later when Frontend connects)
    BACKEND_CORS_ORIGINS: list = ["*"]

    class Config:
        case_sensitive = True

settings = Settings()