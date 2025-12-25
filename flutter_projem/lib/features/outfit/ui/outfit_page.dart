import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../wardrobe/data/wardrobe_repository.dart';
import '../data/outfit_repository.dart';
import '../data/outfit_service.dart';

class OutfitPage extends ConsumerStatefulWidget {
  const OutfitPage({super.key});

  @override
  ConsumerState<OutfitPage> createState() => _OutfitPageState();
}

class _OutfitPageState extends ConsumerState<OutfitPage> {
  String _season = 'All'; 
  List<Cloth>? _currentOutfit; 
  bool _isSaving = false;
  String? _message;

  Future<void> _generate(List<Cloth> items) async {
    final service = ref.read(outfitServiceProvider);
    
    final created = service.generateSmartOutfit(
      allClothes: items, 
      temperature: 20.0 
    );

    setState(() {
      _currentOutfit = created.isNotEmpty ? created : null;
      _message = created.isEmpty ? 'Uygun kombin bulunamadı' : null;
    });

    if (created.isNotEmpty) {
      await _save(created);
    }
  }

  Future<void> _save(List<Cloth> outfit) async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(outfitRepositoryProvider);
      await repo.saveOutfit(
        userId: "1", 
        top: outfit[0],
        bottom: outfit[1],
        shoes: outfit[2],
        seasonUsed: _season,
      );
    } catch (e) {
      setState(() => _message = "Kaydedilirken hata oluştu");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wardrobeRepo = ref.watch(wardrobeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kombin Oluştur'), centerTitle: true),
      body: FutureBuilder<List<Cloth>>(
        future: wardrobeRepo.getClothes("1"), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final items = snapshot.data ?? [];
          
          if (items.isEmpty) {
            return const Center(child: Text('Önce kıyafet eklemelisiniz'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _season,
                    decoration: const InputDecoration(
                      labelText: 'Mevsim Seçimi',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Summer', child: Text('Yaz')),
                      DropdownMenuItem(value: 'Winter', child: Text('Kış')),
                      DropdownMenuItem(value: 'All', child: Text('4 Mevsim')),
                    ],
                    onChanged: (value) => setState(() => _season = value!),
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : () => _generate(items),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(_isSaving ? 'Kaydediliyor...' : 'Kombini Yenile'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_message!, style: const TextStyle(color: Colors.red)),
                    ),
                  
                  const SizedBox(height: 30),
                  
                  if (_currentOutfit != null) ...[
                    const Text(
                      'Senin İçin Seçtiğimiz Kombin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _OutfitPreview(
                      top: _currentOutfit![0],
                      bottom: _currentOutfit![1],
                      shoes: _currentOutfit![2],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OutfitPreview extends StatelessWidget {
  final Cloth top;
  final Cloth bottom;
  final Cloth shoes;

  const _OutfitPreview({
    required this.top,
    required this.bottom,
    required this.shoes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Divider(),
            if (cloth.imagePath != null && cloth.imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(cloth.imagePath!),
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              cloth.name, 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis, 
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}