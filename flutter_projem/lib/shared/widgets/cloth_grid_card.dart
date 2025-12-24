import 'dart:io';
import 'package:flutter/material.dart';
import '../../features/wardrobe/data/wardrobe_repository.dart';

class ClothGridCard extends StatelessWidget {
  final Cloth cloth;
  final VoidCallback onTap;

  const ClothGridCard({super.key, required this.cloth, required this.onTap});

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

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
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
