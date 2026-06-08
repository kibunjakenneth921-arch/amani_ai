import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final _firestore = FirebaseFirestore.instance;
  int journalCount = 0;
  int conversationCount = 0;
  double avgMood = 0.0;
  double avgGoalProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final journals = await _firestore.collection('journals').get();
    final convs = await _firestore.collection('conversations').get();
    final moods = await _firestore.collection('moods').get();
    final goals = await _firestore.collection('goals').get();

    setState(() {
      journalCount = journals.size;
      conversationCount = convs.size;
      if (moods.size > 0) {
        final moodsList = moods.docs.map((d) => (d.data()['mood'] as num).toDouble()).toList();
        avgMood = moodsList.reduce((a, b) => a + b) / moodsList.length;
      }
      if (goals.size > 0) {
        final progressList = goals.docs.map((d) => (d.data()['progress'] as num?)?.toDouble() ?? 0.0).toList();
        avgGoalProgress = progressList.reduce((a, b) => a + b) / progressList.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Journal entries: $journalCount'),
          const SizedBox(height: 8),
          Text('Conversations: $conversationCount'),
          const SizedBox(height: 8),
          Text('Average Mood: ${avgMood.toStringAsFixed(1)}'),
          const SizedBox(height: 8),
          Text('Average Goal Progress: ${avgGoalProgress.toStringAsFixed(1)}%'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadMetrics, child: const Text('Refresh')),
        ]),
      ),
    );
  }
}
