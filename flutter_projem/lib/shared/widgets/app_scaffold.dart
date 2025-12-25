import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.body,
    this.fab,
    this.title,
    this.actions,
  });

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget body;

  // Profesyonel ekler:
  final Widget? fab;
  final String? title;
  final List<Widget>? actions;

  String _defaultTitle(int index) => switch (index) {
        0 => 'Dolabım',
        1 => 'Kombinler',
        2 => 'Geçmiş',
        _ => 'Profil',
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? _defaultTitle(currentIndex)),
        actions: actions ??
            [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Ara',
              ),
              const SizedBox(width: 6),
            ],
      ),

      // Body profesyonel görünüm: safe area + standart padding
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: body,
        ),
      ),

      floatingActionButton: fab,

      // NavigationBar'ı biraz “premium” hissettir:
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(
            // ignore: deprecated_member_use
            top: BorderSide(color: scheme.outlineVariant.withOpacity(0.6)),
          ),
        ),
        child: NavigationBar(
          height: 72,
          selectedIndex: currentIndex,
          onDestinationSelected: onIndexChanged,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.checkroom_rounded), label: 'Dolap'),
            NavigationDestination(icon: Icon(Icons.auto_awesome_rounded), label: 'Kombin'),
            NavigationDestination(icon: Icon(Icons.history_rounded), label: 'Geçmiş'),
            NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
