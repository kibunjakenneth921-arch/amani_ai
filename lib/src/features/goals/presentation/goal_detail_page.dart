import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_model.dart';
import '../state/goals_notifier.dart';
import 'package:uuid/uuid.dart';

class GoalDetailPage extends ConsumerStatefulWidget {
  final Goal? goal;
  const GoalDetailPage({super.key, this.goal});

  @override
  ConsumerState<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends ConsumerState<GoalDetailPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  double _progress = 0.0;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _descController.text = widget.goal!.description;
      _progress = widget.goal!.progress;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.goal == null) {
      await ref.read(goalsNotifierProvider.notifier).createGoal(_titleController.text.trim(), description: _descController.text.trim());
    } else {
      final updated = Goal(
        id: widget.goal!.id,
        userId: widget.goal!.userId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        targetDate: widget.goal!.targetDate,
        progress: _progress,
        milestones: widget.goal!.milestones,
        habits: widget.goal!.habits,
        createdAt: widget.goal!.createdAt,
        updatedAt: widget.goal!.updatedAt,
      );
      await ref.read(goalsNotifierProvider.notifier).updateGoal(updated);
    }
    Navigator.of(context).pop();
  }

  Future<void> _addMilestone() async {
    final id = _uuid.v4();
    final title = await _promptText('Milestone title');
    if (title == null || title.isEmpty) return;
    final m = Milestone(id: id, title: title);
    if (widget.goal != null) await ref.read(goalsNotifierProvider.notifier).addMilestone(widget.goal!.id, m);
  }

  Future<void> _addHabit() async {
    final id = _uuid.v4();
    final name = await _promptText('Habit name');
    if (name == null || name.isEmpty) return;
    final h = Habit(id: id, name: name, streak: 0);
    if (widget.goal != null) await ref.read(goalsNotifierProvider.notifier).addHabit(widget.goal!.id, h);
  }

  Future<String?> _promptText(String label) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool?>(context: context, builder: (_) => AlertDialog(title: Text(label), content: TextField(controller: ctrl), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Add'))]));
    if (ok != true) return null;
    return ctrl.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    return Scaffold(
      appBar: AppBar(title: Text(goal == null ? 'New Goal' : goal.title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 8),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')), 
          const SizedBox(height: 8),
          Row(children: [Expanded(child: Slider(value: _progress, min: 0, max: 100, divisions: 100, label: '${_progress.toStringAsFixed(0)}%', onChanged: (v) => setState(() => _progress = v))), Text('${_progress.toStringAsFixed(0)}%')]),
          const SizedBox(height: 8),
          if (goal != null) Expanded(child: ListView(children: [
            const Text('Milestones', style: TextStyle(fontWeight: FontWeight.bold)),
            ...goal.milestones.map((m) => ListTile(title: Text(m.title), trailing: m.completed ? const Icon(Icons.check) : TextButton(onPressed: () => ref.read(goalsNotifierProvider.notifier).completeMilestone(goal.id, m.id), child: const Text('Complete')))),
            const SizedBox(height: 8),
            const Text('Habits', style: TextStyle(fontWeight: FontWeight.bold)),
            ...goal.habits.map((h) => ListTile(title: Text(h.name), subtitle: Text('Streak: ${h.streak}'), trailing: TextButton(onPressed: () => ref.read(goalsNotifierProvider.notifier).incrementHabitStreak(goal.id, h.id), child: const Text('+1')))),
          ])),
          Row(children: [TextButton(onPressed: _addMilestone, child: const Text('Add milestone')), const SizedBox(width: 8), TextButton(onPressed: _addHabit, child: const Text('Add habit'))]),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ]),
      ),
    );
  }
}
