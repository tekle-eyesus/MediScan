import certifi
from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie
from app.core.config import settings
from app.models.medical_record import MedicalRecord

async def init_db():
    """
    Initialize the database connection and Beanie ODM.
    """
    # Create Motor Client with SSL context
    client = AsyncIOMotorClient(
        settings.MONGO_URL,
        tlsCAFile=certifi.where()
    )
    
    # Initialize Beanie
    await init_beanie(
        database=client[settings.DATABASE_NAME],
        document_models=[MedicalRecord]
    )
    print("✅ MongoDB Connected and Beanie Initialized!")