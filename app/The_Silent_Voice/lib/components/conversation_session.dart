import 'package:the_silent_voice/components/chat_message.dart';

class ConversationSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final List<ChatMessage> messages;
  final Duration duration;
  final String personName;

  ConversationSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.messages,
    required this.duration,
    this.personName = '',
  });

  List<String> get transcript =>
      messages.where((m) => m.sender == MessageSender.other).map((m) => m.text).toList();

  List<String> get myMessages =>
      messages.where((m) => m.sender == MessageSender.me).map((m) => m.text).toList();

  List<String> get signMessages =>
      messages.where((m) => m.sender == MessageSender.me).map((m) => m.text).toList();

  List<String> get speechMessages =>
      messages.where((m) => m.sender == MessageSender.other).map((m) => m.text).toList();
  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'messages': messages.map((m) => m.toJson()).toList(),
    'duration': duration.inSeconds,
    'personName': personName,
  };

  factory ConversationSession.fromJson(Map<String, dynamic> json) {
    return ConversationSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      duration: Duration(seconds: json['duration'] as int),
      personName: json['personName'] as String? ?? '',
      messages: (json['messages'] as List? ?? [])
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  ConversationSession copyWith({String? personName}) {
    return ConversationSession(
      id: id,
      startTime: startTime,
      endTime: endTime,
      messages: messages,
      duration: duration,
      personName: personName ?? this.personName,
    );
  }
}