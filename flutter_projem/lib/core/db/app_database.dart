import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = p.join(dir.path, 'kombin_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            passwordHash TEXT NOT NULL,
            createdAt INTEGER NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE session(
            id INTEGER PRIMARY KEY,
            userId TEXT
          );
        ''');
        await db.insert('session', {'id': 1, 'userId': null});
        await db.execute('''
          CREATE TABLE clothes(
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            color TEXT,
            season TEXT NOT NULL,
            tags TEXT,
            imagePath TEXT,
            createdAt INTEGER NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE outfits(
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            topClothId TEXT NOT NULL,
            bottomClothId TEXT NOT NULL,
            shoeClothId TEXT NOT NULL,
            seasonUsed TEXT NOT NULL,
            createdAt INTEGER NOT NULL
          );
        ''');
      },
    );
  }
}