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
      imagePath: map['image_path'] as String?,
      createdAt: map['created_at'] as int,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'category': category.dbValue,
        'color': color,
        'season': season.dbValue,
        'tags': tags,
        'image_path': imagePath,
        'created_at': createdAt,
      };

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
}

extension ClothCategoryX on ClothCategory {
  String get dbValue {
    switch (this) {
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

  String get label {
    switch (this) {
      case ClothCategory.top:
        return 'Üst Giyim';
      case ClothCategory.bottom:
        return 'Alt Giyim';
      case ClothCategory.shoes:
        return 'Ayakkabı';
      case ClothCategory.outerwear:
        return 'Dış Giyim';
      case ClothCategory.accessory:
        return 'Aksesuar';
    }
  }
}

extension SeasonX on Season {
  String get dbValue {
    switch (this) {
      case Season.summer:
        return 'summer';
      case Season.winter:
        return 'winter';
      case Season.all:
        return 'all';
    }
  }

  String get label {
    switch (this) {
      case Season.summer:
        return 'Yaz';
      case Season.winter:
        return 'Kış';
      case Season.all:
        return '4 Mevsim';
    }
  }
}