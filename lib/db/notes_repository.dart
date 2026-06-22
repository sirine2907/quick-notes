import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

class NotesRepository {
  static final NotesRepository instance = NotesRepository._();
  static Database? _db;

  NotesRepository._();

  Future<Database> get _database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quick_notes.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE notes (
          id       INTEGER PRIMARY KEY AUTOINCREMENT,
          title    TEXT    NOT NULL,
          body     TEXT    NOT NULL,
          tags     TEXT    NOT NULL DEFAULT '',
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      '''),
    );
  }

  Future<Note> insert(Note note) async {
    final db = await _database;
    final id = await db.insert('notes', note.toMap());
    return note.copyWith(id: id);
  }

  Future<List<Note>> getAll() async {
    final db = await _database;
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note?> getById(int id) async {
    final db = await _database;
    final rows = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Note.fromMap(rows.first);
  }

  Future<void> update(Note note) async {
    final db = await _database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Note>> search(String query) async {
    final db = await _database;
    final rows = await db.query(
      'notes',
      where: 'title LIKE ? OR body LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );
    return rows.map(Note.fromMap).toList();
  }

  Future<List<Note>> getByTag(String tag) async {
    final all = await getAll();
    return all.where((n) => n.tags.contains(tag)).toList();
  }
}
