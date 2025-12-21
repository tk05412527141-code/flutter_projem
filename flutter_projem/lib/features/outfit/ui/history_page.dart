import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../wardrobe/data/wardrobe_repository.dart';
import '../data/outfit_repository.dart';
import 'outfit_detail_page.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final repo = ref.watch(outfitRepositoryProvider);
    final wardrobeRepo = ref.watch(wardrobeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kombin Geçmişi')),
      body: user == null
          ? const Center(child: Text('Giriş yapmanız gerekiyor'))
          : FutureBuilder(
              future: repo.getOutfits(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final outfits = snapshot.data ?? [];
                if (outfits.isEmpty) {
                  return const Center(child: Text('Henüz kombin oluşturulmadı'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final outfit = outfits[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(
                        outfit.createdAt);
                    return ListTile(
                      title: Text('Kombin ${index + 1}'),
                      subtitle: Text(
                          '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final top =
                            await wardrobeRepo.getClothById(outfit.topClothId);
                        final bottom = await wardrobeRepo
                            .getClothById(outfit.bottomClothId);
                        final shoes = await wardrobeRepo
                            .getClothById(outfit.shoeClothId);
                        if (top == null || bottom == null || shoes == null) {
                          return;
                        }
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OutfitDetailPage(
                                top: top,
                                bottom: bottom,
                                shoes: shoes,
                                createdAt: outfit.createdAt,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: outfits.length,
                );
              },
            ),
    );
  }
}