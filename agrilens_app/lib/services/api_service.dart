import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  static Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Weather & Irrigation Recommendations
  static Future<Map<String, dynamic>> getWeather(double lat, double lng, String lang) async {
    try {
      final url = Uri.parse('$baseUrl/weather?lat=$lat&lng=$lng&lang=$lang');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint("Offline Mode: Weather fallback used.");
    }
    
    final isHi = lang == 'hi';
    return {
      "temperature": "32.4°C",
      "humidity": "64%",
      "wind_speed": "12.5 km/h",
      "rain_forecast": isHi ? "साफ मौसम" : "Sunny",
      "rain_probability": "15%",
      "irrigation_recommendation": isHi 
          ? "मिट्टी सूखी लग रही है, शाम को हल्की सिंचाई करें।" 
          : "Soil is moderately dry. Light evening irrigation recommended."
    };
  }

  // Scan Crop Disease (Upload Image)
  static Future<Map<String, dynamic>> scanCrop(File imageFile, String lang) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/scan'))
        ..fields['lang'] = lang
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
        
      final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint("Offline Mode: Crop scan local simulation used.");
    }

    final isHi = lang == 'hi';
    return {
      "disease_key": "wheat_rust",
      "disease_name": isHi ? "गेहूं का पत्ता रस्ट (Wheat Rust)" : "Wheat Leaf Rust",
      "severity": "Medium",
      "confidence": 92.5,
      "estimated_cost_inr": 450,
      "crop_saved_percentage": 90,
      "time_to_act": isHi ? "अगले 48 घंटे के भीतर" : "Within 48 hours",
      "recommended_actions": isHi 
          ? [
              "प्रोपिकोनाजोल 25% EC का 1ml प्रति लीटर पानी में छिड़काव करें।",
              "खेत में यूरिया डालने की गति नियंत्रित करें।"
            ]
          : [
              "Spray Propiconazole 25% EC at 1 ml/litre of water.",
              "Control Nitrogen fertilizer top dressing."
            ],
      "image_url": null
    };
  }

  // Send Voice query to assistant
  static Future<Map<String, dynamic>> sendVoiceAssistant(File audioFile, String lang) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/voice'))
        ..fields['lang'] = lang
        ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));
        
      final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint("Offline Mode: Voice Assistant local response used.");
    }

    final isHi = lang == 'hi';
    return {
      "user_query": isHi ? "गेहूं के पत्ते पीले हो रहे हैं" : "Wheat leaves yellowing",
      "response_text": isHi 
          ? "आपकी गेहूं की फसल में नाइट्रोजन की कमी या पीला रस्ट रोग हो सकता है। कृपया 450 रुपये की लागत से प्रोपिकोनाजोल फंगिसाइड का छिड़काव करें।" 
          : "Your wheat crops might have Nitrogen deficiency or Yellow Rust. We recommend spraying Propiconazole fungicide costing around Rs. 450.",
      "crop": isHi ? "गेहूं" : "Wheat",
      "disease": isHi ? "पीला रस्ट (Yellow Rust)" : "Yellow Rust",
      "severity": "Medium",
      "treatment_cost_inr": 450,
      "crop_saved_percentage": 90,
      "time_to_act": isHi ? "अगले 2 दिनों में" : "Within 2 days",
      "recommendations": isHi 
          ? ["यूरिया डालें", "प्रोपिकोनाजोल 25% EC का छिड़काव करें"] 
          : ["Apply urea fertilizer", "Spray Propiconazole 25% EC"]
    };
  }

  // Text Assistant fallback
  static Future<Map<String, dynamic>> sendTextAssistant(String query, String lang) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assistant-text'),
        body: {'query': query, 'lang': lang},
      ).timeout(const Duration(seconds: 8));
      
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint("Offline Mode: Text assistant fallback.");
    }

    final isHi = lang == 'hi' || lang == 'bho' || lang == 'mai' || lang == 'mwr';
    
    // Slang detection clarification loop (e.g. leaf drying query)
    if (query.contains("सूख") || query.contains("dry") || query.contains("sookh")) {
      return {
        "requires_clarification": true,
        "response_text": isHi
            ? "पत्तियां सूखने के कई कारण हो सकते हैं - जैसे पानी की कमी या झुलसा (Blight) रोग। क्या पत्तियों पर भूरे धब्बे दिखाई दे रहे हैं या वे किनारे से मुड़ रही हैं?"
            : "Leaves drying can be due to drought or blight. Do you see brown spots on the leaves, or are they curling from the edges?",
        "crop": "Crop",
        "disease": "Drying",
        "severity": "Medium",
        "treatment_cost_inr": 0,
        "crop_saved_percentage": 100,
        "time_to_act": "Within 24 hours",
        "recommendations": ["Upload leaf photo to diagnostic scanner", "Check soil humidity"]
      };
    }

    return {
      "requires_clarification": false,
      "response_text": isHi 
          ? "आपकी गेहूं की फसल में पीला रस्ट रोग होने की संभावना है। कल बारिश की संभावना है, इसलिए दवा का छिड़काव बारिश रुकने के बाद ही करें।" 
          : "Your wheat crop might have Yellow Rust. Rain is expected tomorrow, so it is better to spray fungicides after the rain stops.",
      "crop": "Wheat",
      "disease": "Yellow Rust",
      "severity": "Medium",
      "treatment_cost_inr": 450,
      "crop_saved_percentage": 92,
      "time_to_act": "After rain stops",
      "recommendations": ["Spray Propiconazole 25% EC after rain stops", "Control nitrogen top-dressing"]
    };
  }

  // Fetch Mandi market prices
  static Future<Map<String, dynamic>> getMarketPrices(String lang) async {
    try {
      final url = Uri.parse('$baseUrl/market-prices?lang=$lang');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    
    final isHi = lang == 'hi';
    return {
      "market_name": isHi ? "स्थानीय कृषि उपज मंडी" : "Local Agriculture Mandi",
      "last_updated": isHi ? "आज सुबह" : "Today Morning",
      "prices": [
        {"id": "wheat", "name": isHi ? "गेहूं (Wheat)" : "Wheat", "price": 2100, "unit": isHi ? "रु/क्विंटल" : "Rs/Quintal", "trend": "up", "predicted_price": 2300, "profit_outlook": isHi ? "अच्छा (+12%)" : "Good (+12%)", "color": "green"},
        {"id": "paddy", "name": isHi ? "धान (Paddy)" : "Paddy", "price": 2180, "unit": isHi ? "रु/क्विंटल" : "Rs/Quintal", "trend": "stable", "predicted_price": 2200, "profit_outlook": isHi ? "सामान्य (+5%)" : "Normal (+5%)", "color": "orange"},
        {"id": "potato", "name": isHi ? "आलू (Potato)" : "Potato", "price": 1400, "unit": isHi ? "रु/क्विंटल" : "Rs/Quintal", "trend": "down", "predicted_price": 1250, "profit_outlook": isHi ? "कम (-10%)" : "Low (-10%)", "color": "red"},
        {"id": "tomato", "name": isHi ? "टमाटर (Tomato)" : "Tomato", "price": 2800, "unit": isHi ? "रु/क्विंटल" : "Rs/Quintal", "trend": "up", "predicted_price": 3200, "profit_outlook": isHi ? "उत्कृष्ट (+25%)" : "Excellent (+25%)", "color": "green"}
      ]
    };
  }

  // Fetch Government Schemes list
  static Future<List<dynamic>> getGovernmentSchemes(double farmSize, String cropType, String lang) async {
    try {
      final url = Uri.parse('$baseUrl/government-schemes?farm_size=$farmSize&crop_type=$cropType&lang=$lang');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    
    final isHi = lang == 'hi';
    return [
      {
        "title": isHi ? "पीएम किसान सम्मान निधि" : "PM Kisan Samman Nidhi",
        "eligibility": isHi ? "सीमांत व छोटे किसान" : "Landholders < 5 acres",
        "subsidy": isHi ? "₹6,000 प्रति वर्ष" : "₹6,000/year in cash support",
        "description": isHi ? "प्रत्यक्ष लाभ अंतरण योजना।" : "Income support scheme.",
        "link": "https://pmkisan.gov.in"
      },
      {
        "title": isHi ? "ड्रिप सिंचाई यंत्र सब्सिडी" : "Drip Irrigation Subsidy",
        "eligibility": isHi ? "सभी लघु व सीमांत किसान" : "Farmers installing drip nets",
        "subsidy": isHi ? "लागत का 80% सब्सिडी" : "80% government subsidy on drip setup",
        "description": isHi ? "पानी बचाने और उपज बढ़ाने के लिए।" : "More crop per drop irrigation support.",
        "link": "https://pmksy.gov.in"
      }
    ];
  }

  // Fetch Outbreak Heatmap alerts
  static Future<Map<String, dynamic>> getDiseaseAlerts(double lat, double lng, String lang) async {
    try {
      final url = Uri.parse('$baseUrl/alerts?lat=$lat&lng=$lng&lang=$lang');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}

    final isHi = lang == 'hi';
    return {
      "summary": isHi ? "5 किमी के भीतर उच्च कीट जोखिम" : "High pest risk within 5 km",
      "alerts": [
        {
          "disease": isHi ? "गेहूं का पीला रस्ट" : "Yellow Rust",
          "distance": isHi ? "1.2 किमी दूर" : "1.2 km away",
          "severity": "High",
          "reported_count": 8,
          "message": isHi ? "आपके पड़ोस के खेतों में पीला रस्ट है। दवा छिड़कें।" : "Nearby crop has yellow rust. Spray fungicides."
        }
      ]
    };
  }

  // =====================================================================
  //                        FINTECH API CLIENTS
  // =====================================================================

  static Future<Map<String, dynamic>> getFinanceDashboard(double farmSize, String cropType, String lang) async {
    try {
      final url = Uri.parse('$baseUrl/finance/dashboard?farm_size=$farmSize&crop_type=$cropType&lang=$lang');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    
    return {
      "financial_score": 84,
      "breakdown": {
        "profit_potential": "High",
        "expense_control": "Medium",
        "loan_risk": "Low",
        "weather_risk": "Medium"
      }
    };
  }

  static Future<Map<String, dynamic>> checkLoanEligibility({
    required double farmSize,
    required String cropType,
    required double prevHarvest,
    required double inputExpenses,
    required double weatherRisk,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/finance/loan-eligibility'
          '?farm_size=$farmSize&crop_type=$cropType&prev_harvest=$prevHarvest'
          '&input_expenses=$inputExpenses&weather_risk=$weatherRisk');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}

    final double score = 50 + (farmSize * 4) - (weatherRisk * 25);
    final String eligibility = score > 60 ? "Medium" : "Low";
    final int minAmt = score > 60 ? 15000 : 5000;
    final int maxAmt = score > 60 ? 40000 : 12000;
    final double rate = score > 60 ? 11.5 : 14.5;
    
    final double totalRepay = ((minAmt + maxAmt) / 2) * (1 + (rate / 100));
    final double emi = totalRepay / 12;

    return {
      "eligibility_score": score.roundToDouble(),
      "loan_eligibility": eligibility,
      "suggested_amount_min": minAmt,
      "suggested_amount_max": maxAmt,
      "risk_level": "Low",
      "interest_rate_pct": rate,
      "repayment_months": 12,
      "estimated_monthly_payment": emi.roundToDouble()
    };
  }

  static Future<List<dynamic>> getMarketplaceProducts(String diseaseKey, double farmSize, String lang) async {
    try {
      final url = Uri.parse('$baseUrl/finance/marketplace?disease_key=$diseaseKey&farm_size=$farmSize&lang=$lang');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}

    final isHi = lang == 'hi';
    final isRust = diseaseKey.contains("rust") || diseaseKey.contains("wheat");
    
    return [
      {
        "category": isHi ? "कवकनाशी (Fungicide)" : "Fungicide",
        "id": isRust ? "propiconazole_25_ec" : "copper_oxychloride_50_wp",
        "name": isRust 
            ? (isHi ? "प्रोपिकोनाजोल 25% EC (कवकनाशी)" : "Propiconazole 25% EC (Fungicide)")
            : (isHi ? "कॉपर ऑक्सीक्लोराइड 50% WP" : "Copper Oxychloride 50% WP"),
        "price": isRust ? 450 : 350,
        "unit": isRust ? "Bottle (500ml)" : "Packet (500g)",
        "quantity_recommended": isRust ? (farmSize * 0.5) : (farmSize * 1.0),
        "estimated_cost": isRust ? (450 * farmSize * 0.5).round() : (350 * farmSize * 1.0).round(),
        "description": isRust 
            ? (isHi ? "पीला रस्ट कवक रोग नियंत्रण।" : "Yellow Rust fungus protection.")
            : (isHi ? "झुलसा/ब्लाइट कवक नियंत्रण।" : "Late Blight fungal prevention."),
        "store_availability": isHi ? "500 मीटर (कृष्णा एग्रो)" : "500m (Krishna Agro Stores)"
      },
      {
        "category": isHi ? "उर्वरक/खाद (Fertilizer)" : "Fertilizer",
        "id": "neem_urea",
        "name": isHi ? "नीम लेपित यूरिया (Urea)" : "Neem Coated Urea",
        "price": 266,
        "unit": "Bag (45kg)",
        "quantity_recommended": farmSize.roundToDouble(),
        "estimated_cost": (266 * farmSize).round(),
        "description": isHi ? "नाइट्रोजन का जैविक रूप से छिड़काव।" : "Organic nitrogen slow-release fertilizer.",
        "store_availability": isHi ? "1.2 किमी (जय किसान मंडी)" : "1.2 km (Jai Kisan Mandi)"
      }
    ];
  }

  static Future<List<dynamic>> getInsurancePolicies(double weatherRisk, String lang) async {
    try {
      final url = Uri.parse('$baseUrl/finance/insurance?weather_risk=$weatherRisk&lang=$lang');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}

    final isHi = lang == 'hi';
    return [
      {
        "id": "crop_insurance",
        "name": isHi ? "प्रधानमंत्री फसल बीमा योजना (PMFBY)" : "PM Fasal Bima Yojana (PMFBY)",
        "type": "Crop Insurance",
        "premium_rate": isHi ? "1.5% प्रीमियम" : "1.5% Premium Rate",
        "coverage": isHi ? "सूखा, बाढ़, चक्रवात और कीट क्षति" : "Drought, Flood, Storm & Pests",
        "explanation": isHi 
            ? "इस महीने आपके क्षेत्र में भारी बारिश का खतरा अधिक है।" 
            : "Heavy rainfall risk in your area is high this month.",
        "cost_per_acre": 250
      }
    ];
  }

  static Future<Map<String, dynamic>> getSellingAdvice(String cropId, double currentPrice, String lang) async {
    try {
      final url = Uri.parse('$baseUrl/finance/selling-advisor?crop_id=$cropId&current_price=$currentPrice&lang=$lang');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}

    final isHi = lang == 'hi';
    final double predictedPrice = currentPrice * 1.095;
    return {
      "current_price": currentPrice,
      "predicted_price_next_week": predictedPrice.roundToDouble(),
      "recommended_wait_days": 5,
      "recommendation": isHi
          ? "अगले 5 दिनों के लिए रुकें। भाव में बढ़ोतरी होने के संकेत हैं।"
          : "Wait 5 days to sell. Mandi price expected to rise.",
      "nearby_buyers": [
        {"name": isHi ? "जयपुर मंडी व्यापारी" : "Jaipur Mandi Traders", "distance": "4.5 km", "rating": "4.8★"}
      ]
    };
  }

  // =====================================================================
  //                        VOICE AI CLIENTS
  // =====================================================================

  // Auto Language Detection mapping based on GPS Coordinates
  static Future<Map<String, dynamic>> suggestLanguages(double lat, double lng) async {
    try {
      final url = Uri.parse('$baseUrl/voice/suggest-languages?lat=$lat&lng=$lng');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}

    // Offline Geofencing fallback
    String state = "Delhi";
    if (24.0 <= lat && lat <= 27.5 && 83.0 <= lng && lng <= 88.5) {
      state = "Bihar";
    } else if (8.0 <= lat && lat <= 13.5 && 76.0 <= lng && lng <= 80.5) {
      state = "Tamil Nadu";
    } else if (29.5 <= lat && lat <= 32.5 && 74.0 <= lng && lng <= 77.0) {
      state = "Punjab";
    }

    final opts = {
      "Bihar": [
        {"code": "hi", "name": "हिन्दी (Hindi)"},
        {"code": "bho", "name": "भोजपुरी (Bhojpuri)"},
        {"code": "mai", "name": "मैथिली (Maithili)"}
      ],
      "Tamil Nadu": [
        {"code": "ta", "name": "தமிழ் (Tamil)"},
        {"code": "en", "name": "English"}
      ],
      "Punjab": [
        {"code": "pa", "name": "ਪੰਜਾਬੀ (Punjabi)"},
        {"code": "hi", "name": "हिन्दी (Hindi)"}
      ],
      "Delhi": [
        {"code": "hi", "name": "हिन्दी (Hindi)"},
        {"code": "en", "name": "English"}
      ]
    };

    return {
      "detected_state": state,
      "primary_language": state == "Tamil Nadu" ? "ta" : (state == "Punjab" ? "pa" : "hi"),
      "suggested_languages": opts[state] ?? opts["Delhi"]
    };
  }

  // Dialect Slang clarify client
  static Future<Map<String, dynamic>> dialectClarify(String query, String lang) async {
    try {
      final url = Uri.parse('$baseUrl/voice/dialect-clarify?query=$query&lang=$lang');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}

    // Offline dialect slang resolver fallback
    final isRust = query.contains("पीला") || query.contains("yellow");
    return {
      "term_matched": query,
      "normalized_meaning": isRust ? "Yellow Rust (पीला रस्ट)" : "Leaf Drying (पत्ता सूखना)",
      "common_causes": isRust ? "Fungal Yellow Rust" : "Late Blight / Dehydration",
      "recommended_diagnostic": "Upload leaf picture to scan disease."
    };
  }

  static Map<String, dynamic> calculateProfitLocal(double farmSize, String cropId, double yieldPerAcre) {
    final cropCostDb = {
      "wheat": {"cost_per_acre": 15000, "price_per_quintal": 2100},
      "paddy": {"cost_per_acre": 18000, "price_per_quintal": 2180},
      "potato": {"cost_per_acre": 25000, "price_per_quintal": 1400},
      "tomato": {"cost_per_acre": 35000, "price_per_quintal": 2800}
    };
    
    final stats = cropCostDb[cropId] ?? {"cost_per_acre": 15000, "price_per_quintal": 2000};
    final double costPerAcre = stats["cost_per_acre"]!.toDouble();
    final double pricePerQuintal = stats["price_per_quintal"]!.toDouble();

    final totalCost = costPerAcre * farmSize;
    final totalYield = yieldPerAcre * farmSize;
    final grossRevenue = totalYield * pricePerQuintal;
    final netProfit = grossRevenue - totalCost;
    
    return {
      "total_cost_inr": totalCost.round(),
      "total_yield_quintals": totalYield.round(),
      "gross_revenue_inr": grossRevenue.round(),
      "net_profit_inr": netProfit.round(),
      "roi_percentage": totalCost > 0 ? (netProfit / totalCost * 100).round() : 0
    };
  }
}
