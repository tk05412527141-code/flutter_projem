import 'dart:io';

import 'package:flutter/material.dart';

import '../../features/wardrobe/data/wardrobe_repository.dart';

class ClothCard extends StatelessWidget {
  const ClothCard({super.key, required this.cloth, this.onTap});

  final Cloth cloth;
  final VoidCallback? onTap;

  String _categoryLabel(ClothCategory category) {
    switch (category) {
      case ClothCategory.top:
        return 'Üst';
      case ClothCategory.bottom:
        return 'Alt';
      case ClothCategory.shoes:
        return 'Ayakkabı';
      case ClothCategory.outerwear:
        return 'Dış giyim';
      case ClothCategory.accessory:
        return 'Aksesuar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (cloth.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(cloth.imagePath!),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              if (cloth.imagePath != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cloth.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(_categoryLabel(cloth.category)),
                    if (cloth.color != null)
                      Text(
                        cloth.color!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}