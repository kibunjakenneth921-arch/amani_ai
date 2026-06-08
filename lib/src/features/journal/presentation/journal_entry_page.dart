import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/journal_notifier.dart';
import '../../voice/state/voice_notifier.dart';
import '../models/journal_entry_model.dart';

class JournalEntryPage extends ConsumerStatefulWidget {
  final JournalEntry? entry;
  const JournalEntryPage({super.key, this.entry});

  @override
  ConsumerState<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends ConsumerState<JournalEntryPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final userId = ref.read(journalUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated')));
      setState(() => _loading = false);
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    try {
      if (widget.entry == null) {
        await ref.read(journalNotifierProvider.notifier).create(userId, title, content);
      } else {
        final updated = JournalEntry(
          id: widget.entry!.id,
          userId: widget.entry!.userId,
          title: title,
          content: content,
          category: widget.entry!.category,
          createdAt: widget.entry!.createdAt,
          updatedAt: widget.entry!.updatedAt,
        );
        await ref.read(journalNotifierProvider.notifier).update(updated);
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _startVoice() async {
    await ref.read(voiceNotifierProvider.notifier).init();
    await ref.read(voiceNotifierProvider.notifier).startListening((text) {
      _contentController.text = '${_contentController.text}\n$text';
      setState(() {});
    });
  }

  Future<void> _stopVoice() async {
    await ref.read(voiceNotifierProvider.notifier).stopListening();
  }

  Future<void> _generateReflection() async {
    setState(() => _loading = true);
    final prompt = 'Please provide a compassionate reflection and journaling prompts for the following entry:\n\n${_contentController.text}';
    final reflection = await ref.read(journalNotifierProvider.notifier).generateReflection(prompt);
    // show in dialog
    await showDialog(context: context, builder: (_) => AlertDialog(title: const Text('AI Reflection'), content: SingleChildScrollView(child: Text(reflection)), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))]));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final listening = ref.watch(voiceNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 8),
          Expanded(child: TextField(controller: _contentController, decoration: const InputDecoration(labelText: 'Write your thoughts'), maxLines: null, expands: true)),
          Row(children: [
            IconButton(onPressed: listening ? _stopVoice : _startVoice, icon: Icon(listening ? Icons.mic_off : Icons.mic)),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _loading ? null : _generateReflection, child: const Text('AI Reflection')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _loading ? null : _save, child: _loading ? const CircularProgressIndicator() : const Text('Save')),
          ])
        ]),
      ),
    );
  }
}
