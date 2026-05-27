import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService extends ChangeNotifier {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _playbackSpeed = 1.0; // Playback speed scaler (default 1.0x)

  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;
  String get wordsSpoken => _wordsSpoken;
  double get playbackSpeed => _playbackSpeed;

  VoiceService() {
    _initVoiceSystem();
  }

  Future<void> _initVoiceSystem() async {
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    
    try {
      _speechEnabled = await _speech.initialize(
        onError: (val) => debugPrint('STT Error: $val'),
        onStatus: (val) => debugPrint('STT Status: $val'),
      );
    } catch (e) {
      debugPrint("Speech recognition not supported: $e");
      _speechEnabled = false;
    }

    try {
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _updateTtsSpeed();
    } catch (e) {
      debugPrint("TTS Setup error: $e");
    }
  }

  void setPlaybackSpeed(double speed) {
    if (speed >= 0.3 && speed <= 1.5) {
      _playbackSpeed = speed;
      _updateTtsSpeed();
      notifyListeners();
    }
  }

  Future<void> _updateTtsSpeed() async {
    try {
      // In FlutterTts, 1.0 is default fast. 
      // We scale speed so 1.0x plays at comfortable 0.45, 0.5x plays at 0.22, 1.2x plays at 0.55
      double scaledRate = _playbackSpeed * 0.45;
      await _tts.setSpeechRate(scaledRate.clamp(0.1, 1.0));
    } catch (_) {}
  }

  // Start listening
  Future<void> startListening(Function(String) onResult) async {
    if (_speechEnabled) {
      _isListening = true;
      _wordsSpoken = "";
      notifyListeners();
      
      await _speech.listen(
        onResult: (val) {
          _wordsSpoken = val.recognizedWords;
          onResult(_wordsSpoken);
          notifyListeners();
        },
        localeId: 'hi_IN',
      );
    } else {
      // Simulated voice inputs for testing/offline bypass
      _isListening = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
      _wordsSpoken = "मेरी गेहूं की फसल की पत्तियां पीली पड़ रही हैं";
      onResult(_wordsSpoken);
      _isListening = false;
      notifyListeners();
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (_speechEnabled) {
      await _speech.stop();
    }
    _isListening = false;
    notifyListeners();
  }

  // Speak response out loud
  Future<void> speak(String text, String lang) async {
    try {
      await _tts.stop();
      if (lang == 'hi') {
        await _tts.setLanguage('hi-IN');
      } else {
        await _tts.setLanguage('en-US');
      }
      await _tts.speak(text);
    } catch (e) {
      debugPrint("TTS Speech generation error: $e");
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }
}
