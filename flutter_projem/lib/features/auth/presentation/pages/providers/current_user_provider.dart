import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';

final currentUserProvider = Provider<AppUser?>((ref) {
  final session = ref.watch(sessionControllerProvider);
  return session.valueOrNull;
});