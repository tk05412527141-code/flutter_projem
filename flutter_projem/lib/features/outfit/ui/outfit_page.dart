import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import yollarını kendi proje yapına göre kontrol et
import '../../wardrobe/data/wardrobe_repository.dart';
import '../data/outfit_repository.dart';
import '../data/outfit_service.dart';
import '../../../core/models/cloth_model.dart'; // Cloth modelinin yolu

class OutfitPage extends ConsumerStatefulWidget {
  const OutfitPage({super.key});

  @override
  ConsumerState<OutfitPage> createState() => _OutfitPageState();
}

class _OutfitPageState extends ConsumerState<OutfitPage> {
  // Not: Season enum'ın nerede tanımlıysa oradan import edilmeli
  String _season = 'All'; 
  List<Cloth>? _currentOutfit; // Map yerine Service'den gelen List yapısına uygun hale getirildi
  bool _isSaving = false;
  String? _message;

  Future<void> _generate(List<Cloth> items) async {
    final service = ref.read(outfitServiceProvider);
    
    // KRİTİK DÜZELTME: Metod ismi generateSmartOutfit olarak güncellendi
    // Sıcaklık değeri şimdilik 20.0 (sabit) olarak gönderildi
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
    // Not: currentUserProvider'ın tanımlı olduğundan emin ol
    // final user = ref.read(currentUserProvider); 
    // if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(outfitRepositoryProvider);
      
      // Servisten gelen liste sırası: 0: üst, 1: alt, 2: ayakkabı
      await repo.saveOutfit(
        userId: "1", // Geçici olarak statik ID, user.id ile değiştir
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
    // WardrobeRepository'nin provider üzerinden izlenmesi
    final wardrobeRepo = ref.watch(wardrobeRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Akıllı Kombin Oluştur')),
      body: FutureBuilder<List<Cloth>>(
        future: wardrobeRepo.getAllClothes(), // getClothes(user.id) yerine genel metod
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _season,
                  decoration: const InputDecoration(labelText: 'Mevsim Filtresi'),
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
                  child: ElevatedButton(
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
      width: 140,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Divider(),
              if (cloth.imagePath != null && cloth.imagePath!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    File(cloth.imagePath!),
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const Icon(Icons.image, size: 80, color: Colors.grey),
              const SizedBox(height: 8),
              Text(cloth.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(cloth.color ?? '-', style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}