import 'dart:io';
import 'package:flutter/material.dart';
import '../../features/wardrobe/data/wardrobe_repository.dart';

class ClothGridCard extends StatelessWidget {
  final Cloth cloth;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClothGridCard({
    super.key,
    required this.cloth,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  String _cat(ClothCategory c) => switch (c) {
        ClothCategory.top => "Üst",
        ClothCategory.bottom => "Alt",
        ClothCategory.shoes => "Ayakkabı",
        ClothCategory.outerwear => "Dış Giyim",
        ClothCategory.accessory => "Aksesuar",
      };

  String _season(Season s) => switch (s) {
        Season.summer => "Yaz",
        Season.winter => "Kış",
        Season.all => "Tüm",
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasMenu = (onEdit != null) || (onDelete != null);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Görsel alanı + sağ üst menü
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        color: scheme.surface,
                        child: (cloth.imagePath == null || cloth.imagePath!.isEmpty)
                            ? const Center(child: Icon(Icons.image_rounded))
                            : Image.file(
                                File(cloth.imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Center(child: Icon(Icons.broken_image_rounded)),
                              ),
                      ),
                    ),

                    if (hasMenu)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Material(
                          color: Colors.transparent,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.surface.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: PopupMenuButton<String>(
                              tooltip: 'İşlemler',
                              onSelected: (value) {
                                if (value == 'edit') onEdit?.call();
                                if (value == 'delete') onDelete?.call();
                              },
                              itemBuilder: (context) => [
                                if (onEdit != null)
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Düzenle'),
                                  ),
                                if (onDelete != null)
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Sil',
                                      style: TextStyle(color: scheme.error),
                                    ),
                                  ),
                              ],
                              icon: const Icon(Icons.more_vert),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Text(
                cloth.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(_cat(cloth.category))),
                  if (cloth.season != Season.all) Chip(label: Text(_season(cloth.season))),
                  if ((cloth.color ?? '').isNotEmpty) Chip(label: Text(cloth.color!)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
