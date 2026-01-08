from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.api import predict
from app.core.database import init_db

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db() 
    yield

app = FastAPI(
    title="MediScan Ethiopia API",
    description="Backend for Pneumonia Detection and XAI generation",
    version="1.0.0",
    lifespan=lifespan
)

app.include_router(predict.router, prefix="/api/v1", tags=["AI Diagnosis"])

@app.get("/")
async def root():
    return {"message": "MediScan Backend is running (SQLite)", "status": "active"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)


# after running, access the docs at:
# http://127.0.0.1:8000/docs