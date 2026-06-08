import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/checkin_notifier.dart';

class CheckInPage extends ConsumerStatefulWidget {
  const CheckInPage({super.key});

  @override
  ConsumerState<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends ConsumerState<CheckInPage> {
  int _mood = 5;
  int _energy = 5;
  int _stress = 5;
  final _gratitudeController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _gratitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(checkInNotifierProvider.notifier).addCheckIn(mood: _mood, energy: _energy, stress: _stress, gratitude: _gratitudeController.text.trim().isEmpty ? null : _gratitudeController.text.trim(), notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim());
    await ref.read(checkInNotifierProvider.notifier).loadRecent();
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check-in saved')));
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(checkInNotifierProvider);
    final weekly = ref.read(checkInNotifierProvider.notifier).weeklySummary();
    final monthly = ref.read(checkInNotifierProvider.notifier).monthlySummary();

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Check-in')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Text('How are you feeling today?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _slider('Mood', _mood, (v) => setState(() => _mood = v)),
          _slider('Energy', _energy, (v) => setState(() => _energy = v)),
          _slider('Stress', _stress, (v) => setState(() => _stress = v)),
          TextField(controller: _gratitudeController, decoration: const InputDecoration(labelText: 'Gratitude (one thing)')),
          const SizedBox(height: 8),
          Expanded(child: TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes'), maxLines: null, expands: true)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: _saving ? null : _save, child: _saving ? const CircularProgressIndicator() : const Text('Save Check-in'))),
          ]),
          const SizedBox(height: 12),
          _summaryCard('Weekly Averages', weekly),
          const SizedBox(height: 8),
          _summaryCard('Monthly Averages', monthly),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];
                return ListTile(
                  title: Text('Mood ${e.mood} • Energy ${e.energy} • Stress ${e.stress}'),
                  subtitle: Text(e.createdAt.toDate().toLocal().toString()),
                );
              },
            ),
          )
        ]),
      ),
    );
  }

  Widget _slider(String label, int value, ValueChanged<int> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label: $value'),
      Slider(value: value.toDouble(), min: 1, max: 10, divisions: 9, label: value.toString(), onChanged: (v) => onChanged(v.toInt())),
    ]);
  }

  Widget _summaryCard(String title, Map<String, double> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Mood: ${data['mood']?.toStringAsFixed(1) ?? '0'}'),
          Text('Energy: ${data['energy']?.toStringAsFixed(1) ?? '0'}'),
          Text('Stress: ${data['stress']?.toStringAsFixed(1) ?? '0'}'),
        ]),
      ),
    );
  }
}
