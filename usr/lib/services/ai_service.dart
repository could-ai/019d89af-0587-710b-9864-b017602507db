import 'dart:async';
import '../models/chat_message.dart';

class AiService {
  // Mock image generation
  Future<String> generateImage({
    required String personImagePath,
    List<String>? characterImagePaths,
    required String prompt,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));
    
    // Return a placeholder image URL
    return 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/800';
  }

  // Mock chat response
  Future<ChatMessage> sendMessage(String message) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple mock logic
    if (message.toLowerCase().contains('edit') || message.toLowerCase().contains('change')) {
      return ChatMessage(
        text: 'I have updated the image based on your request!',
        isUser: false,
        imageUrl: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/800',
      );
    }
    
    return ChatMessage(
      text: 'That sounds great! Do you want me to make any other changes to the characters or the scene?',
      isUser: false,
    );
  }
}
