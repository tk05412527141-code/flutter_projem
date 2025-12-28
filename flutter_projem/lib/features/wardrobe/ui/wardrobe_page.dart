import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/cloth_grid_card.dart';
import '../controller/wardrobe_controller.dart';
import '../data/wardrobe_repository.dart';
import 'add_cloth_page.dart';
import 'cloth_detail_page.dart';

/// Seçili kombin (liste index'leri) burada tutulur.
/// Not: Şimdilik en basit hali: dolaptan 3 parça rastgele seçiyoruz.
final outfitSelectionProvider = StateProvider<List<int>?>((ref) => null);

class WardrobePage extends ConsumerWidget {
  const WardrobePage({super.key});

  List<int> _pickRandomDistinctIndexes(int itemCount, {int pick = 3}) {
    if (itemCount <= 0) return const [];
    final rng = Random();
    final set = <int>{};

    // itemCount 3'ten azsa hepsini seç
    final target = min(pick, itemCount);

    while (set.length < target) {
      set.add(rng.nextInt(itemCount));
    }
    return set.toList();
  }

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
              // ÜST: Kombin alanı (items boş olsa da buton kısmı görünebilir diye burada yönetiyoruz)
              Widget buildTopArea() {
                if (items.isEmpty) return const SizedBox.shrink();

                final selectedIdxs = ref.watch(outfitSelectionProvider);
                final hasSelection = selectedIdxs != null && selectedIdxs.isNotEmpty;

                final selectedClothes = hasSelection
                    ? selectedIdxs
                        .where((i) => i >= 0 && i < items.length)
                        .map((i) => items[i])
                        .toList()
                    : <dynamic>[];

                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    final idxs = _pickRandomDistinctIndexes(items.length, pick: 3);
                                    ref.read(outfitSelectionProvider.notifier).state = idxs;
                                  },
                                  icon: const Icon(Icons.auto_awesome),
                                  label: Text(hasSelection ? 'Kombini Yenile' : 'Kombin Üret'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Kombini temizle',
                                onPressed: () {
                                  ref.read(outfitSelectionProvider.notifier).state = null;
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),

                          if (hasSelection) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Önerilen Kombin',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 10),

                            // Seçilen parçaları yatay gösterelim
                            SizedBox(
                              height: 210,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedClothes.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final cloth = selectedClothes[index];

                                  return SizedBox(
                                    width: 160,
                                    child: ClothGridCard(
                                      cloth: cloth,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ClothDetailPage(cloth: cloth),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 8),
                            // Mini aksiyonlar
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // "Beğenmedim" => tekrar üret
                                      final idxs = _pickRandomDistinctIndexes(items.length, pick: 3);
                                      ref.read(outfitSelectionProvider.notifier).state = idxs;
                                    },
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Beğenmedim, yenile'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'İpucu: Bir sonraki adımda bunu kategori/renk/mevsim kurallarıyla “akıllı” hale getireceğiz.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }

              // BOŞ DOLAP EKRANI
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

              // DOLAP DOLU: üstte kombin kartı + altta grid
              return Column(
                children: [
                  buildTopArea(),
                  Expanded(
                    child: GridView.builder(
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
                    ),
                  ),
                ],
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
