import 'package:flutter_projem/features/outfit/data/outfit_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/error/app_failure.dart';
import '../../../core/models/cloth.dart';
import 'outfit_repository.dart' show Result;

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

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'userId': userId,
      'topClothId': topClothId,
      'bottomClothId': bottomClothId,
      'shoeClothId': shoeClothId,
      'seasonUsed': seasonUsed,
      'createdAt': createdAt,
    };
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
  
  get Result => null;

  Future<Result<Outfit>> saveOutfit({
    required String userId,
    required Cloth top,
    required Cloth bottom,
    required Cloth shoes,
    required String seasonUsed,
  }) async {
    try {
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

      await db.insert('outfits', outfit.toMap());
      return Result.success(outfit);
    } catch (error, stackTrace) {
      return Result.error(
        AppFailure(
          message: 'Kombin kaydedilemedi.',
          exception: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<List<Outfit>>> getOutfits(String userId) async {
    try {
      final db = await database.database;
      final rows = await db.query(
        'outfits',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
      return Result.success(rows.map(Outfit.fromMap).toList());
    } catch (error, stackTrace) {
      return Result.error(
        AppFailure(
          message: 'Kombin geçmişi alınamadı.',
          exception: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Result<OutfitWithClothes?>> getOutfitWithClothes(String id) async {
    try {
      final db = await database.database;

      final outfitRows = await db.query(
        'outfits',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (outfitRows.isEmpty) return Result.success(null);

      final outfit = Outfit.fromMap(outfitRows.first);

      final topRow = await db.query(
        'clothes',
        where: 'id = ?',
        whereArgs: [outfit.topClothId],
        limit: 1,
      );
      final bottomRow = await db.query(
        'clothes',
        where: 'id = ?',
        whereArgs: [outfit.bottomClothId],
        limit: 1,
      );
      final shoeRow = await db.query(
        'clothes',
        where: 'id = ?',
        whereArgs: [outfit.shoeClothId],
        limit: 1,
      );

      if (topRow.isEmpty || bottomRow.isEmpty || shoeRow.isEmpty) {
        return Result.success(null);
      }

      return Result.success(
        OutfitWithClothes(
          outfit: outfit,
          top: Cloth.fromMap(topRow.first),
          bottom: Cloth.fromMap(bottomRow.first),
          shoes: Cloth.fromMap(shoeRow.first),
        ),
      );
    } catch (error, stackTrace) {
      return Result.error(
        AppFailure(
          message: 'Kombin detayları alınamadı.',
          exception: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

class Result {
}
