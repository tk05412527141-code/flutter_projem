import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_projem/features/auth/data/auth_repository.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: session.when(
          data: (user) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.email ?? 'Giriş yapılmadı',
                style: const TextStyle(fontSize: 18),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(sessionControllerProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Çıkış yap'),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
        ),
      ),
    );
  }
}
