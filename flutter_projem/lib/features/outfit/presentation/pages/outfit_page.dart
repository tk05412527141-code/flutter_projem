import 'package:flutter_riverpod/flutter_riverpod.dart';


final outfitGeneratorProvider = Provider<OutfitGenerator>((ref) {
  return OutfitGenerator();
});

class OutfitGenerator {
}