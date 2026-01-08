from sqlmodel import SQLModel, Field
from datetime import datetime
from typing import Optional

class MedicalRecord(SQLModel, table=True):
    """
    Represents a single X-ray diagnosis event.
    """
    id: Optional[int] = Field(default=None, primary_key=True)
    patient_id: str
    doctor_id: str
    prediction: str          # "PNEUMONIA" or "NORMAL"
    confidence: float        # e.g., 0.98
    heatmap_base64: Optional[str] = None 
    created_at: datetime = Field(default_factory=datetime.now)