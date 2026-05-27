class LanguageService:
    # Dialect Database mapping for all 28 States and 8 Union Territories in India
    STATE_LANGUAGE_MAP = {
        "Bihar": {
            "primary": "hi",
            "options": [
                {"code": "hi", "name": "हिन्दी (Hindi)"},
                {"code": "bho", "name": "भोजपुरी (Bhojpuri)"},
                {"code": "mai", "name": "मैथिली (Maithili)"},
                {"code": "mag", "name": "मगही (Magahi)"}
            ]
        },
        "Uttar Pradesh": {
            "primary": "hi",
            "options": [
                {"code": "hi", "name": "हिन्दी (Hindi)"},
                {"code": "awa", "name": "अवधी (Awadhi)"},
                {"code": "bho", "name": "भोजपुरी (Bhojpuri)"},
                {"code": "ur", "name": "उर्दू (Urdu)"}
            ]
        },
        "Punjab": {
            "primary": "pa",
            "options": [
                {"code": "pa", "name": "ਪੰਜਾਬੀ (Punjabi)"},
                {"code": "hi", "name": "हिन्दी (Hindi)"}
            ]
        },
        "West Bengal": {
            "primary": "bn",
            "options": [
                {"code": "bn", "name": "বাংলা (Bengali)"},
                {"code": "hi", "name": "हिन्दी (Hindi)"}
            ]
        },
        "Tamil Nadu": {
            "primary": "ta",
            "options": [
                {"code": "ta", "name": "தமிழ் (Tamil)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Maharashtra": {
            "primary": "mr",
            "options": [
                {"code": "mr", "name": "मराठी (Marathi)"},
                {"code": "hi", "name": "हिन्दी (Hindi)"}
            ]
        },
        "Gujarat": {
            "primary": "gu",
            "options": [
                {"code": "gu", "name": "ગુજરાતી (Gujarati)"},
                {"code": "hi", "name": "हिन्दी (Hindi)"}
            ]
        },
        "Rajasthan": {
            "primary": "hi",
            "options": [
                {"code": "hi", "name": "हिन्दी (Hindi)"},
                {"code": "mwr", "name": "मारवाड़ी (Marwari)"}
            ]
        },
        "Assam": {
            "primary": "as",
            "options": [
                {"code": "as", "name": "অসমীয়া (Assamese)"},
                {"code": "hi", "name": "हिन्दी (Hindi)"}
            ]
        },
        "Odisha": {
            "primary": "or",
            "options": [
                {"code": "or", "name": "ଓଡ଼ିଆ (Odia)"},
                {"code": "hi", "name": "हिन्दी (Hindi)"}
            ]
        },
        "Andhra Pradesh": {
            "primary": "te",
            "options": [
                {"code": "te", "name": "తెలుగు (Telugu)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Telangana": {
            "primary": "te",
            "options": [
                {"code": "te", "name": "తెలుగు (Telugu)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Karnataka": {
            "primary": "kn",
            "options": [
                {"code": "kn", "name": "ಕನ್ನಡ (Kannada)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Kerala": {
            "primary": "ml",
            "options": [
                {"code": "ml", "name": "മലയാളം (Malayalam)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Haryana": {
            "primary": "hi",
            "options": [
                {"code": "hi", "name": "हिन्दी (Hindi)"},
                {"code": "har", "name": "हरियाणवी (Haryanvi)"}
            ]
        },
        "Madhya Pradesh": {
            "primary": "hi",
            "options": [
                {"code": "hi", "name": "हिन्दी (Hindi)"},
                {"code": "bun", "name": "बुंदेलखंडी (Bundeli)"}
            ]
        },
        "Himachal Pradesh": {
            "primary": "hi",
            "options": [
                {"code": "hi", "name": "हिन्दी (Hindi)"},
                {"code": "pah", "name": "पहाड़ी (Pahari)"}
            ]
        },
        "Uttarakhand": {
            "primary": "hi",
            "options": [
                {"code": "hi", "name": "हिन्दी (Hindi)"},
                {"code": "kum", "name": "कुमाऊनी (Kumaoni)"},
                {"code": "gar", "name": "गढ़वाली (Garhwali)"}
            ]
        },
        "Jammu & Kashmir": {
            "primary": "ur",
            "options": [
                {"code": "ks", "name": "कश्मीरी (Kashmiri)"},
                {"code": "doi", "name": "डोगरी (Dogri)"},
                {"code": "ur", "name": "उर्दू (Urdu)"}
            ]
        },
        "Jharkhand": {
            "primary": "hi",
            "options": [
                {"code": "hi", "name": "हिन्दी (Hindi)"},
                {"code": "kho", "name": "खोरठा (Khortha)"},
                {"code": "sad", "name": "सादरी (Sadri)"}
            ]
        },
        "Chhattisgarh": {
            "primary": "hi",
            "options": [
                {"code": "hi", "name": "हिन्दी (Hindi)"},
                {"code": "chg", "name": "छत्तीसगढ़ी (Chhattisgarhi)"}
            ]
        },
        "Goa": {
            "primary": "kok",
            "options": [
                {"code": "kok", "name": "कोंकणी (Konkani)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Tripura": {
            "primary": "bn",
            "options": [
                {"code": "bn", "name": "বাংলা (Bengali)"},
                {"code": "kok_t", "name": "कॉकबोरोक (Kokborok)"}
            ]
        },
        "Manipur": {
            "primary": "mni",
            "options": [
                {"code": "mni", "name": "मणिपुरी (Manipuri)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Meghalaya": {
            "primary": "en",
            "options": [
                {"code": "kha", "name": "खासी (Khasi)"},
                {"code": "gar_m", "name": "गारो (Garo)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Nagaland": {
            "primary": "en",
            "options": [
                {"code": "ao", "name": "आओ (Ao)"},
                {"code": "ang", "name": "अंगामी (Angami)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Mizoram": {
            "primary": "lus",
            "options": [
                {"code": "lus", "name": "मिज़ो (Mizo)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Sikkim": {
            "primary": "ne",
            "options": [
                {"code": "ne", "name": "नेपाली (Nepali)"},
                {"code": "en", "name": "English"}
            ]
        },
        
        # Union Territories
        "Delhi": {
            "primary": "hi",
            "options": [
                {"code": "hi", "name": "हिन्दी (Hindi)"},
                {"code": "pa", "name": "ਪੰਜਾਬੀ (Punjabi)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Chandigarh": {
            "primary": "pa",
            "options": [
                {"code": "pa", "name": "ਪੰਜਾਬੀ (Punjabi)"},
                {"code": "hi", "name": "हिन्दी (Hindi)"}
            ]
        },
        "Puducherry": {
            "primary": "ta",
            "options": [
                {"code": "ta", "name": "தமிழ் (Tamil)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Ladakh": {
            "primary": "ur",
            "options": [
                {"code": "lb", "name": "लद्दाखी (Ladakhi)"},
                {"code": "ur", "name": "उर्दू (Urdu)"}
            ]
        },
        "Lakshadweep": {
            "primary": "ml",
            "options": [
                {"code": "ml", "name": "മലയാളം (Malayalam)"},
                {"code": "en", "name": "English"}
            ]
        },
        "Andaman and Nicobar Islands": {
            "primary": "hi",
            "options": [
                {"code": "hi", "name": "हिन्दी (Hindi)"},
                {"code": "bn", "name": "বাংলা (Bengali)"},
                {"code": "ta", "name": "தமிழ் (Tamil)"}
            ]
        },
        "Dadra and Nagar Haveli and Daman and Diu": {
            "primary": "gu",
            "options": [
                {"code": "gu", "name": "ગુજરાતી (Gujarati)"},
                {"code": "mr", "name": "मराठी (Marathi)"},
                {"code": "hi", "name": "हिन्दी (Hindi)"}
            ]
        }
    }

    @classmethod
    def get_state_from_gps(cls, lat: float, lng: float) -> str:
        """
        Geofencing State Boundary Estimator.
        Approximates the Indian state name based on regional coordinate blocks.
        """
        # Approximations of Indian geographical centers
        if 24.0 <= lat <= 27.5 and 83.0 <= lng <= 88.5:
            return "Bihar"
        elif 24.5 <= lat <= 30.5 and 77.0 <= lng <= 84.5:
            return "Uttar Pradesh"
        elif 29.5 <= lat <= 32.5 and 74.0 <= lng <= 77.0:
            return "Punjab"
        elif 21.5 <= lat <= 27.0 and 85.5 <= lng <= 89.9:
            return "West Bengal"
        elif 8.0 <= lat <= 13.5 and 76.0 <= lng <= 80.5:
            return "Tamil Nadu"
        elif 15.5 <= lat <= 22.0 and 72.5 <= lng <= 80.8:
            return "Maharashtra"
        elif 20.0 <= lat <= 24.8 and 68.0 <= lng <= 74.5:
            return "Gujarat"
        elif 23.3 <= lat <= 30.2 and 69.5 <= lng <= 78.2:
            return "Rajasthan"
        elif 24.0 <= lat <= 28.3 and 89.8 <= lng <= 96.0:
            return "Assam"
        elif 17.5 <= lat <= 22.5 and 81.2 <= lng <= 87.5:
            return "Odisha"
        else:
            return "Delhi" # Capital default fallback

    @classmethod
    def suggest_state_languages(cls, lat: float, lng: float) -> dict:
        """
        Returns state-specific primary language code and local dialect option parameters.
        """
        state_name = cls.get_state_from_gps(lat, lng)
        config = cls.STATE_LANGUAGE_MAP.get(state_name, cls.STATE_LANGUAGE_MAP["Delhi"])
        
        return {
            "detected_state": state_name,
            "primary_language": config["primary"],
            "suggested_languages": config["options"]
        }

language_service = LanguageService()
