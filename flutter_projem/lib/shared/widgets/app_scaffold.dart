import 'package:flutter/material.dart';


class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.body,
  });

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget body; // ✅ Object/dynamic değil, Widget olmalı

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body, // ✅ burada Widget beklenir
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onIndexChanged,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checkroom), label: 'Gardırop'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Kombin'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Geçmiş'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
