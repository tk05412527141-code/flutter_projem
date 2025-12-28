import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/cloth.dart';

class OutfitDetailPage extends StatelessWidget {
  const OutfitDetailPage({
    super.key,
    required this.top,
    required this.bottom,
    required this.shoes,
    required this.createdAt,
  });

  final Cloth top;
  final Cloth bottom;
  final Cloth shoes;
  final int createdAt;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt);

    final formattedDate =
        '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kombin Detay'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarih: $formattedDate',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            _item('Üst', top),
            const SizedBox(height: AppSpacing.sm),
            _item('Alt', bottom),
            const SizedBox(height: AppSpacing.sm),
            _item('Ayakkabı', shoes),
          ],
        ),
      ),
    );
  }

  Widget _item(String title, Cloth cloth) {
    final hasImage =
        cloth.imagePath != null && cloth.imagePath!.trim().isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(cloth.imagePath!),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            if (hasImage) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(cloth.name),
                  if (cloth.color != null && cloth.color!.trim().isNotEmpty)
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
    );
  }
}
