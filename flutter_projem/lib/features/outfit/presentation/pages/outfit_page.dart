import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/outfit_generator.dart';

final outfitGeneratorProvider = Provider<OutfitGenerator>((ref) {
  return OutfitGenerator();
});