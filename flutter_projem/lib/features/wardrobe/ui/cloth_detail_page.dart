import 'dart:io';

import 'package:flutter/material.dart';

import '../data/wardrobe_repository.dart';

class ClothDetailPage extends StatelessWidget {
  const ClothDetailPage({super.key, required this.cloth});

  final Cloth cloth;

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

  String _seasonLabel(Season season) {
    switch (season) {
      case Season.summer:
        return 'Yaz';
      case Season.winter:
        return 'Kış';
      case Season.all:
        return '4 Mevsim';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cloth.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cloth.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(cloth.imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text('Kategori: ${_categoryLabel(cloth.category)}'),
            const SizedBox(height: 8),
            Text('Sezon: ${_seasonLabel(cloth.season)}'),
            const SizedBox(height: 8),
            Text('Renk: ${cloth.color ?? '-'}'),
            const SizedBox(height: 8),
            Text('Etiketler: ${cloth.tags ?? '-'}'),
          ],
        ),
      ),
    );
  }
}