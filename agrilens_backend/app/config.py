import os
from dotenv import load_dotenv

# Load .env file if it exists
load_dotenv()

class Settings:
    PROJECT_NAME: str = "AgriLens AI Backend"
    API_V1_STR: str = "/api"
    
    # AI Keys (can be configured in .env or system environment)
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    
    # Firebase configuration
    FIREBASE_CREDENTIALS_PATH: str = os.getenv("FIREBASE_CREDENTIALS_PATH", "")
    
    # Weather configuration
    OPENWEATHER_API_KEY: str = os.getenv("OPENWEATHER_API_KEY", "")
    
    # Run in simulation/demo mode if API keys are missing
    SIMULATION_MODE: bool = True

    def __init__(self):
        # If Gemini key is set, we can run real AI features
        if self.GEMINI_API_KEY:
            self.SIMULATION_MODE = False

settings = Settings()
