import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading_state.dart';
import '../../../wardrobe/data/wardrobe_repository.dart';
import '../providers/outfit_history_provider.dart';
import 'outfit_detail_page.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final wardrobeRepo = ref.watch(wardrobeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kombin Geçmişi')),
      body: user == null
          ? const Center(child: Text('Giriş yapmanız gerekiyor'))
          : ref.watch(outfitHistoryProvider(user.id)).when(
                data: (result) {
                  if (!result.isSuccess) {
                    return AppErrorState(
                      title: 'Kombin geçmişi yüklenemedi',
                      message: result.failure?.message ?? AppStrings.genericError,
                      onRetry: () => ref.refresh(outfitHistoryProvider(user.id)),
                    );
                  }

                  final outfits = result.data ?? [];
                  if (outfits.isEmpty) {
                    return const AppEmptyState(
                      title: 'Henüz kombin oluşturulmadı',
                      message: 'Kombin oluşturduğunda burada görünecek.',
                      icon: Icons.auto_awesome_rounded,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemBuilder: (context, index) {
                      final outfit = outfits[index];
                      final date = DateTime.fromMillisecondsSinceEpoch(outfit.createdAt);
                      return ListTile(
                        title: Text('Kombin ${index + 1}'),
                        subtitle: Text(
                          '${date.day}.${date.month}.${date.year} '
                          '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final topResult =
                              await wardrobeRepo.getClothById(outfit.topClothId);
                          final bottomResult =
                              await wardrobeRepo.getClothById(outfit.bottomClothId);
                          final shoesResult =
                              await wardrobeRepo.getClothById(outfit.shoeClothId);
                          if (!topResult.isSuccess ||
                              !bottomResult.isSuccess ||
                              !shoesResult.isSuccess) {
                            return;
                          }
                          final top = topResult.data;
                          final bottom = bottomResult.data;
                          final shoes = shoesResult.data;
                          if (top == null || bottom == null || shoes == null) return;
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
                loading: () => const AppLoadingState(),
                error: (error, _) => AppErrorState(
                  title: 'Kombin geçmişi yüklenemedi',
                  message: error.toString(),
                  onRetry: () => ref.refresh(outfitHistoryProvider(user.id)),
                ),
              ),
    );
  }
}