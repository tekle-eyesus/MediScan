from fastapi import APIRouter, File, UploadFile, HTTPException
from app.services.ml_service import ml_service

router = APIRouter()

@router.post("/analyze")
async def analyze_xray(file: UploadFile = File(...)):
    """
    Endpoint to analyze chest X-rays.
    - Accepts: Image File
    - Returns: JSON with prediction, confidence score, and Base64 Heatmap
    """
    # Validate file type
    if file.content_type not in ["image/jpeg", "image/png", "image/jpg"]:
        raise HTTPException(status_code=400, detail="Invalid file type. Please upload JPEG or PNG.")

    try:
        # Read file contents
        contents = await file.read()
        
        # Pass to ML Service
        result = ml_service.predict(contents)
        
        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")