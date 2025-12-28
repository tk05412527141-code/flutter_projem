import 'package:flutter_projem/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final currentUserProvider = Provider<AppUser?>((ref) {
  final session = ref.watch(sessionControllerProvider);
  return session.valueOrNull;
});