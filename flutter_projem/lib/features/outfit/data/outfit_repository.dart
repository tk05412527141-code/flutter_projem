import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../wardrobe/data/wardrobe_repository.dart';
import '../../auth/data/auth_repository.dart';

class Outfit {
  Outfit({
    required this.id,
    required this.userId,
    required this.topClothId,
    required this.bottomClothId,
    required this.shoeClothId,
    required this.seasonUsed,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String topClothId;
  final String bottomClothId;
  final String shoeClothId;
  final String seasonUsed;
  final int createdAt;

  factory Outfit.fromMap(Map<String, Object?> map) {
    return Outfit(
      id: map['id'] as String,
      userId: map['userId'] as String,
      topClothId: map['topClothId'] as String,
      bottomClothId: map['bottomClothId'] as String,
      shoeClothId: map['shoeClothId'] as String,
      seasonUsed: map['seasonUsed'] as String,
      createdAt: map['createdAt'] as int,
    );
  }
}

class OutfitWithClothes {
  OutfitWithClothes({
    required this.outfit,
    required this.top,
    required this.bottom,
    required this.shoes,
  });

  final Outfit outfit;
  final Cloth top;
  final Cloth bottom;
  final Cloth shoes;
}

final outfitRepositoryProvider = Provider<OutfitRepository>((ref) {
  return OutfitRepository(database: AppDatabase.instance);
});

class OutfitRepository {
  OutfitRepository({required this.database});

  final AppDatabase database;

  Future<Outfit> saveOutfit({
    required String userId,
    required Cloth top,
    required Cloth bottom,
    required Cloth shoes,
    required String seasonUsed,
  }) async {
    final db = await database.database;
    final outfit = Outfit(
      id: const Uuid().v4(),
      userId: userId,
      topClothId: top.id,
      bottomClothId: bottom.id,
      shoeClothId: shoes.id,
      seasonUsed: seasonUsed,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert('outfits', {
      'id': outfit.id,
      'userId': outfit.userId,
      'topClothId': outfit.topClothId,
      'bottomClothId': outfit.bottomClothId,
      'shoeClothId': outfit.shoeClothId,
      'seasonUsed': outfit.seasonUsed,
      'createdAt': outfit.createdAt,
    });
    return outfit;
  }

  Future<List<Outfit>> getOutfits(String userId) async {
    final db = await database.database;
    final rows = await db.query(
      'outfits',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(Outfit.fromMap).toList();
  }

  Future<OutfitWithClothes?> getOutfitWithClothes(String id) async {
    final db = await database.database;
    final rows =
        await db.query('outfits', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    final outfit = Outfit.fromMap(rows.first);

    final topRow = await db.query('clothes',
        where: 'id = ?', whereArgs: [outfit.topClothId], limit: 1);
    final bottomRow = await db.query('clothes',
        where: 'id = ?', whereArgs: [outfit.bottomClothId], limit: 1);
    final shoeRow = await db.query('clothes',
        where: 'id = ?', whereArgs: [outfit.shoeClothId], limit: 1);
    if (topRow.isEmpty || bottomRow.isEmpty || shoeRow.isEmpty) return null;

    return OutfitWithClothes(
      outfit: outfit,
      top: Cloth.fromMap(topRow.first),
      bottom: Cloth.fromMap(bottomRow.first),
      shoes: Cloth.fromMap(shoeRow.first),
    );
  }
}