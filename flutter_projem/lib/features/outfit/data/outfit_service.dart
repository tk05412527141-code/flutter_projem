import 'dart:math';
import 'package:flutter_projem/features/wardrobe/data/wardrobe_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Kendi projenizdeki Cloth model yoluna göre gerekirse burayı düzeltin:

// 1. KRİTİK DÜZELTME: Provider'ı global olarak tanımlıyoruz. 
// OutfitPage bu ismi buradan okuyacak.
final outfitServiceProvider = Provider<SmartOutfitEngine>((ref) {
  return SmartOutfitEngine();
});

class SmartOutfitEngine {
  final Random _random = Random();

  // 2. ZEKA KATMANI: Sıcaklık parametresi eklendi
  List<Cloth> generateSmartOutfit({
    required List<Cloth> allClothes,
    required double temperature,
  }) {
    // Sıcaklığa göre mevsim belirleme zekası
    String recommendedSeason;
    if (temperature < 15) {
      recommendedSeason = 'Winter'; // Kışlık
    } else if (temperature > 25) {
      recommendedSeason = 'Summer'; // Yazlık
    } else {
      recommendedSeason = 'All';    // Mevsimsiz/Bahar
    }

    // Filtreleme: Mevsime uygun olanları seç
    final suitableClothes = allClothes.where((c) => 
      // ignore: unrelated_type_equality_checks
      c.season == recommendedSeason || c.season == 'All'
    ).toList();

    if (suitableClothes.isEmpty) return [];

    // Kategorilere ayır
    // ignore: unrelated_type_equality_checks
    final tops = suitableClothes.where((c) => c.category == 'top').toList();
    // ignore: unrelated_type_equality_checks
    final bottoms = suitableClothes.where((c) => c.category == 'bottom').toList();
    // ignore: unrelated_type_equality_checks
    final shoes = suitableClothes.where((c) => c.category == 'shoes').toList();

    if (tops.isEmpty || bottoms.isEmpty || shoes.isEmpty) return [];

    // Rastgele ama kategorize edilmiş seçim
    return [
      tops[_random.nextInt(tops.length)],
      bottoms[_random.nextInt(bottoms.length)],
      shoes[_random.nextInt(shoes.length)],
    ];
  }
}