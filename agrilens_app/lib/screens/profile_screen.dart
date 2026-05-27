import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../models/scan_history.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _farmSizeController = TextEditingController(text: "2.5");
  final _locationController = TextEditingController(text: "Jaipur, Rajasthan");
  String _cropType = "wheat";
  List<ScanHistory> _scanHistoryList = [];
  bool _isSaving = false;

  // Manual list of 14 languages requested
  final List<Map<String, String>> _allLanguages = [
    {"code": "hi", "name": "हिन्दी (Hindi)"},
    {"code": "bho", "name": "भोजपुरी (Bhojpuri)"},
    {"code": "mai", "name": "मैथिली (Maithili)"},
    {"code": "pa", "name": "ਪੰਜਾਬੀ (Punjabi)"},
    {"code": "mr", "name": "मराठी (Marathi)"},
    {"code": "gu", "name": "ગુજરાતી (Gujarati)"},
    {"code": "ta", "name": "தமிழ் (Tamil)"},
    {"code": "te", "name": "తెలుగు (Telugu)"},
    {"code": "kn", "name": "ಕನ್ನಡ (Kannada)"},
    {"code": "ml", "name": "മലയാളം (Malayalam)"},
    {"code": "bn", "name": "বাংলা (Bengali)"},
    {"code": "or", "name": "ଓଡ଼ିଆ (Odia)"},
    {"code": "as", "name": "অসমীया (Assamese)"},
    {"code": "en", "name": "English"},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadScanHistory();
  }

  @override
  void dispose() {
    _farmSizeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _farmSizeController.text = prefs.getString('farm_size') ?? "2.5";
        _locationController.text = prefs.getString('location') ?? "Jaipur, Rajasthan";
        _cropType = prefs.getString('crop_type') ?? "wheat";
      });
    }
  }

  Future<void> _saveProfileData(AppLocalizations localizations) async {
    setState(() {
      _isSaving = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farm_size', _farmSizeController.text);
    await prefs.setString('location', _locationController.text);
    await prefs.setString('crop_type', _cropType);
    await prefs.setString('preferred_locale', localizations.locale);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.locale == 'hi' 
                ? "विवरण सफलतापूर्वक सुरक्षित कर लिया गया है।" 
                : "Profile details saved successfully."
          ),
          backgroundColor: Colors.green[800],
        ),
      );
    }
  }

  void _loadScanHistory() {
    final now = DateTime.now();
    setState(() {
      _scanHistoryList = [
        ScanHistory(
          id: "scan1",
          cropName: "गेहूं (Wheat)",
          diseaseName: "पीला रस्ट (Yellow Rust)",
          confidence: 91.8,
          severity: "Medium",
          treatmentCost: 450,
          cropSavedPercentage: 92,
          timeToAct: "Within 48 hours",
          timestamp: now.subtract(const Duration(days: 3)),
        ),
        ScanHistory(
          id: "scan2",
          cropName: "टमाटर (Tomato)",
          diseaseName: "स्वस्थ (Healthy Leaf)",
          confidence: 98.4,
          severity: "Low",
          treatmentCost: 0,
          cropSavedPercentage: 100,
          timeToAct: "No action needed",
          timestamp: now.subtract(const Duration(days: 10)),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = Provider.of<AppLocalizations>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('profile')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.locale == 'hi' ? "किसान विवरण" : "Farmer Profile Details",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Farm Size
                      TextField(
                        controller: _farmSizeController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          labelText: "${localizations.translate('farm_size')} (${localizations.locale == 'hi' ? 'एकड़' : 'Acres'})",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.photo_size_select_small),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Location State
                      TextField(
                        controller: _locationController,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          labelText: localizations.translate('location'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Crop Dropdown
                      DropdownButtonFormField<String>(
                        value: _cropType,
                        decoration: InputDecoration(
                          labelText: localizations.translate('crop_type'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.grass),
                        ),
                        items: const [
                          DropdownMenuItem(value: "wheat", child: Text("गेहूं (Wheat)")),
                          DropdownMenuItem(value: "paddy", child: Text("धान (Paddy)")),
                          DropdownMenuItem(value: "potato", child: Text("आलू (Potato)")),
                          DropdownMenuItem(value: "tomato", child: Text("टमाटर (Tomato)")),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _cropType = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Expanded manual selector with 14 languages
                      DropdownButtonFormField<String>(
                        value: localizations.locale,
                        decoration: InputDecoration(
                          labelText: localizations.translate('select_lang'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.language),
                        ),
                        items: _allLanguages.map((lang) {
                          return DropdownMenuItem<String>(
                            value: lang["code"],
                            child: Text(lang["name"] ?? '', style: const TextStyle(fontSize: 18)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            localizations.setLocale(val);
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Save
                      ElevatedButton(
                        onPressed: _isSaving ? null : () => _saveProfileData(localizations),
                        child: _isSaving 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(localizations.translate('save')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Scan History
              Text(
                localizations.translate('scan_history'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              _scanHistoryList.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text("कोई इतिहास नहीं है (No history)"),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _scanHistoryList.length,
                      itemBuilder: (context, index) {
                        final scan = _scanHistoryList[index];
                        final formattedDate = "${scan.timestamp.day}/${scan.timestamp.month}/${scan.timestamp.year}";
                        final isHealthy = scan.diseaseName.contains("स्वस्थ") || scan.diseaseName.contains("Healthy");

                        return Card(
                          child: ListTile(
                            leading: Icon(
                              isHealthy ? Icons.check_circle : Icons.warning_amber,
                              color: isHealthy ? Colors.green : Colors.orange[800],
                              size: 32,
                            ),
                            title: Text(
                              "${scan.cropName} • ${scan.diseaseName}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${localizations.translate('severity')}: ${scan.severity} • $formattedDate",
                              style: const TextStyle(fontSize: 15),
                            ),
                            trailing: Text(
                              "₹${scan.treatmentCost}",
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                                color: isHealthy ? Colors.green : Colors.red[800],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
