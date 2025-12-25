import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../wardrobe/data/wardrobe_repository.dart';
import '../data/outfit_repository.dart';
import '../data/outfit_service.dart';
// Buraya currentUserProvider'ın tanımlı olduğu dosyayı eklemelisin:
// import '../../auth/data/auth_repository.dart'; 

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
    
    // Servis metodu çağrılıyor
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
    // currentUserProvider'ın varlığından emin olmalısın
    // final user = ref.read(currentUserProvider);
    const String userId = "1"; // Şimdilik test için statik

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(outfitRepositoryProvider);
      
      await repo.saveOutfit(
        userId: userId,
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
    // final user = ref.watch(currentUserProvider); // Kullanıcıyı izle

    return Scaffold(
      appBar: AppBar(title: const Text('Akıllı Kombin Oluştur')),
      body: FutureBuilder<List<Cloth>>(
        // KRİTİK DÜZELTME: getAllClothes yerine getClothes kullanıldı ve ID verildi
        future: wardrobeRepo.getClothes("1"), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final items = snapshot.data ?? [];
          
          if (items.isEmpty) {
            return const Center(
              child: Text('Kombin için önce kıyafet ekleyin'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView( // Taşmaları önlemek için eklendi
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _season,
                    decoration: const InputDecoration(
                      labelText: 'Mevsim Filtresi',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Summer', child: Text('Yaz')),
                      DropdownMenuItem(value: 'Winter', child: Text('Kış')),
                      DropdownMenuItem(value: 'All', child: Text('4 Mevsim')),
                    ],
                    onChanged: (value) => setState(() => _season = value!),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: _isSaving ? null : () => _generate(items),
                      child: Text(_isSaving ? 'Kaydediliyor...' : 'Kombin Oluştur'),
                    ),
                  ),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_message!, style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 24),
                  if (_currentOutfit != null) ...[
                    const Text(
                      'Senin İçin Seçtiklerimiz',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
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

  const _OutfitPreview({required this.top, required this.bottom, required this.shoes});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220, // Belirli bir yükseklik verildi
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _itemCard('Üst Giyim', top),
          _itemCard('Alt Giyim', bottom),
          _itemCard('Ayakkabı', shoes),
        ],
      ),
    );
  }

  Widget _itemCard(String title, Cloth cloth) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
              const Divider(),
              Expanded(
                child: cloth.imagePath != null && cloth.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(cloth.imagePath!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(cloth.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(cloth.color ?? 'Renk Yok', style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}