import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../wardrobe/data/wardrobe_repository.dart';
import '../data/outfit_repository.dart';
import '../data/outfit_service.dart';

class OutfitPage extends ConsumerStatefulWidget {
  const OutfitPage({super.key});

  @override
  ConsumerState<OutfitPage> createState() => _OutfitPageState();
}

class _OutfitPageState extends ConsumerState<OutfitPage> {
  Season _season = Season.all;
  Map<String, Cloth>? _currentOutfit;
  bool _isSaving = false;
  String? _message;

  Future<void> _generate(List<Cloth> items) async {
    final service = ref.read(outfitServiceProvider);
    final created = service.createOutfit(items: items, season: _season);
    setState(() {
      _currentOutfit = created;
      _message = created == null ? 'Uygun kombin bulunamadı' : null;
    });
    if (created != null) {
      await _save(created);
    }
  }

  Future<void> _save(Map<String, Cloth> outfit) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _isSaving = true);
    final repo = ref.read(outfitRepositoryProvider);
    await repo.saveOutfit(
      userId: user.id,
      top: outfit['top']!,
      bottom: outfit['bottom']!,
      shoes: outfit['shoes']!,
      seasonUsed: _season.name,
    );
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final wardrobeRepo = ref.watch(wardrobeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kombin Oluştur')),
      body: user == null
          ? const Center(child: Text('Giriş yapmanız gerekiyor'))
          : FutureBuilder(
              future: wardrobeRepo.getClothes(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(
                    child:
                        Text('Kombin için en az üst, alt ve ayakkabı ekleyin'),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<Season>(
                        value: _season,
                        decoration: const InputDecoration(labelText: 'Sezon'),
                        items: const [
                          DropdownMenuItem(
                              value: Season.summer, child: Text('Yaz')),
                          DropdownMenuItem(
                              value: Season.winter, child: Text('Kış')),
                          DropdownMenuItem(
                              value: Season.all, child: Text('4 Mevsim')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _season = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isSaving ? null : () => _generate(items),
                          child: Text(_isSaving
                              ? 'Kaydediliyor...'
                              : 'Kombin Oluştur'),
                        ),
                      ),
                      if (_message != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _message!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (_currentOutfit != null) ...[
                        const Text(
                          'Oluşturulan Kombin',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _OutfitPreview(
                          top: _currentOutfit!['top']!,
                          bottom: _currentOutfit!['bottom']!,
                          shoes: _currentOutfit!['shoes']!,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _OutfitPreview extends StatelessWidget {
  const _OutfitPreview({
    required this.top,
    required this.bottom,
    required this.shoes,
  });

  final Cloth top;
  final Cloth bottom;
  final Cloth shoes;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _itemCard('Üst', top)),
        const SizedBox(width: 8),
        Expanded(child: _itemCard('Alt', bottom)),
        const SizedBox(width: 8),
        Expanded(child: _itemCard('Ayakkabı', shoes)),
      ],
    );
  }

  Widget _itemCard(String title, Cloth cloth) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (cloth.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(cloth.imagePath!),
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            Text(cloth.name),
            if (cloth.color != null)
              Text(
                cloth.color!,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}