import json
from app.config import settings

class LLMService:
    @staticmethod
    async def ask_assistant(query: str, lang: str = "hi") -> dict:
        """
        Analyze a query from a farmer and return structured farming recommendations.
        Supports regional language mapping, slang words, and clarification loops.
        """
        query_lower = query.lower()
        
        # Rule-based simulator for demo / offline / simulation mode
        if settings.SIMULATION_MODE or not settings.GEMINI_API_KEY:
            return LLMService._get_simulated_response(query_lower, lang)

        try:
            import google.generativeai as genai
            genai.configure(api_key=settings.GEMINI_API_KEY)
            
            model = genai.GenerativeModel("gemini-1.5-flash")
            
            prompt = f"""
            You are "AgriLens AI", an expert agricultural assistant helping smallholder farmers.
            The farmer's query is: "{query}"
            The requested response language is: "{lang}" (either "hi" for Hindi, regional codes like "bho", "mai", "pa", "ta", etc., or "en" for English).
            
            IMPORTANT: Farmers often use local agricultural terms, slangs, or ambiguous phrases like "पत्ता सूख रहा है" (leaves drying) or "कीड़ा लग गया है" (pests are there). 
            If the query is too ambiguous to identify a specific disease, set "requires_clarification" to true, and write a simple clarification question in "text_response" (e.g., "क्या धान के पत्ते मुड़ रहे हैं या उन पर भूरे धब्बे हैं?").
            
            Analyze the query and return a JSON object with the following structure. Do not return any other text, markdown, or HTML. Just raw JSON.
            
            {{
              "requires_clarification": false,
              "text_response": "A direct, simple, and warm reply to the farmer in their selected language. Keep it very simple, friendly, and practical.",
              "detected_crop": "Name of the crop identified (e.g. Wheat, Tomato, Rice, or 'Unknown')",
              "detected_issue": "The crop disease or pest issue identified (e.g. Yellow Rust, Leaf Curl, or 'Unknown')",
              "severity": "Low, Medium, or High",
              "recommended_actions": [
                 "Step-by-step action 1 in the selected language",
                 "Step-by-step action 2 in the selected language",
                 "Step-by-step action 3 in the selected language"
              ],
              "estimated_cost_inr": 350,
              "crop_saved_percentage": 85,
              "time_to_act": "Within 48 hours"
            }}
            """
            
            response = model.generate_content(prompt)
            clean_text = response.text.strip()
            if clean_text.startswith("```"):
                clean_text = clean_text.split("```")[1]
                if clean_text.startswith("json"):
                    clean_text = clean_text[4:]
            clean_text = clean_text.strip()
            
            return json.loads(clean_text)
            
        except Exception as e:
            print(f"Error in LLMService: {e}")
            return LLMService._get_simulated_response(query_lower, lang)

    @staticmethod
    def _get_simulated_response(query: str, lang: str) -> dict:
        is_hi = (lang == "hi" or lang == "bho" or lang == "mai" or lang == "mwr")
        
        # Dialect slang understanding: "पत्ता सूख रहा है" or "पत्ता पीला"
        if "सूख रहा" in query or "dry" in query or "sookh" in query:
            # Ambiguous query requires clarification
            if is_hi:
                return {
                    "requires_clarification": True,
                    "text_response": "पत्तियां सूखने के कई कारण हो सकते हैं - जैसे पानी की कमी या झुलसा (Blight) रोग। क्या पत्तियों पर भूरे धब्बे दिखाई दे रहे हैं या वे किनारे से मुड़ रही हैं?",
                    "detected_crop": "अज्ञात (Unknown)",
                    "detected_issue": "अस्पष्ट (Drying Leaves)",
                    "severity": "Medium",
                    "recommended_actions": [
                        "कृपया पौधे की प्रभावित पत्तियों की एक स्पष्ट तस्वीर खींचकर अपलोड करें।",
                        "मिट्टी की नमी जांचें। यदि सूखी है, तो सिंचाई करें।"
                    ],
                    "estimated_cost_inr": 0,
                    "crop_saved_percentage": 100,
                    "time_to_act": "अगले 24 घंटों में स्पष्ट करें"
                }
            else:
                return {
                    "requires_clarification": True,
                    "text_response": "Leaves drying can be due to drought or blight. Do you see brown spots on the leaves, or are they curling from the edges?",
                    "detected_crop": "Unknown",
                    "detected_issue": "Drying Leaves",
                    "severity": "Medium",
                    "recommended_actions": [
                        "Please upload a clear leaf photo for disease scanning.",
                        "Check soil moisture levels immediately."
                    ],
                    "estimated_cost_inr": 0,
                    "crop_saved_percentage": 100,
                    "time_to_act": "Within 24 hours"
                }
        elif "yellow" in query or "पीला" in query or "पीली" in query:
            if is_hi:
                return {
                    "requires_clarification": False,
                    "text_response": "आपकी गेहूं की फसल में पीला रस्ट रोग होने की संभावना है। कल बारिश की संभावना है, इसलिए दवा का छिड़काव बारिश रुकने के बाद ही करें।",
                    "detected_crop": "गेहूं (Wheat)",
                    "detected_issue": "पीला रस्ट (Yellow Rust)",
                    "severity": "Medium",
                    "recommended_actions": [
                        "बारिश समाप्त होने के बाद प्रोपिकोनाजोल 25% EC का छिड़काव करें",
                        "प्रभावित पौधों को खेत से अलग करें"
                    ],
                    "estimated_cost_inr": 450,
                    "crop_saved_percentage": 92,
                    "time_to_act": "बारिश रुकते ही"
                }
            else:
                return {
                    "requires_clarification": False,
                    "text_response": "Your wheat crop might have Yellow Rust. Rain is expected tomorrow, so it is better to spray fungicides after the rain stops.",
                    "detected_crop": "Wheat",
                    "detected_issue": "Yellow Rust",
                    "severity": "Medium",
                    "recommended_actions": [
                        "Spray Propiconazole 25% EC after the rain stops",
                        "Destroy crop residues of infected plants"
                    ],
                    "estimated_cost_inr": 450,
                    "crop_saved_percentage": 92,
                    "time_to_act": "After rain stops"
                }
        else:
            # Generic Response
            if is_hi:
                return {
                    "requires_clarification": False,
                    "text_response": "नमस्ते! मुझे अपनी फसल के बारे में बताएं। उदाहरण के लिए कह सकते हैं: 'गेहूं के पत्ते पीले हो रहे हैं' या 'धान में कीड़ा लगा है'।",
                    "detected_crop": "अज्ञात",
                    "detected_issue": "अज्ञात",
                    "severity": "Low",
                    "recommended_actions": ["कृपया समस्या का विवरण स्पष्ट बोलें"],
                    "estimated_cost_inr": 0,
                    "crop_saved_percentage": 100,
                    "time_to_act": "कोई तात्कालिकता नहीं"
                }
            else:
                return {
                    "requires_clarification": False,
                    "text_response": "Hello! Describe your crop issue. For example: 'Wheat leaves are turning yellow' or 'Bugs in my rice field'.",
                    "detected_crop": "Unknown",
                    "detected_issue": "Unknown",
                    "severity": "Low",
                    "recommended_actions": ["Please describe your symptoms clearly"],
                    "estimated_cost_inr": 0,
                    "crop_saved_percentage": 100,
                    "time_to_act": "No urgency"
                }

    @staticmethod
    def resolve_slang_dialect(query: str, lang: str = "hi") -> dict:
        """
        Parses common farming slangs and returns the normalized agricultural issue.
        """
        query_l = query.lower()
        if "कीड़ा" in query_l or "कीड़े" in query_l or "sundi" in query_l or "bug" in query_l:
            return {
                "term_matched": "कीड़ा (Pest/Insect)",
                "normalized_meaning": "Pest Attack (कीट प्रकोप)",
                "common_causes": "Stem borer, leaf folders or aphids",
                "recommended_diagnostic": "Upload leaf/shoot photo to check specific species."
            }
        elif "सूख" in query_l or "sookh" in query_l or "dry" in query_l:
            return {
                "term_matched": "सूखना (Drying)",
                "normalized_meaning": "Blight or Water Deficit (झुलसा रोग या जल अभाव)",
                "common_causes": "Fungal blast, root rot or dehydration",
                "recommended_diagnostic": "Verify soil moisture value first, then scan leaves."
            }
        else:
            return {
                "term_matched": query,
                "normalized_meaning": "General crop query",
                "common_causes": "General nutrients or weather concern",
                "recommended_diagnostic": "Upload leaf picture or ask voice assistant."
            }
