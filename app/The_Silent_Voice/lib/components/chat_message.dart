enum MessageSender {me, other}

class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'sender': sender.name,
    'time': time.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'],
    sender: json['sender'] == 'me' ? MessageSender.me : MessageSender.other,
    time: DateTime.parse(json['time']),
  );
}