import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _routes = ['/home', '/chat', '/journal', '/profile', '/goals', '/check-in'];

  void _onSelect(int idx) {
    setState(() => _index = idx);
    GoRouter.of(context).go(_routes[idx]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 700;
      if (isWide) {
        return Scaffold(
          body: Row(children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.chat_bubble), label: Text('Chat')),
                NavigationRailDestination(icon: Icon(Icons.book), label: Text('Journal')),
                NavigationRailDestination(icon: Icon(Icons.flag), label: Text('Goals')),
                NavigationRailDestination(icon: Icon(Icons.check_circle), label: Text('Check-in')),
                NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: Center(child: Text('Loading...'))),
          ]),
        );
      }

      return Scaffold(
        body: Center(child: Text('Loading...')),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: _onSelect,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
    });
  }
}
