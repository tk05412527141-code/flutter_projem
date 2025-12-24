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
          NavigationDestination(icon: Icon(Icons.checkroom), label: 'Garobum'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Kombinim'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Geçmişim'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profilim'),
        ],
      ),
    );
  }
}
