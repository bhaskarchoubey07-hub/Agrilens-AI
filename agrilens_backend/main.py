import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.api.endpoints import router as api_router
from app.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="AgriLens AI API Backend for crop health scanning and farmer voice assistant.",
    version="1.0.0"
)

# Set CORS permissions for mobile app communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount a directory for simulated static media assets (e.g. sample scans and audio clips)
static_dir = os.path.join(os.path.dirname(__file__), "static")
os.makedirs(static_dir, exist_ok=True)
app.mount("/static", StaticFiles(directory=static_dir), name="static")

# Register API endpoints
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/")
def read_root():
    return {
        "message": "Welcome to AgriLens AI Server",
        "docs_url": "/docs",
        "api_v1_url": f"{settings.API_V1_STR}/health"
    }

if __name__ == "__main__":
    import uvicorn
    # Run uvicorn server on port 8000
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
