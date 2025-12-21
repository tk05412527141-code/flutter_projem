import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/data/auth_repository.dart';
import 'features/auth/ui/login_page.dart';
import 'features/auth/ui/register_page.dart';
import 'features/wardrobe/ui/wardrobe_page.dart';
import 'features/outfit/ui/outfit_page.dart';
import 'features/outfit/ui/history_page.dart';
import 'features/profile/ui/profile_page.dart';
import 'shared/widgets/app_scaffold.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Kombin Üretici',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const SplashPage(),
      onGenerateRoute: onGenerateRoute,
    );
  }
}

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    return session.when(
      data: (user) {
        if (user == null) return const LoginPage();
        return const HomeShell();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Hata: $e')),
      ),
    );
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const WardrobePage(),
      const OutfitPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    return AppScaffold(
      currentIndex: _index,
      onIndexChanged: (i) => setState(() => _index = i),
      body: pages[_index],
    );
  }
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  if (settings.name == RegisterPage.routeName) {
    return MaterialPageRoute(builder: (_) => const RegisterPage());
  }
  return null;
}
