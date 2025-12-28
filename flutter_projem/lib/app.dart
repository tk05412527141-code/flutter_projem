import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'core/constants/app_spacing.dart';
import 'core/constants/app_strings.dart';
import 'core/error/app_failure.dart';
import 'core/models/cloth.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/outfit/presentation/pages/history_page.dart';
import 'features/outfit/presentation/pages/outfit_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/wardrobe/presentation/controllers/wardrobe_controller.dart';
import 'features/wardrobe/presentation/pages/wardrobe_page.dart';

import 'shared/widgets/app_loading_state.dart';
import 'shared/widgets/app_scaffold.dart';

// Bu provider sende başka dosyada olabilir.
// Aynı isimle zaten var dediğin için olduğu gibi bıraktım.
import 'features/auth/data/auth_repository.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: AppTheme.lightTheme(),
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
      loading: () => const Scaffold(body: AppLoadingState()),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Hata: $error')),
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
    final pages = <Widget>[
      const WardrobePage(),
      const OutfitPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    return AppScaffold(
      currentIndex: _index,
      onIndexChanged: (i) => setState(() => _index = i),

      // ✅ FAB sadece Dolap (index 0) ekranında görünsün
      fab: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final pickedPath = await showModalBottomSheet<String>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (_) => const _AddItemSheet(),
                );

                if (!mounted) return;

                if (pickedPath == null || pickedPath.isEmpty) return;

                try {
                  await ref
                      .read(wardrobeControllerProvider.notifier)
                      .addFromPickedImage(
                        pickedPath: pickedPath,
                        name: 'Yeni Parça',
                        category: ClothCategory.top,
                        season: Season.all,
                      );

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dolaba eklendi ✅')),
                  );
                } on AppFailure catch (failure) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(failure.message)),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Beklenmeyen hata: $e')),
                  );
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Parça Ekle'),
            )
          : null,

      // ✅ Sayfa geçişlerini yumuşat
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: pages[_index],
        ),
      ),
    );
  }
}

class _AddItemSheet extends StatelessWidget {
  const _AddItemSheet();

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();

    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (file == null) return; // kullanıcı vazgeçti
    if (!context.mounted) return;

    // Seçilen path'i HomeShell'e geri döndür
    Navigator.pop(context, file.path);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Parça Ekle',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),

          FilledButton.icon(
            onPressed: () => _pick(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Galeriden Seç'),
          ),
          const SizedBox(height: AppSpacing.sm),

          OutlinedButton.icon(
            onPressed: () => _pick(context, ImageSource.camera),
            icon: const Icon(Icons.photo_camera_rounded),
            label: const Text('Kamera ile Çek'),
          ),

          const SizedBox(height: AppSpacing.xs),
          Text(
            'Fotoğraf seçince otomatik olarak dolaba ekleme adımına geçeceğiz.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  if (settings.name == RegisterPage.routeName) {
    return MaterialPageRoute(builder: (_) => const RegisterPage());
  }
  return null;
}
