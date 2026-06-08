import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/goals_notifier.dart';
import 'goal_detail_page.dart';

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  @override
  void initState() {
    super.initState();
    ref.read(goalsNotifierProvider.notifier).loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: ListView.separated(
        itemCount: goals.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final g = goals[index];
          return ListTile(
            title: Text(g.title),
            subtitle: Text('${g.progress.toStringAsFixed(0)}% • ${g.milestones.where((m) => m.completed).length}/${g.milestones.length} milestones'),
            trailing: CircularProgressIndicator(value: g.progress / 100.0),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GoalDetailPage(goal: g))),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GoalDetailPage())), child: const Icon(Icons.add)),
    );
  }
}
