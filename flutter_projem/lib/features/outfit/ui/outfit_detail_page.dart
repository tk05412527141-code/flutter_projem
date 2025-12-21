import 'dart:io';

import 'package:flutter/material.dart';

import '../../wardrobe/data/wardrobe_repository.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kombin Detay'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarih: ${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _item('Üst', top),
            const SizedBox(height: 12),
            _item('Alt', bottom),
            const SizedBox(height: 12),
            _item('Ayakkabı', shoes),
          ],
        ),
      ),
    );
  }

  Widget _item(String title, Cloth cloth) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (cloth.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(cloth.imagePath!),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(cloth.name),
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
    );
  }
}