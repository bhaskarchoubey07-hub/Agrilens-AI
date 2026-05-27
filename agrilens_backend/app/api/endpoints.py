from fastapi import APIRouter, UploadFile, File, Form, Query
from app.services.speech import speech_service
from app.services.llm import LLMService
from app.services.recommendation import recommendation_service
from app.services.market import market_service
from app.services.finance import finance_service
from app.services.commerce import commerce_service
from app.services.languages import language_service
import random
import time

router = APIRouter()

@router.get("/health")
def health_check():
    return {"status": "ok", "timestamp": time.time()}

@router.get("/weather")
def get_weather(
    lat: float = Query(26.9124, description="Latitude"),
    lng: float = Query(75.7873, description="Longitude"),
    lang: str = Query("hi", description="Language code")
):
    """
    Get weather details and irrigation recommendations based on coordinates.
    """
    is_hindi = (lang == "hi")
    temp = round(random.uniform(28.0, 42.0), 1)
    humidity = random.randint(30, 85)
    wind = round(random.uniform(5.0, 20.0), 1)
    rain_probability = random.randint(0, 95)
    
    if rain_probability > 60:
        rec = "अगले 24 घंटों में भारी बारिश की संभावना है। सिंचाई करने की आवश्यकता नहीं है।" if is_hindi else "Heavy rain forecast in next 24 hours. No irrigation required."
    elif humidity > 75 and temp < 32:
        rec = "मिट्टी में नमी का स्तर अच्छा है। सिंचाई में 1-2 दिन की देरी की जा सकती है।" if is_hindi else "High humidity and low temp. Irrigation can be delayed by 1-2 days."
    elif temp > 38 and humidity < 40:
        rec = "गर्मी तेज है और नमी कम है। आज शाम को हल्की सिंचाई अवश्य करें।" if is_hindi else "High temperature and low moisture. Light irrigation recommended this evening."
    else:
        rec = "आगामी 24 घंटों में सिंचाई की आवश्यकता नहीं है।" if is_hindi else "No irrigation required for the next 24 hours."

    return {
        "temperature": f"{temp}°C",
        "humidity": f"{humidity}%",
        "wind_speed": f"{wind} km/h",
        "rain_forecast": "भारी वर्षा" if rain_probability > 70 else ("हल्की वर्षा" if rain_probability > 30 else "साफ मौसम"),
        "rain_probability": f"{rain_probability}%",
        "irrigation_recommendation": rec
    }

@router.post("/scan")
async def scan_crop(
    file: UploadFile = File(...),
    lang: str = Form("hi")
):
    """
    Scans a crop image and returns classification details, confidence, severity, and treatments.
    """
    contents = await file.read()
    result = recommendation_service.scan_image(file.filename, lang=lang)
    result["image_url"] = f"/static/scans/{file.filename}"
    return result

@router.post("/voice")
async def voice_assistant(
    file: UploadFile = File(...),
    lang: str = Form("hi")
):
    """
    Voice Assistant Endpoint
    """
    audio_bytes = await file.read()
    transcription = await speech_service.transcribe_audio(audio_bytes, file.filename)
    assistant_response = await LLMService.ask_assistant(transcription, lang=lang)
    tts_url = await speech_service.text_to_speech(assistant_response["text_response"], lang=lang)
    
    return {
        "user_query": transcription,
        "response_text": assistant_response["text_response"],
        "tts_audio_url": tts_url,
        "requires_clarification": assistant_response.get("requires_clarification", False),
        "crop": assistant_response.get("detected_crop", "Unknown"),
        "disease": assistant_response.get("detected_issue", "Unknown"),
        "severity": assistant_response.get("severity", "Low"),
        "recommendations": assistant_response.get("recommended_actions", []),
        "treatment_cost_inr": assistant_response.get("estimated_cost_inr", 0),
        "crop_saved_percentage": assistant_response.get("crop_saved_percentage", 100),
        "time_to_act": assistant_response.get("time_to_act", "")
    }

@router.post("/assistant-text")
async def text_assistant(
    query: str = Form(...),
    lang: str = Form("hi")
):
    """
    Text-based assistant endpoint.
    """
    assistant_response = await LLMService.ask_assistant(query, lang=lang)
    return {
        "user_query": query,
        "response_text": assistant_response["text_response"],
        "requires_clarification": assistant_response.get("requires_clarification", False),
        "crop": assistant_response.get("detected_crop", "Unknown"),
        "disease": assistant_response.get("detected_issue", "Unknown"),
        "severity": assistant_response.get("severity", "Low"),
        "recommendations": assistant_response.get("recommended_actions", []),
        "treatment_cost_inr": assistant_response.get("estimated_cost_inr", 0),
        "crop_saved_percentage": assistant_response.get("crop_saved_percentage", 100),
        "time_to_act": assistant_response.get("time_to_act", "")
    }

