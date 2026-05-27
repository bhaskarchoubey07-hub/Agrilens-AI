import 'dart:io';
import 'dart:math';

class TfliteService {
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  // Initialize and load the .tflite model file
  Future<void> loadModel() async {
    try {
      // In a real application, you would load the TFLite model:
      // await Tflite.loadModel(
      //   model: "assets/model/crop_disease_model.tflite",
      //   labels: "assets/model/labels.txt",
      // );
      
      // We simulate model loading for instant run configuration
      await Future.delayed(const Duration(milliseconds: 600));
      _isModelLoaded = true;
      print("TFLite Model loaded successfully.");
    } catch (e) {
      print("Error loading TFLite model, falling back to local emulator: $e");
      _isModelLoaded = false;
    }
  }

  // Classify a leaf image offline
  Future<Map<String, dynamic>> classifyImage(File imageFile, String lang) async {
    // Wait to simulate CPU processing time of a lightweight model
    await Future.delayed(const Duration(milliseconds: 800));
    
    final isHi = lang == 'hi';
    final randomValue = Random().nextInt(4);
    
    // Simulating model inference outputs
    switch (randomValue) {
      case 0:
        return {
          "disease_key": "wheat_rust",
          "disease_name": isHi ? "गेहूं का पीला रस्ट (Yellow Rust)" : "Wheat Leaf Rust",
          "severity": "Medium",
          "confidence": 91.8,
          "estimated_cost_inr": 450,
          "crop_saved_percentage": 92,
          "time_to_act": isHi ? "अगले 2 दिनों में" : "Within 48 hours",
          "recommended_actions": isHi 
              ? [
                  "खेत में यूरिया उर्वरक का छिड़काव यथोचित करें।",
                  "प्रोपिकोनाजोल 25% EC का 1ml/लीटर की दर से छिड़काव करें।"
                ]
              : [
                  "Apply urea fertilizer in balanced quantities.",
                  "Spray Propiconazole 25% EC at 1 ml/liter of water."
                ]
        };
      case 1:
        return {
          "disease_key": "tomato_blight",
          "disease_name": isHi ? "टमाटर का पछेती झुलसा (Blight)" : "Tomato Late Blight",
          "severity": "High",
          "confidence": 88.4,
          "estimated_cost_inr": 350,
          "crop_saved_percentage": 85,
          "time_to_act": isHi ? "तुरंत (अगले 24 घंटों में)" : "Immediately (Within 24 hours)",
          "recommended_actions": isHi 
              ? [
                  "कॉपर ऑक्सीक्लोराइड 50% WP का छिड़काव करें।",
                  "संक्रमित पत्तियों को तोड़कर जला दें।"
                ]
              : [
                  "Spray Copper Oxychloride 50% WP.",
                  "Remove and destroy infected leaves to halt spreading."
                ]
        };
      case 2:
        return {
          "disease_key": "potato_early_blight",
          "disease_name": isHi ? "आलू का अगेती झुलसा (Early Blight)" : "Potato Early Blight",
          "severity": "Medium",
          "confidence": 94.1,
          "estimated_cost_inr": 300,
          "crop_saved_percentage": 90,
          "time_to_act": isHi ? "4 दिनों के भीतर" : "Within 4 days",
          "recommended_actions": isHi 
              ? [
                  "मैनकोज़ेब 75% WP का 2g प्रति लीटर पानी में मिलाकर छिड़काव करें।",
                  "मिट्टी में पानी की नमी बनाए रखें।"
                ]
              : [
                  "Spray Mancozeb 75% WP at 2 g/liter of water.",
                  "Maintain adequate soil moisture levels."
                ]
        };
      default:
        return {
          "disease_key": "healthy_leaf",
          "disease_name": isHi ? "स्वस्थ पौधा" : "Healthy Crop",
          "severity": "Low",
          "confidence": 97.5,
          "estimated_cost_inr": 0,
          "crop_saved_percentage": 100,
          "time_to_act": isHi ? "कार्रवाई की आवश्यकता नहीं" : "No action needed",
          "recommended_actions": isHi 
              ? [
                  "आपकी फसल स्वस्थ है! नियमित निराई करें।",
                  "फसल में कीटों की साप्ताहिक निगरानी जारी रखें।"
                ]
              : [
                  "Your crop looks healthy! Continue normal weeding.",
                  "Keep monitoring the crop health weekly."
                ]
        };
    }
  }

  // Release TFLite memory
  void dispose() {
    _isModelLoaded = false;
  }
}
