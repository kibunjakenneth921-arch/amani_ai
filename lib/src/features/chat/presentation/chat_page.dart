import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/chat_notifier.dart';
import '../../auth/state/auth_notifier.dart';
import '../models/message_model.dart';
import 'widgets/message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  String _conversationId = 'default';

  @override
  void initState() {
    super.initState();
    // For demo create or reuse a default conversation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref.read(chatNotifierProvider.notifier).sendMessage(_conversationId, text);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatNotifierProvider);
    final user = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Listener')),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final m = messages[index];
              return MessageBubble(message: m, isMe: m.role == MessageRole.user);
            },
          ),
        ),
        SafeArea(
          child: Row(children: [
            Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Talk to Amani'))),
            const SizedBox(width: 8),
            _AnimatedSendButton(onPressed: _send),
          ]),
        )
      ]),
    );
  }
}

class _AnimatedSendButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedSendButton({required this.onPressed});

  @override
  State<_AnimatedSendButton> createState() => _AnimatedSendButtonState();
}

class _AnimatedSendButtonState extends State<_AnimatedSendButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTap() async {
    setState(() => _scale = 0.9);
    await Future.delayed(const Duration(milliseconds: 80));
    setState(() => _scale = 1.0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      child: IconButton(onPressed: _onTap, icon: const Icon(Icons.send), tooltip: 'Send message'),
    );
  }
}

