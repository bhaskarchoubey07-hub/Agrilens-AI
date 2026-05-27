import random

class RecommendationService:
    DISEASE_DB = {
        "wheat_rust": {
            "name_en": "Wheat Rust (Leaf Rust)",
            "name_hi": "गेहूं का गेरूआ रोग (रस्ट)",
            "severity": "Medium",
            "confidence_range": (85, 96),
            "cost_inr": 450,
            "saved_percentage": 92,
            "time_to_act_en": "Within 48 hours",
            "time_to_act_hi": "अगले 48 घंटों के भीतर",
            "actions_en": [
                "Spray Propiconazole 25% EC (e.g., Tilt) at 1 ml per liter of water.",
                "Ensure recommended nitrogen fertilizer dosage; avoid excess nitrogen.",
                "Apply potassium fertilizer to build crop resistance."
            ],
            "actions_hi": [
                "प्रोपिकोनाजोल 25% EC (जैसे: टिल्ट) का 1 मिलीलीटर प्रति लीटर पानी में मिलाकर छिड़काव करें।",
                "नाइट्रोजन उर्वरक का सही मात्रा में उपयोग करें, अधिक नाइट्रोजन देने से बचें।",
                "फसल की प्रतिरोधक क्षमता बढ़ाने के लिए पोटेशियम उर्वरक डालें।"
            ]
        },
        "tomato_blight": {
            "name_en": "Tomato Late Blight",
            "name_hi": "टमाटर का पछेती झुलसा (ब्लाइट)",
            "severity": "High",
            "confidence_range": (88, 98),
            "cost_inr": 350,
            "saved_percentage": 85,
            "time_to_act_en": "Immediately (Within 24 hours)",
            "time_to_act_hi": "तुरंत (अगले 24 घंटों के भीतर)",
            "actions_en": [
                "Apply Copper Oxychloride 50% WP at 2.5 g per liter of water.",
                "Prune the lower leaves to improve air circulation and reduce humidity.",
                "Remove and burn severely infected leaves and plants."
            ],
            "actions_hi": [
                "कॉपर ऑक्सीक्लोराइड 50% WP का 2.5 ग्राम प्रति लीटर पानी में मिलाकर छिड़काव करें।",
                "हवा के संचार को बढ़ाने और नमी कम करने के लिए निचली पत्तियों की छंटाई करें।",
                "गंभीर रूप से संक्रमित पत्तियों और पौधों को खेत से हटाकर नष्ट कर दें।"
            ]
        },
        "rice_blast": {
            "name_en": "Rice Blast",
            "name_hi": "धान का झोंका रोग (ब्लास्ट)",
            "severity": "High",
            "confidence_range": (90, 97),
            "cost_inr": 600,
            "saved_percentage": 88,
            "time_to_act_en": "Within 3 days",
            "time_to_act_hi": "अगले 3 दिनों के भीतर",
            "actions_en": [
                "Spray Tricyclazole 75% WP (e.g., Beam) at 0.6 g per liter of water.",
                "Avoid ponding of water in fields under cloudy conditions.",
                "Avoid top dressing of nitrogen fertilizer during disease outbreak."
            ],
            "actions_hi": [
                "ट्राइसाइक्लाजोल 75% WP (जैसे: बीम) का 0.6 ग्राम प्रति लीटर पानी में मिलाकर छिड़काव करें।",
                "बादल छाए रहने की स्थिति में खेतों में बहुत अधिक पानी जमा न होने दें।",
                "रोग के प्रकोप के दौरान नाइट्रोजन उर्वरक का ऊपर से छिड़काव न करें।"
            ]
        },
        "potato_early_blight": {
            "name_en": "Potato Early Blight",
            "name_hi": "आलू का अगेती झुलसा",
            "severity": "Medium",
            "confidence_range": (82, 94),
            "cost_inr": 300,
            "saved_percentage": 90,
            "time_to_act_en": "Within 4 days",
            "time_to_act_hi": "अगले 4 दिनों के भीतर",
            "actions_en": [
                "Spray Mancozeb 75% WP at 2 g per liter of water.",
                "Maintain adequate soil moisture through drip or sprinkler irrigation.",
                "Harvest early if crop is mature to prevent tuber infection."
            ],
            "actions_hi": [
                "मैनकोज़ेब 75% WP का 2 ग्राम प्रति लीटर पानी में मिलाकर छिड़काव करें।",
                "ड्रिप या स्प्रिंकलर सिंचाई के माध्यम से मिट्टी में उचित नमी बनाए रखें।",
                "कंद संक्रमण को रोकने के लिए यदि फसल परिपक्व हो गई हो तो जल्दी खुदाई करें।"
            ]
        },
        "healthy_leaf": {
            "name_en": "Healthy Crop",
            "name_hi": "स्वस्थ फसल",
            "severity": "Low",
            "confidence_range": (95, 99),
            "cost_inr": 0,
            "saved_percentage": 100,
            "time_to_act_en": "No action needed",
            "time_to_act_hi": "किसी कार्रवाई की आवश्यकता नहीं है",
            "actions_en": [
                "Your crop is healthy! Maintain regular weeding and watering.",
                "Apply organic compost or Neem cake for long-term health.",
                "Keep scanning weekly to monitor health."
            ],
            "actions_hi": [
                "आपकी फसल पूरी तरह स्वस्थ है! नियमित निराई और सिंचाई जारी रखें।",
                "दीर्घकालिक स्वास्थ्य के लिए जैविक खाद या नीम की खली का प्रयोग करें।",
                "स्वास्थ्य की निगरानी के लिए साप्ताहिक रूप से स्कैन करते रहें।"
            ]
        }
    }

    @classmethod
    def get_recommendation(cls, disease_key: str, lang: str = "hi") -> dict:
        """
        Retrieves treatment and action recommendations for a disease in specified language.
        """
        disease = cls.DISEASE_DB.get(disease_key, cls.DISEASE_DB["healthy_leaf"])
        is_hindi = (lang == "hi")
        
        confidence = round(random.uniform(*disease["confidence_range"]), 2)
        
        return {
            "disease_key": disease_key,
            "disease_name": disease["name_hi"] if is_hindi else disease["name_en"],
            "severity": disease["severity"],
            "confidence": confidence,
            "estimated_cost_inr": disease["cost_inr"],
            "crop_saved_percentage": disease["saved_percentage"],
            "time_to_act": disease["time_to_act_hi"] if is_hindi else disease["time_to_act_en"],
            "recommended_actions": disease["actions_hi"] if is_hindi else disease["actions_en"]
        }

    @classmethod
    def scan_image(cls, file_name: str, lang: str = "hi") -> dict:
        """
        Simulates image classification output based on keywords in the filename.
        This provides a fallback endpoint.
        """
        file_name_lower = file_name.lower()
        if "wheat" in file_name_lower or "rust" in file_name_lower:
            key = "wheat_rust"
        elif "tomato" in file_name_lower or "blight" in file_name_lower:
            key = "tomato_blight"
        elif "rice" in file_name_lower or "blast" in file_name_lower:
            key = "rice_blast"
        elif "potato" in file_name_lower:
            key = "potato_early_blight"
        else:
            # Random selection for demo if no keyword matches
            key = random.choice(list(cls.DISEASE_DB.keys()))
            
        return cls.get_recommendation(key, lang)

recommendation_service = RecommendationService()
