import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/wardrobe_repository.dart';

final wardrobeControllerProvider =
    AsyncNotifierProvider<WardrobeController, List<Cloth>>(WardrobeController.new);

class WardrobeController extends AsyncNotifier<List<Cloth>> {
  @override
  Future<List<Cloth>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final repo = ref.read(wardrobeRepositoryProvider);
    return repo.getClothes(user.id);
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    final repo = ref.read(wardrobeRepositoryProvider);
    state = AsyncData(await repo.getClothes(user.id));
  }

  Future<void> addFromPickedImage({
    required String pickedPath,
    String name = "Yeni Parça",
    ClothCategory category = ClothCategory.top,
    Season season = Season.all,
    String? color,
    String? tags,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final wardrobeDir = Directory(p.join(dir.path, 'wardrobe'));
    if (!await wardrobeDir.exists()) await wardrobeDir.create(recursive: true);

    final ext = p.extension(pickedPath).isEmpty ? '.jpg' : p.extension(pickedPath);
    final newPath = p.join(wardrobeDir.path, '${DateTime.now().millisecondsSinceEpoch}$ext');
    await File(pickedPath).copy(newPath);

    final repo = ref.read(wardrobeRepositoryProvider);
    final cloth = await repo.addCloth(
      userId: user.id,
      name: name,
      category: category,
      season: season,
      color: color,
      tags: tags,
      imagePath: newPath,
    );

    final current = state.valueOrNull ?? [];
    state = AsyncData([cloth, ...current]);
  }
}