@router.get("/market-prices")
def get_prices(lang: str = Query("hi")):
    """
    Fetch Mandi market prices and predicted rates.
    """
    prices = market_service.get_market_prices(lang=lang)
    return {
        "market_name": "जयपुर कृषि मंडी (Jaipur Mandi)" if lang == "hi" else "Jaipur Central Mandi",
        "last_updated": "आज, 10:00 पूर्वाह्न" if lang == "hi" else "Today, 10:00 AM",
        "prices": prices
    }

@router.get("/government-schemes")
def get_schemes(
    farm_size: float = Query(2.0, description="Farm size in acres"),
    crop_type: str = Query("wheat", description="Current crop type"),
    lang: str = Query("hi")
):
    """
    Returns eligible schemes and benefits for the farmer.
    """
    is_hindi = (lang == "hi")
    schemes = [
        {
            "title": "पीएम किसान सम्मान निधि (PM-KISAN)" if is_hindi else "PM Kisan Samman Nidhi",
            "eligibility": "सभी सीमांत और छोटे किसान (स्वामित्व < 2 हेक्टेयर)" if is_hindi else "All small & marginal landholders (< 5 acres)",
            "subsidy": "₹6,000 प्रति वर्ष (₹2,000 की 3 किस्तें)" if is_hindi else "₹6,000/year (3 direct transfers of ₹2,000)",
            "description": "किसानों को वित्तीय सहायता प्रदान करने के लिए प्रत्यक्ष लाभ हस्तांतरण योजना।" if is_hindi else "Income support scheme providing financial aid directly to bank accounts of farmers.",
            "link": "https://pmkisan.gov.in"
        },
        {
            "title": "प्रधानमंत्री फसल बीमा योजना (PMFBY)" if is_hindi else "PM Fasal Bima Yojana",
            "eligibility": "सभी खरीफ और रबी फसल किसान" if is_hindi else "All farmers cultivating notified crops",
            "subsidy": "प्राकृतिक आपदाओं के खिलाफ न्यूनतम प्रीमियम पर 100% बीमा सुरक्षा" if is_hindi else "Low premium crop insurance protecting against natural disasters",
            "description": "बाढ़, सूखा और कीटों के कारण फसल खराब होने की स्थिति में वित्तीय सुरक्षा।" if is_hindi else "Protects farmers against crop failure due to weather or pests.",
            "link": "https://pmfby.gov.in"
        },
        {
            "title": "पीएम कृषि सिंचाई योजना - ड्रिप सिंचाई सब्सिडी" if is_hindi else "PM Krishi Sinchayee Yojana (Drip)",
            "eligibility": "ड्रिप/स्प्रिंकलर सिंचाई प्रणाली स्थापित करने वाले किसान" if is_hindi else "Farmers installing micro-irrigation systems",
            "subsidy": "लागत पर 55% से 80% तक की भारी सरकारी सब्सिडी" if is_hindi else "55% to 80% subsidy on installation cost of drip irrigation",
            "description": "जल संरक्षण और उत्पादकता बढ़ाने के लिए खेतों में ड्रिप प्रणाली लगाना।" if is_hindi else "Promotes 'More Crop Per Drop' through efficient water usage.",
            "link": "https://pmksy.gov.in"
        },
        {
            "title": "सौर ऊर्जा पंप सब्सिडी (पीएम कुसुम योजना)" if is_hindi else "PM-KUSUM Solar Pump Scheme",
            "eligibility": "ट्यूबवेल/कुएं वाले किसान जिन्हें बिजली की आवश्यकता है" if is_hindi else "Farmers with borewells needing irrigation power",
            "subsidy": "सौर पंप स्थापना लागत पर 60% सरकारी सब्सिडी और 30% ऋण सहायता" if is_hindi else "60% government subsidy and 30% loan support on solar pump installation",
            "description": "डीजल और महंगी ग्रिड बिजली से सौर सिंचाई पंपों पर स्विच करने के लिए।" if is_hindi else "Switch from diesel pumps to clean solar-powered agricultural pumps.",
            "link": "https://mnre.gov.in/solar-pumps"
        }
    ]
    
    if farm_size > 5.0:
        for scheme in schemes:
            if "PM-KISAN" in scheme["title"] or "PM Kisan" in scheme["title"]:
                scheme["eligibility"] = "केवल 2 हेक्टेयर से कम भूमि वाले किसान (आप सीमा पार कर चुके हैं)" if is_hindi else "For landholders < 5 acres (Your size exceeds eligibility)"
                
    return schemes

