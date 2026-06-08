import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/journal_notifier.dart';
import 'journal_entry_page.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(journalNotifierProvider.notifier).loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(journalNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JournalEntryPage())),
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search entries...'),
            onChanged: (v) => ref.read(journalNotifierProvider.notifier).search(v),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final e = entries[index];
              return ListTile(
                title: Text(e.title.isEmpty ? _preview(e.content) : e.title),
                subtitle: Text(e.createdAt.toDate().toLocal().toString()),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => JournalEntryPage(entry: e))),
              );
            },
          ),
        )
      ]),
    );
  }

  String _preview(String content) {
    if (content.length <= 80) return content;
    return '${content.substring(0, 80)}...';
  }
}
