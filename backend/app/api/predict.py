from fastapi import APIRouter, File, UploadFile, HTTPException, Form, Depends
from sqlmodel import Session, select
from app.services.ml_service import ml_service
from app.models.medical_record import MedicalRecord
from app.core.database import get_session

router = APIRouter()

@router.post("/analyze")
async def analyze_xray(
    file: UploadFile = File(...),
    patient_id: str = Form(...),
    doctor_id: str = Form(...),
    session: Session = Depends(get_session) # <--- Inject DB Session here
):
    """
    Endpoint to analyze chest X-rays and SAVE the result to SQLite.
    """
    if file.content_type not in ["image/jpeg", "image/png", "image/jpg"]:
        raise HTTPException(status_code=400, detail="Invalid file type.")

    try:
        # pridict
        contents = await file.read()
        result = ml_service.predict(contents)
        
        record = MedicalRecord(
            patient_id=patient_id,
            doctor_id=doctor_id,
            prediction=result["prediction"],
            confidence=result["confidence"],
            heatmap_base64=result["heatmap_base64"]
        )
        
        session.add(record)
        session.commit()
        session.refresh(record) # Get the generated ID
        
        return {
            "record_id": record.id,
            "patient_id": patient_id,
            "prediction": result["prediction"],
            "confidence": result["confidence"],
            "heatmap_base64": result["heatmap_base64"]
        }

    except Exception as e:
        print(f"Error: {e}")
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

@router.get("/history/{patient_id}")
async def get_patient_history(
    patient_id: str, 
    session: Session = Depends(get_session)
):
    statement = select(MedicalRecord).where(MedicalRecord.patient_id == patient_id)
    results = session.exec(statement).all()
    return results

# Add this new route at the bottom of the file
@router.get("/records/recent")
async def get_recent_records(session: Session = Depends(get_session)):
    """
    Get the 50 most recent diagnoses for the History Tab.
    """
    statement = select(MedicalRecord).order_by(MedicalRecord.created_at.desc()).limit(50)
    results = session.exec(statement).all()
    return results