class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.imageUrl,
  });
}
