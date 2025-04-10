import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {

    return await openDatabase('chord.db', version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE ChordProgression (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          createdAt TEXT
        );
      ''');

      await db.execute('''
        CREATE TABLE ChordRow (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          progressionId INTEGER,
          chords TEXT
        );
      ''');
    });
  }

  Future<int> insertProgression(String title, List<List<String>> chordGrid) async {
    final dbClient = await db;
    final now = DateTime.now().toIso8601String();

    final id = await dbClient.insert('ChordProgression', {
      'title': title,
      'createdAt': now,
    });

    for (final row in chordGrid) {
      await dbClient.insert('ChordRow', {
        'progressionId': id,
        'chords': jsonEncode(row),
      });
    }

    return id;
  }
}