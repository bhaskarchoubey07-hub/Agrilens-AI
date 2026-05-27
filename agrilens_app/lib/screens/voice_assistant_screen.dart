import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/voice_service.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  String _userText = "";
  String _assistantText = "";
  bool _isLoading = false;
  Map<String, dynamic>? _structuredData;
  
  // Accessibility Font size multiplier (1.0 = Normal, 1.3 = Large)
  double _fontScale = 1.0; 
  
  // Simulated GPS Coordinates for Testing Auto Language Detection
  double _simulatedLat = 26.9124; // Default Jaipur, Rajasthan
  double _simulatedLng = 75.7873;
  String _detectedState = "Rajasthan";
  List<dynamic> _suggestedLanguages = [];
  bool _showLocationSuggestion = false;

  @override
  void initState() {
    super.initState();
    _triggerAutoLanguageDetect();
  }

  @override
  void dispose() {
    final voiceService = Provider.of<VoiceService>(context, listen: false);
    voiceService.stopSpeaking();
    super.dispose();
  }

  // Trigger geofencing API to suggest local languages based on GPS
  Future<void> _triggerAutoLanguageDetect() async {
    final data = await ApiService.suggestLanguages(_simulatedLat, _simulatedLng);
    setState(() {
      _detectedState = data['detected_state'] ?? '';
      _suggestedLanguages = data['suggested_languages'] ?? [];
      
      // If detected state matches current locale, don't show suggestion banner.
      // E.g. if we detect Tamil Nadu and they speak Tamil, no banner is needed.
      _showLocationSuggestion = true;
    });
  }

  // Simulate coordinate movement for user testing
  void _simulateLocationChange(String state) {
    setState(() {
      if (state == "Bihar") {
        _simulatedLat = 25.5941;
        _simulatedLng = 85.1376;
      } else if (state == "Punjab") {
        _simulatedLat = 31.3260;
        _simulatedLng = 75.5762;
      } else if (state == "Tamil Nadu") {
        _simulatedLat = 11.1271;
        _simulatedLng = 78.6569;
      } else {
        _simulatedLat = 26.9124;
        _simulatedLng = 75.7873;
      }
    });
    _triggerAutoLanguageDetect();
  }

  // Handle Speech query submission
  Future<void> _handleMicPress(VoiceService voiceService, AppLocalizations localizations) async {
    if (voiceService.isListening) {
      await voiceService.stopListening();
    } else {
      await voiceService.stopSpeaking();
      setState(() {
        _userText = "";
        _assistantText = "";
        _structuredData = null;
      });

      await voiceService.startListening((text) {
        if (text.isNotEmpty) {
          setState(() {
            _userText = text;
          });
          _processVoiceQuery(text, localizations, voiceService);
        }
      });
    }
  }

  Future<void> _processVoiceQuery(
    String query, 
    AppLocalizations localizations, 
    VoiceService voiceService
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Connect to speech query endpoints (incorporates automatic offline fallbacks)
      final response = await ApiService.sendTextAssistant(query, localizations.locale);
      
      setState(() {
        _assistantText = response['response_text'] ?? '';
        _structuredData = response;
        _isLoading = false;
      });

      // Synthetic TTS Playback
      if (_assistantText.isNotEmpty) {
        await voiceService.speak(_assistantText, localizations.locale);
      }
    } catch (e) {
      setState(() {
        _assistantText = localizations.locale == 'hi' 
            ? 'सर्वर कनेक्शन अनुपलब्ध है।' 
            : 'Server connection offline.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = Provider.of<AppLocalizations>(context);
    final voiceService = Provider.of<VoiceService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('voice_assistant')),
        actions: [
          // 1. Accessibility Large Text Scaler
          IconButton(
            icon: Icon(_fontScale > 1.0 ? Icons.text_fields : Icons.text_format),
            onPressed: () {
              setState(() {
                _fontScale = _fontScale > 1.0 ? 1.0 : 1.35;
              });
            },
            tooltip: "Enlarge Text",
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          // 2. Geofencing Language auto-detection suggestion Banner
          if (_showLocationSuggestion && _suggestedLanguages.isNotEmpty)
            Container(
              color: isDark ? const Color(0xFF1E3A8A) : Colors.blue[50],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          localizations.locale == 'hi'
                              ? "हम देख रहे हैं कि आप $_detectedState में हैं। क्या आप भाषा बदलना चाहते हैं?"
                              : "We noticed you are in $_detectedState. Suggested languages:",
                          style: TextStyle(
                            fontSize: 14 * _fontScale, 
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.blue[900]
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _showLocationSuggestion = false),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8.0,
                    children: _suggestedLanguages.map<Widget>((lang) {
                      final code = lang['code'] as String;
                      final name = lang['name'] as String;
                      return ChoiceChip(
                        label: Text(name),
                        selected: localizations.locale == code,
                        onSelected: (selected) {
                          if (selected) {
                            localizations.setLocale(code);
                            setState(() => _showLocationSuggestion = false);
                          }
                        },
                      );
                    }).toList(),
                  )
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Simulated location changing switcher for developers/testers
                Text(localizations.locale == 'hi' ? "लोकेशन सिम्युलेटर: " : "Simulate Location: ", style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _detectedState == "Rajasthan" || _detectedState == "Bihar" || _detectedState == "Punjab" || _detectedState == "Tamil Nadu" 
                      ? _detectedState 
                      : "Rajasthan",
                  items: const [
                    DropdownMenuItem(value: "Rajasthan", child: Text("Jaipur, RJ")),
                    DropdownMenuItem(value: "Bihar", child: Text("Patna, BR")),
                    DropdownMenuItem(value: "Punjab", child: Text("Amritsar, PB")),
                    DropdownMenuItem(value: "Tamil Nadu", child: Text("Chennai, TN")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      _simulateLocationChange(val);
                    }
                  },
                ),
              ],
            ),
          ),

          // 3. Audio Playback Speed Control Slider
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      localizations.locale == 'hi' 
                          ? "आवाज की गति (Speed): ${voiceService.playbackSpeed.toStringAsFixed(1)}x" 
                          : "Voice Speed: ${voiceService.playbackSpeed.toStringAsFixed(1)}x",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: voiceService.playbackSpeed,
                  min: 0.5,
                  max: 1.5,
                  divisions: 5,
                  label: "${voiceService.playbackSpeed}x",
                  onChanged: (val) {
                    voiceService.setPlaybackSpeed(val);
                  },
                )
              ],
            ),
          ),

          // Voice dialogue container
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.green[50],
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 2),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userText.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.account_circle, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _userText,
                              style: TextStyle(
                                fontSize: 18 * _fontScale, 
                                fontStyle: FontStyle.italic
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                    ],
                    
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_assistantText.isNotEmpty) ...[
                      // Dialect/Slang Clarification alert card
                      if (_structuredData != null && _structuredData!['requires_clarification'] == true)
                        Card(
                          color: Colors.amber[100],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.help_center, color: Colors.amber, size: 36),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    localizations.locale == 'hi' 
                                        ? "AI स्पष्टीकरण आवश्यक: पत्तियां सूखने के बारे में और बताएं।" 
                                        : "AI Clarification Requested: Specify leaf drying symptoms.",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.amber[900],
                                      fontSize: 15 * _fontScale
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.eco, color: Colors.green[800]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _assistantText,
                              style: TextStyle(
                                fontSize: 20 * _fontScale, 
                                fontWeight: FontWeight.bold, 
                                height: 1.4
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Treatment cost recommendations cards
                      if (_structuredData != null && _structuredData!['disease'] != 'Unknown') ...[
                        Card(
                          color: isDark ? Colors.black54 : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${localizations.translate('alerts')}: ${_structuredData!['disease']}",
                                  style: TextStyle(
                                    fontSize: 18 * _fontScale, 
                                    fontWeight: FontWeight.bold, 
                                    color: Colors.green[900]
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${localizations.translate('est_cost')}: ₹${_structuredData!['treatment_cost_inr']}",
                                  style: TextStyle(fontSize: 16 * _fontScale),
                                ),
                                Text(
                                  "${localizations.translate('crop_saved')}: ${_structuredData!['crop_saved_percentage']}%",
                                  style: TextStyle(fontSize: 16 * _fontScale),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ] else ...[
                      // Empty state templates (Offline support guide)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: Column(
                            children: [
                              Icon(Icons.spatial_audio_off, size: 64, color: Colors.green[900]),
                              const SizedBox(height: 16),
                              Text(
                                localizations.translate('mic_instruction'),
                                style: TextStyle(fontSize: 18 * _fontScale, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                localizations.translate('voice_hint'),
                                style: TextStyle(fontSize: 16 * _fontScale, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              
                              // Offline agriculture queries quick triggers
                              const Divider(),
                              const SizedBox(height: 12),
                              Text(
                                localizations.locale == 'hi' 
                                    ? "ऑफ़लाइन त्वरित वाक्यांश (Offline triggers):" 
                                    : "Offline Quick Dialect Triggers:",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  ActionChip(
                                    label: const Text("पत्ता सूख रहा है (Drying leaves)"),
                                    onPressed: () {
                                      setState(() {
                                        _userText = "पत्ता सूख रहा है";
                                      });
                                      _processVoiceQuery("पत्ता सूख रहा है", localizations, voiceService);
                                    },
                                  ),
                                  ActionChip(
                                    label: const Text("पत्तियां पीली हैं (Yellow Rust)"),
                                    onPressed: () {
                                      setState(() {
                                        _userText = "पत्तियां पीली हैं";
                                      });
                                      _processVoiceQuery("पत्तियां पीली हैं", localizations, voiceService);
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Large Microphone Button
          Center(
            child: GestureDetector(
              onTap: () => _handleMicPress(voiceService, localizations),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: voiceService.isListening 
                      ? Colors.red.withOpacity(0.15) 
                      : Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: voiceService.isListening ? Colors.red : Colors.green[800],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (voiceService.isListening ? Colors.red : Colors.green).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    voiceService.isListening ? Icons.stop : Icons.mic,
                    size: 56.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            voiceService.isListening 
                ? (localizations.locale == 'hi' ? "सुन रहा हूँ..." : "Listening...") 
                : (localizations.locale == 'hi' ? "माइक चालू करें" : "Tap to Speak"),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
