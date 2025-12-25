import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Veritabanı sağlayıcısı (Proje genelinde tek bir instance olmasını sağlar)
final dbServiceProvider = Provider((ref) => DatabaseService());

class DatabaseService {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('kombin.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kombins (
            id TEXT PRIMARY KEY,
            imageUrl TEXT,
            title TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }
}