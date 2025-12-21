import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/utils/hash.dart';

class AppUser {
  AppUser({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String passwordHash;
  final int createdAt;

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      createdAt: map['createdAt'] as int,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(database: AppDatabase.instance);
});

final sessionControllerProvider =
    StateNotifierProvider<SessionController, AsyncValue<AppUser?>>((ref) {
  return SessionController(ref.read);
});

class AuthRepository {
  AuthRepository({required this.database});

  final AppDatabase database;

  Future<AppUser> register(String email, String password) async {
    final db = await database.database;
    final existing =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (existing.isNotEmpty) {
      throw Exception('Email zaten kayıtlı');
    }
    final user = AppUser(
      id: const Uuid().v4(),
      email: email,
      passwordHash: sha256Hash(password),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert('users', {
      'id': user.id,
      'email': user.email,
      'passwordHash': user.passwordHash,
      'createdAt': user.createdAt,
    });
    await _setSessionUser(user.id);
    return user;
  }

  Future<AppUser> login(String email, String password) async {
    final db = await database.database;
    final rows =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (rows.isEmpty) {
      throw Exception('Kullanıcı bulunamadı');
    }
    final user = AppUser.fromMap(rows.first);
    if (user.passwordHash != sha256Hash(password)) {
      throw Exception('Şifre hatalı');
    }
    await _setSessionUser(user.id);
    return user;
  }

  Future<void> logout() async {
    await _setSessionUser(null);
  }

  Future<AppUser?> currentUser() async {
    final db = await database.database;
    final session =
        await db.query('session', where: 'id = ?', whereArgs: [1], limit: 1);
    if (session.isEmpty) return null;
    final userId = session.first['userId'] as String?;
    if (userId == null) return null;
    final users =
        await db.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
    if (users.isEmpty) return null;
    return AppUser.fromMap(users.first);
  }

  Future<void> _setSessionUser(String? userId) async {
    final db = await database.database;
    await db.update(
      'session',
      {'userId': userId},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}

class SessionController extends StateNotifier<AsyncValue<AppUser?>> {
  SessionController(this._read) : super(const AsyncValue.loading()) {
    loadSession();
  }

  final Reader _read;

  AuthRepository get _repo => _read(authRepositoryProvider);

  Future<void> loadSession() async {
    try {
      final user = await _repo.currentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.register(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(null);
  }
}