@router.get("/alerts")
def get_alerts(
    lat: float = Query(26.9124),
    lng: float = Query(75.7873),
    lang: str = Query("hi")
):
    """
    Get community disease outbreaks near coordinates.
    """
    is_hindi = (lang == "hi")
    alerts = [
        {
            "id": "alert1",
            "disease": "गेहूं का पीला रस्ट (Yellow Rust)" if is_hindi else "Yellow Rust (Wheat)",
            "distance": "1.2 किमी दूर" if is_hindi else "1.2 km away",
            "severity": "High",
            "reported_count": 8,
            "message": "आपके क्षेत्र में पीला रस्ट रोग तेजी से फैल रहा है। फसल की नियमित जांच करें।" if is_hindi else "Yellow Rust outbreak reported. Inspect your fields immediately."
        },
        {
            "id": "alert2",
            "disease": "टमाटर का अर्ली ब्लाइट (Tomato Early Blight)" if is_hindi else "Tomato Early Blight",
            "distance": "4.8 किमी दूर" if is_hindi else "4.8 km away",
            "severity": "Medium",
            "reported_count": 3,
            "message": "पत्तियों पर काले चक्रदार धब्बे दिखने पर कॉपर फंगिसाइड का छिड़काव करें।" if is_hindi else "Black rings seen on tomato leaves. Copper fungicide spray advised."
        }
    ]
    return {
        "summary": "5 किमी के भीतर उच्च कीट और रोग जोखिम" if is_hindi else "High pest risk within 5 km",
        "alerts": alerts
    }

# =====================================================================
#                        FINTECH ROUTES
# =====================================================================

@router.get("/finance/dashboard")
def get_finance_dashboard(
    farm_size: float = Query(2.0),
    crop_type: str = Query("wheat"),
    lang: str = Query("hi")
):
    score_details = finance_service.get_financial_health_score(farm_size, crop_type)
    return score_details

@router.get("/finance/loan-eligibility")
def check_loan_eligibility(
    farm_size: float = Query(2.0),
    crop_type: str = Query("wheat"),
    prev_harvest: float = Query(15.0),
    input_expenses: float = Query(18000.0),
    weather_risk: float = Query(0.3)
):
    loan_report = finance_service.calculate_loan_eligibility(
        farm_size=farm_size,
        crop_type=crop_type,
        prev_harvest=prev_harvest,
        input_expenses=input_expenses,
        weather_risk_score=weather_risk
    )
    return loan_report

@router.get("/finance/marketplace")
def get_marketplace_products(
    disease_key: str = Query("wheat_rust"),
    farm_size: float = Query(2.0),
    lang: str = Query("hi")
):
    products = commerce_service.get_marketplace_recommendations(
        disease_key=disease_key,
        farm_size=farm_size,
        lang=lang
    )
    return products

@router.get("/finance/insurance")
def get_insurance(
    weather_risk: float = Query(0.3),
    lang: str = Query("hi")
):
    policies = finance_service.get_insurance_recommendations(weather_risk, lang)
    return policies

@router.get("/finance/selling-advisor")
def get_selling_advisor(
    crop_id: str = Query("wheat"),
    current_price: float = Query(2100.0),
    lang: str = Query("hi")
):
    selling_report = finance_service.get_selling_advice(crop_id, current_price, lang)
    return selling_report

# =====================================================================
#                        VOICE AI ROUTES
# =====================================================================

@router.get("/voice/suggest-languages")
def suggest_languages(
    lat: float = Query(26.9124, description="GPS Latitude"),
    lng: float = Query(75.7873, description="GPS Longitude")
):
    """
    Auto Language Detection: Returns state name and suggested regional languages based on GPS.
    """
    suggestions = language_service.suggest_state_languages(lat, lng)
    return suggestions

@router.get("/voice/dialect-clarify")
def resolve_dialect_slang(
    query: str = Query(..., description="Slang voice input text"),
    lang: str = Query("hi")
):
    """
    Resolves regional agriculture slang terms and local farming speech patterns.
    """
    clarification = LLMService.resolve_slang_dialect(query, lang)
    return clarification
