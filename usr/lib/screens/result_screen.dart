import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

class ResultScreen extends StatefulWidget {
  final String personImagePath;
  final List<String> characterImagePaths;
  final String prompt;

  const ResultScreen({
    super.key,
    required this.personImagePath,
    required this.characterImagePaths,
    required this.prompt,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _chatController = TextEditingController();
  final List<ChatMessage> _messages = [];
  
  String? _currentImageUrl;
  bool _isGenerating = true;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _generateInitialImage();
  }

  Future<void> _generateInitialImage() async {
    try {
      final imageUrl = await _aiService.generateImage(
        personImagePath: widget.personImagePath,
        characterImagePaths: widget.characterImagePaths,
        prompt: widget.prompt,
      );
      
      if (mounted) {
        setState(() {
          _currentImageUrl = imageUrl;
          _isGenerating = false;
          _messages.add(
            ChatMessage(
              text: 'Here is your generated scene! Let me know if you want to change anything.',
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate image.')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isSendingMessage = true;
    });
    
    _chatController.clear();

    try {
      final response = await _aiService.sendMessage(text);
      
      if (mounted) {
        setState(() {
          _messages.add(response);
          if (response.imageUrl != null) {
            _currentImageUrl = response.imageUrl;
          }
          _isSendingMessage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Scene'),
      ),
      body: Column(
        children: [
          // Image Display Area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.black12,
              child: _isGenerating
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Generating your scene...'),
                        ],
                      ),
                    )
                  : _currentImageUrl != null
                      ? Image.network(
                          _currentImageUrl!,
                          fit: BoxFit.contain,
                        )
                      : const Center(child: Text('No image generated')),
            ),
          ),
          
          // Chat Area
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return Align(
                          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: msg.isUser ? Colors.blue : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isUser ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_isSendingMessage)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: const InputDecoration(
                              hintText: 'Ask for edits or chat with AI...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(24)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: _isSendingMessage ? null : _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
