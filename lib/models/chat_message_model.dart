class ChatMessage {
  final String id;
  final String role; // 'user' or 'ai'
  final String text;
  final String time;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.time,
  });
}
