class CommerceService:
    PRODUCT_CATALOG = {
        "fungicides": [
            {
                "id": "propiconazole_25_ec",
                "name_en": "Propiconazole 25% EC (Fungicide)",
                "name_hi": "प्रोपिकोनाजोल 25% EC (कवकनाशी)",
                "base_price_inr": 450,
                "unit": "Bottle (500ml)",
                "dosage_per_acre": 0.5, # bottles per acre
                "image_name": "fungicide_bottle.png",
                "description_en": "Controls Yellow Rust, Leaf Rust and Powdery Mildew.",
                "description_hi": "पीला रस्ट, लीफ रस्ट और पाउडरी मिल्ड्यू को नियंत्रित करता है।"
            },
            {
                "id": "copper_oxychloride_50_wp",
                "name_en": "Copper Oxychloride 50% WP (Blitox)",
                "name_hi": "कॉपर ऑक्सीक्लोराइड 50% WP (ब्लाइटोक्स)",
                "base_price_inr": 350,
                "unit": "Packet (500g)",
                "dosage_per_acre": 1.0, # packets per acre
                "image_name": "blitox_packet.png",
                "description_en": "Broad spectrum contact fungicide for Late Blight and Downy Mildew.",
                "description_hi": "पछेती झुलसा और डाउनी मिल्ड्यू के लिए कवकनाशी।"
            }
        ],
        "fertilizers": [
            {
                "id": "neem_urea",
                "name_en": "Neem Coated Urea",
                "name_hi": "नीम लेपित यूरिया (Urea)",
                "base_price_inr": 266,
                "unit": "Bag (45kg)",
                "dosage_per_acre": 1.0, # bags per acre
                "image_name": "urea_bag.png",
                "description_en": "Essential Nitrogen fertilizer with slow release formula.",
                "description_hi": "नीम लेपित फॉर्मूले के साथ आवश्यक नाइट्रोजन उर्वरक।"
            },
            {
                "id": "npk_19_19_19",
                "name_en": "NPK soluble 19:19:19",
                "name_hi": "NPK घुलनशील 19:19:19",
                "base_price_inr": 150,
                "unit": "Packet (1kg)",
                "dosage_per_acre": 2.0, # packets per acre
                "image_name": "npk_packet.png",
                "description_en": "Balanced water-soluble nutrients for uniform crop growth.",
                "description_hi": "फसल के समान विकास के लिए संतुलित जल-घुलनशील पोषक तत्व।"
            }
        ],
        "supplements": [
            {
                "id": "zinc_chelated_12",
                "name_en": "Chelated Zinc (12% EDTA)",
                "name_hi": "जिंक चिलेटेड (12% EDTA)",
                "base_price_inr": 180,
                "unit": "Packet (250g)",
                "dosage_per_acre": 0.5, # packets per acre
                "image_name": "zinc_packet.png",
                "description_en": "Overcomes zinc deficiency, aids chlorophyll production.",
                "description_hi": "जिंक की कमी को दूर करता है, क्लोरोफिल उत्पादन में सहायता करता है।"
            }
        ]
    }

    @classmethod
    def get_marketplace_recommendations(
        cls, 
        disease_key: str, 
        farm_size: float, 
        lang: str = "hi"
    ) -> list:
        """
        AI Crop Medicine Marketplace recommendation engine.
        Returns product quantities and local store stocks based on acreage and leaf disease.
        """
        is_hindi = (lang == "hi")
        products = []
        
        # 1. Match specific fungicide based on disease scan key
        recommended_fungicide = None
        if "rust" in disease_key or "wheat" in disease_key:
            recommended_fungicide = cls.PRODUCT_CATALOG["fungicides"][0] # Propiconazole
        elif "blight" in disease_key or "tomato" in disease_key or "potato" in disease_key:
            recommended_fungicide = cls.PRODUCT_CATALOG["fungicides"][1] # Copper Oxychloride
            
        if recommended_fungicide:
            # Calculate required quantity
            qty = max(1.0, round(recommended_fungicide["dosage_per_acre"] * farm_size, 1))
            total_cost = round(qty * recommended_fungicide["base_price_inr"])
            products.append({
                "category": "Fungicide" if not is_hindi else "कवकनाशी",
                "id": recommended_fungicide["id"],
                "name": recommended_fungicide["name_hi"] if is_hindi else recommended_fungicide["name_en"],
                "price": recommended_fungicide["base_price_inr"],
                "unit": recommended_fungicide["unit"],
                "quantity_recommended": qty,
                "estimated_cost": total_cost,
                "description": recommended_fungicide["description_hi"] if is_hindi else recommended_fungicide["description_en"],
                "store_availability": "500m (Krishna Agro)" if is_hindi else "500m (Krishna Agro Stores)"
            })
            
        # 2. Add Fertilizer (e.g. Urea or NPK depending on disease key)
        fertilizer = cls.PRODUCT_CATALOG["fertilizers"][0] if "rust" in disease_key else cls.PRODUCT_CATALOG["fertilizers"][1]
        qty_fert = max(1, round(fertilizer["dosage_per_acre"] * farm_size))
        total_cost_fert = round(qty_fert * fertilizer["base_price_inr"])
        products.append({
            "category": "Fertilizer" if not is_hindi else "उर्वरक/खाद",
            "id": fertilizer["id"],
            "name": fertilizer["name_hi"] if is_hindi else fertilizer["name_en"],
            "price": fertilizer["base_price_inr"],
            "unit": fertilizer["unit"],
            "quantity_recommended": float(qty_fert),
            "estimated_cost": total_cost_fert,
            "description": fertilizer["description_hi"] if is_hindi else fertilizer["description_en"],
            "store_availability": "1.2 km (Jai Kisan Mandi)" if is_hindi else "1.2 km (Jai Kisan Mandi)"
        })

        # 3. Add Zinc Supplement
        zinc = cls.PRODUCT_CATALOG["supplements"][0]
        qty_zinc = max(1.0, round(zinc["dosage_per_acre"] * farm_size, 1))
        products.append({
            "category": "Nutrients" if not is_hindi else "पोषक तत्व",
            "id": zinc["id"],
            "name": zinc["name_hi"] if is_hindi else zinc["name_en"],
            "price": zinc["base_price_inr"],
            "unit": zinc["unit"],
            "quantity_recommended": qty_zinc,
            "estimated_cost": round(qty_zinc * zinc["base_price_inr"]),
            "description": zinc["description_hi"] if is_hindi else zinc["description_en"],
            "store_availability": "500m (Krishna Agro)" if is_hindi else "500m (Krishna Agro Stores)"
        })
        
        return products

commerce_service = CommerceService()
