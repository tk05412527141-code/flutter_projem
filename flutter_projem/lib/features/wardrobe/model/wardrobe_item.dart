class WardrobeItem {
  final String id;
  final String imagePath;
  final String category;
  final DateTime createdAt;

  const WardrobeItem({
    required this.id,
    required this.imagePath,
    required this.category,
    required this.createdAt,
  });

  factory WardrobeItem.fromMap(Map<String, Object?> map) {
    return WardrobeItem(
      id: map['id'] as String,
      imagePath: map['image_path'] as String,
      category: map['category'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'image_path': imagePath,
        'category': category,
        'created_at': createdAt.millisecondsSinceEpoch,
      };
}
