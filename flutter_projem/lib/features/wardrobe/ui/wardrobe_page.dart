import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/wardrobe_controller.dart';
import '../data/wardrobe_repository.dart';
import 'add_cloth_page.dart';
import 'cloth_detail_page.dart';
import '../../../shared/widgets/cloth_grid_card.dart';

class WardrobePage extends ConsumerWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Center(child: Text('Giriş yapmanız gerekiyor'));
    }

    final asyncItems = ref.watch(wardrobeControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),

        Expanded(
          child: asyncItems.when(
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.checkroom_rounded, size: 40),
                            const SizedBox(height: 10),
                            const Text(
                              'Henüz kıyafet eklenmedi',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Parça Ekle ile dolabını oluşturmaya başla.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AddClothPage()),
                                );
                                // AddClothPage ile eklediyse yenile
                                ref.read(wardrobeControllerProvider.notifier).refresh();
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Parça Ekle'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(2),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final cloth = items[index];

                  return ClothGridCard(
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
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Hata: $e')),
          ),
        ),
      ],
    );
  }
}
