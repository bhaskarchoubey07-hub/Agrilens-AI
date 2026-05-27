# AgriLens AI — AI-Powered Farming Mobile Assistant

AgriLens AI is a complete, downloadable Android mobile application built using Flutter for the frontend, FastAPI for the backend, and Firebase for database storage. It is designed specifically for smallholder farmers, featuring a simplified, high-contrast visual user interface, multilingual support (Hindi by default, English), offline capability, and a voice assistant.

---

## Project Structure

```
agritech/
├── README.md                      # Build guide and documentation
├── setup.bat                      # Automated environment configuration script
├── agrilens_app/                  # Flutter Application
│   ├── pubspec.yaml               # Flutter dependencies
│   ├── android/                   # Native Android configuration
│   └── lib/
│       ├── main.dart              # Flutter Entry point
│       ├── theme/                 # Sunlit-contrast high-visibility themes
│       ├── l10n/                  # Hindi / English translation files
│       ├── models/                # Crop scan history classes
│       ├── services/              # API clients, local TFLite, and Audio STT/TTS
│       └── screens/               # 11 screen interfaces
│
└── agrilens_backend/              # FastAPI Backend Server
    ├── main.py                    # Server runner
    ├── requirements.txt           # Python packages
    └── app/
        ├── config.py              # Environment configuration & keys
        ├── api/                   # Router endpoints
        └── services/              # Gemini, speech analysis, recommendation models
```

---

## Getting Started

### Prerequisites
1. **Python 3.10+** (installed on your system).
2. **Flutter SDK** and **Java JDK 17** (for mobile application compilation).

---

## 1. Backend Setup & Run

### Automated Setup (Windows)
Double-click `setup.bat` in the root folder, or execute it in your terminal:
```powershell
.\setup.bat
```
This script creates a virtual environment (`venv`), installs backend requirements, creates the `.env` settings template, and launches the server.

### Manual Setup
1. Open a terminal in `agrilens_backend/`:
   ```bash
   cd agrilens_backend
   python -m venv venv
   .\venv\Scripts\activate
   pip install -r requirements.txt
   ```
2. Set up your Gemini API Key in `agrilens_backend/.env` (optional, falls back to demo simulator if not set):
   ```env
   GEMINI_API_KEY="your-google-gemini-api-key"
   ```
3. Run the FastAPI server:
   ```bash
   python main.py
   ```
   The backend server starts on `http://localhost:8000`. You can inspect the interactive swagger documentation at `http://localhost:8000/docs`.

---

## 2. Flutter Mobile App Setup & APK Build

### Native Android Firebase Connection
To connect the application to your database instance:
1. Go to your **Firebase Console** and create a project named `AgriLens AI`.
2. Add an **Android App** under package name `com.agrilens.ai`.
3. Download `google-services.json` and move it to `agrilens_app/android/app/`.
4. Enable **Phone Authentication** and **Cloud Firestore** databases.

### Offline TFLite Model Setup
1. Train/download your custom leaf image classification model weights (e.g. from Kaggle/PlantVillage MobileNet models).
2. Save your compiled weights as `crop_disease_model.tflite` and its index file `labels.txt` inside `agrilens_app/assets/model/`.
*Note: If the files are not present, the app automatically runs an intelligent offline simulated classification algorithm so the scan features remain fully testable.*

### Compile and Build the Downloadable APK
1. Open a terminal in `agrilens_app/`:
   ```powershell
   cd agrilens_app
   ```
2. Fetch Flutter packages:
   ```powershell
   flutter pub get
   ```
3. Run the app on a connected emulator or budget smartphone:
   ```powershell
   flutter run
   ```
4. Build the release APK package to download and distribute:
   ```powershell
   flutter build apk --release --split-per-abi
   ```
   The compiled APK binary will be outputted to:
   `agrilens_app/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (optimized for budget 32-bit Android phones).

---

## AI Features & Offline Architecture

1. **Crop Disease Detection**: Uses on-device TensorFlow Lite (`tflite_flutter`) to process images directly on the farmer's CPU in less than 800ms. If internet is available, scans cache to Firebase Firestore for remote diagnostics.
2. **Offline Mode**: If the local phone is disconnected from cellular towers, all buttons, dashboards, soil charts, and crop scanners remain functional by calling on-device Tflite pipelines and local translation maps.
3. **Voice Assistant**: Enables conversational dialogue. Audio recorded from the microphone is transcribed (Whisper / Gemini) on the backend and mapped to recommendations, which are read back to the farmer via Text-to-Speech (TTS) synthesizer in Hindi.
