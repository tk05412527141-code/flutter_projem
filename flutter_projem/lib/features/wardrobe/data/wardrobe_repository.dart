import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../auth/data/auth_repository.dart';

enum ClothCategory { top, bottom, shoes, outerwear, accessory }

enum Season { summer, winter, all }

class Cloth {
  Cloth({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.color,
    required this.season,
    required this.tags,
    required this.imagePath,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final ClothCategory category;
  final String? color;
  final Season season;
  final String? tags;
  final String? imagePath;
  final int createdAt;

  factory Cloth.fromMap(Map<String, Object?> map) {
    return Cloth(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      category: _categoryFromString(map['category'] as String),
      color: map['color'] as String?,
      season: _seasonFromString(map['season'] as String),
      tags: map['tags'] as String?,
      imagePath: map['imagePath'] as String?,
      createdAt: map['createdAt'] as int,
    );
  }

  static ClothCategory _categoryFromString(String value) {
    switch (value) {
      case 'top':
        return ClothCategory.top;
      case 'bottom':
        return ClothCategory.bottom;
      case 'shoes':
        return ClothCategory.shoes;
      case 'outerwear':
        return ClothCategory.outerwear;
      case 'accessory':
      default:
        return ClothCategory.accessory;
    }
  }

  static Season _seasonFromString(String value) {
    switch (value) {
      case 'summer':
        return Season.summer;
      case 'winter':
        return Season.winter;
      default:
        return Season.all;
    }
  }

  String get seasonValue {
    switch (season) {
      case Season.summer:
        return 'summer';
      case Season.winter:
        return 'winter';
      case Season.all:
        return 'all';
    }
  }

  String get categoryValue {
    switch (category) {
      case ClothCategory.top:
        return 'top';
      case ClothCategory.bottom:
        return 'bottom';
      case ClothCategory.shoes:
        return 'shoes';
      case ClothCategory.outerwear:
        return 'outerwear';
      case ClothCategory.accessory:
        return 'accessory';
    }
  }
}

final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return WardrobeRepository(database: AppDatabase.instance);
});

class WardrobeRepository {
  WardrobeRepository({required this.database});

  final AppDatabase database;

  Future<Cloth> addCloth({
    required String userId,
    required String name,
    required ClothCategory category,
    required Season season,
    String? color,
    String? tags,
    String? imagePath,
  }) async {
    final db = await database.database;
    final cloth = Cloth(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      category: category,
      season: season,
      color: color,
      tags: tags,
      imagePath: imagePath,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert('clothes', {
      'id': cloth.id,
      'userId': cloth.userId,
      'name': cloth.name,
      'category': cloth.categoryValue,
      'color': cloth.color,
      'season': cloth.seasonValue,
      'tags': cloth.tags,
      'imagePath': cloth.imagePath,
      'createdAt': cloth.createdAt,
    });
    return cloth;
  }

  Future<List<Cloth>> getClothes(String userId) async {
    final db = await database.database;
    final rows = await db.query(
      'clothes',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(Cloth.fromMap).toList();
  }

  Future<List<Cloth>> getAllClothes() async {
    final db = await database.database;
    final rows = await db.query('clothes', orderBy: 'createdAt DESC');
    return rows.map(Cloth.fromMap).toList();
  }

  Future<Cloth?> getClothById(String id) async {
    final db = await database.database;
    final rows =
        await db.query('clothes', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Cloth.fromMap(rows.first);
  }
}

final currentUserProvider = Provider<AppUser?>((ref) {
  final session = ref.watch(sessionControllerProvider);
  return session.valueOrNull;
});
