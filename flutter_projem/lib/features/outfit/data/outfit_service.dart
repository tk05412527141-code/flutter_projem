import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../wardrobe/data/wardrobe_repository.dart';

final outfitServiceProvider = Provider<OutfitService>((ref) {
  return OutfitService(Random());
});

class OutfitService {
  OutfitService(this._random);

  final Random _random;

  List<Cloth> _filterBySeason(List<Cloth> items, Season season) {
    return items.where((cloth) {
      if (season == Season.all) return true;
      if (cloth.season == Season.all) return true;
      return cloth.season == season;
    }).toList();
  }

  Cloth? _pickRandom(List<Cloth> items) {
    if (items.isEmpty) return null;
    return items[_random.nextInt(items.length)];
  }

  Cloth? _pickShoes(String? topColor, List<Cloth> shoes) {
    if (topColor == null) return _pickRandom(shoes);
    final lower = topColor.toLowerCase();
    List<Cloth> filtered = shoes;
    if (lower.contains('siyah')) {
      filtered = shoes.where((c) {
        final color = c.color?.toLowerCase() ?? '';
        return color.contains('siyah') || color.contains('beyaz');
      }).toList();
    } else if (lower.contains('beyaz')) {
      filtered = shoes;
    }
    if (filtered.isEmpty) {
      return _pickRandom(shoes);
    }
    return _pickRandom(filtered);
  }

  Map<String, Cloth>? createOutfit(
      {required List<Cloth> items, required Season season}) {
    final tops = _filterBySeason(
        items.where((c) => c.category == ClothCategory.top).toList(), season);
    final bottoms = _filterBySeason(
        items.where((c) => c.category == ClothCategory.bottom).toList(),
        season);
    final shoes = _filterBySeason(
        items.where((c) => c.category == ClothCategory.shoes).toList(),
        season);

    if (tops.isEmpty || bottoms.isEmpty || shoes.isEmpty) {
      return null;
    }

    final Cloth? top = _pickRandom(tops);
    final Cloth? bottom = _pickRandom(bottoms);
    final Cloth? shoe = _pickShoes(top?.color, shoes);

    if (top == null || bottom == null || shoe == null) return null;

    return {
      'top': top,
      'bottom': bottom,
      'shoes': shoe,
    };
  }

  generateSmartOutfit({required List<Cloth> allClothes, required double temperature}) {}
}