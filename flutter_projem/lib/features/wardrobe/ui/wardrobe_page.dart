import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../data/wardrobe_repository.dart';
import 'add_cloth_page.dart';
import 'cloth_detail_page.dart';
import '../../../shared/widgets/cloth_card.dart';

class WardrobePage extends ConsumerWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final repo = ref.watch(wardrobeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gardırop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddClothPage()),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Giriş yapmanız gerekiyor'))
          : FutureBuilder(
              future: repo.getClothes(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('Henüz kıyafet eklenmedi'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final cloth = items[index];
                    return ClothCard(
                      cloth: cloth,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ClothDetailPage(cloth: cloth),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: items.length,
                );
              },
            ),
    );
  }
}