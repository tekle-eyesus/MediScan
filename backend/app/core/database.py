from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie
from app.core.config import settings
from app.models.medical_record import MedicalRecord

async def init_db():
    """
    Initialize the database connection and Beanie ODM.
    """
    # Create Motor Client
    client = AsyncIOMotorClient(settings.MONGO_URL)
    
    # Initialize Beanie with the specific database and models
    await init_beanie(
        database=client[settings.DATABASE_NAME],
        document_models=[MedicalRecord]
    )
    print("✅ MongoDB Connected and Beanie Initialized!")