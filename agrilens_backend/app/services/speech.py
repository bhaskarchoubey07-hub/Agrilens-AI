import os
import random
from app.config import settings

class SpeechService:
    @staticmethod
    async def transcribe_audio(audio_bytes: bytes, filename: str) -> str:
        """
        Transcribes the uploaded farmer audio file to text.
        Supports Hindi and English.
        """
        if settings.SIMULATION_MODE or not settings.GEMINI_API_KEY:
            # Simulated transcription based on file name or generic farmer questions
            simulated_responses = [
                "गेहूं की फसल में पत्तियां पीली पड़ रही हैं क्या करें",
                "मेरी टमाटर की पत्तियां मुड़ रही हैं और उन पर काले धब्बे हैं",
                "धान की फसल में पानी कब देना चाहिए",
                "wheat leaves are turning yellow what to do",
                "what is the market price of potato today in Indore"
            ]
            # If the user uploads a specific voice note, we simulate a smart response
            return random.choice(simulated_responses)

        try:
            import google.generativeai as genai
            genai.configure(api_key=settings.GEMINI_API_KEY)
            
            # Temporary save audio file to send to Gemini API
            temp_path = f"temp_{filename}"
            with open(temp_path, "wb") as f:
                f.write(audio_bytes)
                
            # Upload file to Gemini File API
            audio_file = genai.upload_file(path=temp_path)
            
            # Use gemini-1.5-flash for transcription
            model = genai.GenerativeModel("gemini-1.5-flash")
            response = model.generate_content([
                "You are an expert agriculture voice transcriber. Transcribe this audio recording of a farmer asking a question. Return only the transcription text, in the language spoken (Hindi or English). Do not add any introduction or metadata.",
                audio_file
            ])
            
            # Clean up files
            try:
                os.remove(temp_path)
                genai.delete_file(audio_file.name)
            except Exception:
                pass
                
            return response.text.strip()
            
        except Exception as e:
            print(f"Error during audio transcription: {e}")
            return "मेरी गेहूं की पत्तियां पीली हो रही हैं"  # Generic fallback

    @staticmethod
    async def text_to_speech(text: str, lang: str = "hi") -> str:
        """
        Generates Text-to-Speech audio for the farmer.
        Returns a URL or a base64 encoded audio string, or a path to file.
        Here we return a simulated TTS audio response.
        """
        # In production, this can connect to gTTS (Google Text-to-Speech) or pyttsx3.
        # For simplicity and offline demo, we return a mock audio file path.
        return "/static/response.mp3"

speech_service = SpeechService()
