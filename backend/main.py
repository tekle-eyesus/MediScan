from fastapi import FastAPI
from app.api import predict

app = FastAPI(
    title="MediScan Ethiopia API",
    description="Backend for Pneumonia Detection and XAI generation",
    version="1.0.0"
)

app.include_router(predict.router, prefix="/api/v1", tags=["AI Diagnosis"])

@app.get("/")
async def root():
    return {"message": "MediScan Backend is running", "status": "active"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

# after running, access the docs at:
# http://127.0.0.1:8000/docs