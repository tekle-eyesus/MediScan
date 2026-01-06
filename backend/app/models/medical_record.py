from beanie import Document
from datetime import datetime
from typing import Optional

class MedicalRecord(Document):
    """
    Represents a single X-ray diagnosis event.
    """
    patient_id: str
    doctor_id: str
    prediction: str          # "PNEUMONIA" or "NORMAL"
    confidence: float        # e.g., 0.98
    heatmap_base64: Optional[str] = None # Base64 encoded heatmap image
    created_at: datetime = datetime.now()

    class Settings:
        name = "medical_records"