import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/categoria.dart';
import '../models/curso.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  Future<Database>? _databaseFuture;

  Future<Database> get database => _databaseFuture ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    return openDatabase(
      join(databasePath, 'edutechif.db'),
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL COLLATE NOCASE,
            owner_id INTEGER NOT NULL,
            UNIQUE(owner_id, name),
            FOREIGN KEY (owner_id) REFERENCES users(id)
              ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE courses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            instructor TEXT NOT NULL,
            workload_hours INTEGER NOT NULL CHECK (workload_hours > 0),
            url TEXT NOT NULL DEFAULT '',
            category_id INTEGER,
            owner_id INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (category_id) REFERENCES categories(id)
              ON DELETE SET NULL,
            FOREIGN KEY (owner_id) REFERENCES users(id)
              ON DELETE CASCADE
          )
        ''');
        await db.execute('CREATE INDEX courses_owner_idx ON courses(owner_id)');
      },
    );
  }

  Future<int?> findUserIdByEmail(String email) async {
    final db = await database;
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['id'] as int;
  }

  Future<Map<String, Object?>?> findUserCredentials(String email) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> insertUser(Map<String, Object?> values) async {
    final db = await database;
    return db.insert('users', values);
  }

  Future<List<Categoria>> getCategories(int ownerId) async {
    final db = await database;
    final rows = await db.query(
      'categories',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Categoria.fromMap).toList();
  }

  Future<int> insertCategory(Categoria category, int ownerId) async {
    final db = await database;
    return db.insert('categories', {...category.toMap(), 'owner_id': ownerId});
  }

  Future<int> updateCategory(Categoria category, int ownerId) async {
    final db = await database;
    return db.update(
      'categories',
      category.toMap(),
      where: 'id = ? AND owner_id = ?',
      whereArgs: [category.id, ownerId],
    );
  }

  Future<int> deleteCategory(int id, int ownerId) async {
    final db = await database;
    return db.delete(
      'categories',
      where: 'id = ? AND owner_id = ?',
      whereArgs: [id, ownerId],
    );
  }

  Future<List<Curso>> getCourses(int ownerId) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT courses.*, categories.name AS category_name
      FROM courses
      LEFT JOIN categories ON categories.id = courses.category_id
      WHERE courses.owner_id = ?
      ORDER BY courses.created_at DESC, courses.id DESC
      ''',
      [ownerId],
    );
    return rows.map(Curso.fromMap).toList();
  }

  Future<int> insertCourse(Curso course) async {
    final db = await database;
    return db.insert('courses', course.toMap());
  }

  Future<int> updateCourse(Curso course) async {
    final db = await database;
    return db.update(
      'courses',
      course.toMap(),
      where: 'id = ? AND owner_id = ?',
      whereArgs: [course.id, course.usuarioId],
    );
  }

  Future<int> deleteCourse(int id, int ownerId) async {
    final db = await database;
    return db.delete(
      'courses',
      where: 'id = ? AND owner_id = ?',
      whereArgs: [id, ownerId],
    );
  }
}
