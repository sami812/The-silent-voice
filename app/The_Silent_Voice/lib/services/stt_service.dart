import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:the_silent_voice/components/chat_message.dart';
import 'package:the_silent_voice/services/history_service.dart';

/// ## Speech To Text Service
///
/// --- #### this file contain:
/// all the implementation of service related to converting speech to text
/// 1. Initialize speech recognition engine
/// 2. Start/stop listening to microphone
/// 3. Handle recognized speech and build conversation history
/// ---

class SttService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  ConversationHistoryService? historyService;

  bool _isListening = false;
  bool _isAvailable = false;
  String _currentText = '';
  List<ChatMessage> _conversationHistory = [];

  // Getters
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get currentText => _currentText;
  List<ChatMessage> get conversationHistory => _conversationHistory;

  void setHistoryService(ConversationHistoryService service) {
    historyService = service;
  }
  /// initialize STT - must be called before using
  /// requests microphone permission automatically
  /// and handle if microphone is not working
  Future<bool> initialize() async {
    try {
      _isAvailable = await _speechToText.initialize(
        onError: (error) {
          debugPrint('STT error: ${error.errorMsg}');
          _isListening = false;
          notifyListeners();
        },
        onStatus: (status) {
          debugPrint('STT status: $status');

          // handle when phone automatically stops listening
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );

      notifyListeners();
      return _isAvailable;
    } catch (e) {
      debugPrint('STT initialization error: $e');
      _isAvailable = false;
      notifyListeners();
      return false;
    }
  }

  /// Start listening to microphone
  /// Start listening
  Future<void> startListening() async {
    if (!_isAvailable) {
      final initialized = await initialize();
      if (!initialized) {
        debugPrint('Cannot start listening - STT not available');
        return;
      }
    }

    if (_isListening) return;

    _isListening = true;
    _currentText = '';
    notifyListeners();

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  /// Stop listening to microphone
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  /// Toggle listening on/off (for play/pause button)
  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Callback when speech is recognized
  void _onSpeechResult(SpeechRecognitionResult result) {
    _currentText = result.recognizedWords;

    // When user finishes speaking, add to history
    if (result.finalResult && _currentText.isNotEmpty) {
      final msg = ChatMessage(
        text: _currentText,
        sender: MessageSender.other, 
        time: DateTime.now(),
      );
      _conversationHistory.add(msg);
      historyService?.addMessage(msg);
      _currentText = '';
    }
    notifyListeners(); // update UI with new text
  }

  void addMyMessage(ChatMessage message) {
  conversationHistory.add(message);
  notifyListeners();
}

  /// Clear all conversation data
  void clearHistory() {
    _conversationHistory.clear();
    _currentText = '';
    notifyListeners();
  }

  /// Get the full conversation as a single string
  String getFullConversation() {
    return _conversationHistory.map((m) => '${m.sender.name}: ${m.text}').join('\n');
  }

  /// Check if STT is currently active
  bool get isActive => _speechToText.isListening;

  /// Check if device has speech recognition available
  bool get hasPermission => _isAvailable;

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }
}
