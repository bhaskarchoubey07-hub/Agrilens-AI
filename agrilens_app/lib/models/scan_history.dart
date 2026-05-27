class ScanHistory {
  final String id;
  final String cropName;
  final String diseaseName;
  final double confidence;
  final String severity;
  final int treatmentCost;
  final int cropSavedPercentage;
  final String timeToAct;
  final DateTime timestamp;
  final String? imageUrl;

  ScanHistory({
    required this.id,
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.treatmentCost,
    required this.cropSavedPercentage,
    required this.timeToAct,
    required this.timestamp,
    this.imageUrl,
  });

  // Convert to Map for local database / SharedPreferences caching
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropName': cropName,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'treatmentCost': treatmentCost,
      'cropSavedPercentage': cropSavedPercentage,
      'timeToAct': timeToAct,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  // Restore model from Map
  factory ScanHistory.fromMap(Map<String, dynamic> map) {
    return ScanHistory(
      id: map['id'] ?? '',
      cropName: map['cropName'] ?? '',
      diseaseName: map['diseaseName'] ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      severity: map['severity'] ?? 'Medium',
      treatmentCost: map['treatmentCost'] ?? 0,
      cropSavedPercentage: map['cropSavedPercentage'] ?? 0,
      timeToAct: map['timeToAct'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
      imageUrl: map['imageUrl'],
    );
  }
}
