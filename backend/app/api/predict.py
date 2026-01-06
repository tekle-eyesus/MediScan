from fastapi import APIRouter, File, UploadFile, HTTPException, Form
from app.services.ml_service import ml_service
from app.models.medical_record import MedicalRecord

router = APIRouter()

@router.post("/analyze")
async def analyze_xray(
    file: UploadFile = File(...),
    patient_id: str = Form(...), # require Patient ID
    doctor_id: str = Form(...)   # require Doctor ID
):
    """
    Endpoint to analyze chest X-rays and SAVE the result.
    """
    if file.content_type not in ["image/jpeg", "image/png", "image/jpg"]:
        raise HTTPException(status_code=400, detail="Invalid file type.")

    try:
        # 1. Run AI Inference
        contents = await file.read()
        result = ml_service.predict(contents)
        
        # 2. Save to MongoDB
        record = MedicalRecord(
            patient_id=patient_id,
            doctor_id=doctor_id,
            prediction=result["prediction"],
            confidence=result["confidence"],
            heatmap_base64=result["heatmap_base64"]
        )
        await record.insert()
        
        return {
            "record_id": str(record.id),
            "patient_id": patient_id,
            "prediction": result["prediction"],
            "confidence": result["confidence"],
            "heatmap_base64": result["heatmap_base64"]
        }

    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

# Add a history endpoint to verify saving works
@router.get("/history/{patient_id}")
async def get_patient_history(patient_id: str):
    records = await MedicalRecord.find(MedicalRecord.patient_id == patient_id).to_list()
    return records