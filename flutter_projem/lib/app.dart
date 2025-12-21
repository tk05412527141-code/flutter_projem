import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_projem/features/auth/data/auth_repository.dart';


class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          session.when(
            data: (user) => Text(user?.email ?? 'Giriş yapılmadı'),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Hata: $e'),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(sessionControllerProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış yap'),
            ),
          ),
        ],
      ),
    );
  }
}
