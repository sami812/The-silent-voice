import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// ## Text To Speech Service
///
/// --- #### this file contain:
///
/// 1. Simple service to speak text out loud
/// ---

class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  // Getter
  bool get isSpeaking => _isSpeaking;

  TtsService() {
    _initialize();
  }

  /// Initialize TTS with basic settings
  Future<void> _initialize() async {
    try {
      // Basic settings
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5); // Normal speed
      await _tts.setVolume(1.0); // Full volume
      await _tts.setPitch(1.0); // Normal pitch

      // Event handlers
      _tts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
        debugPrint('TTS: Started');
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
        debugPrint('TTS: Completed');
      });

      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        notifyListeners();
        debugPrint('TTS Error: $msg');
      });

      debugPrint('TTS: Initialized');
    } catch (e) {
      debugPrint('TTS Init Error: $e');
    }
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    // Stop current speech if speaking
    if (_isSpeaking) {
      await _tts.stop();
      await Future.delayed(Duration(milliseconds: 100));
    }

    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS Speak Error: $e');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
