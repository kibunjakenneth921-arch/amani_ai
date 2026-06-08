import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amani AI — Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Welcome to Amani AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('This is the home dashboard. Place quick summaries, today’s check-in, and shortcuts here.'),
        ]),
      ),
    );
  }
}
