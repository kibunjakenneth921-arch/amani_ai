import 'package:flutter/material.dart';
import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Theme.of(context).colorScheme.primary : Colors.grey.shade900;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final txtColor = isMe ? Colors.white : Colors.white;
    return Column(
      crossAxisAlignment: align,
      children: [
        Semantics(
          label: isMe ? 'User message' : 'Assistant message',
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Text(message.text, style: TextStyle(color: txtColor, fontSize: 16.0)),
          ),
        ),
      ],
    );
  }
}
