import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';
import '../models/project.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'devnote.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isGithubRepo INTEGER NOT NULL DEFAULT 0,
        githubFullName TEXT,
        githubUrl TEXT,
        githubDescription TEXT,
        githubLanguage TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        projectId TEXT NOT NULL,
        content TEXT NOT NULL,
        category INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE projects ADD COLUMN isGithubRepo INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE projects ADD COLUMN githubFullName TEXT');
      await db.execute('ALTER TABLE projects ADD COLUMN githubUrl TEXT');
      await db.execute('ALTER TABLE projects ADD COLUMN githubDescription TEXT');
      await db.execute('ALTER TABLE projects ADD COLUMN githubLanguage TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings(
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
    }
  }

  // ── Settings (token storage) ──

  Future<void> saveGithubToken(String token) async {
    final db = await database;
    await db.insert('settings', {'key': 'github_token', 'value': token},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getGithubToken() async {
    final db = await database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: ['github_token']);
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  Future<void> deleteGithubToken() async {
    final db = await database;
    await db.delete('settings', where: 'key = ?', whereArgs: ['github_token']);
  }

  // ── Project CRUD ──

  Future<void> insertProject(Project project) async {
    final db = await database;
    await db.insert('projects', project.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Project>> getProjects() async {
    final db = await database;
    final maps = await db.query('projects', orderBy: 'createdAt DESC');
    return maps.map((m) => Project.fromMap(m)).toList();
  }

  Future<void> deleteProject(String id) async {
    final db = await database;
    await db.delete('notes', where: 'projectId = ?', whereArgs: [id]);
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteGithubProjects() async {
    final db = await database;
    final ghProjects = await db.query('projects', where: 'isGithubRepo = 1');
    for (final p in ghProjects) {
      await db.delete('notes', where: 'projectId = ?', whereArgs: [p['id']]);
    }
    await db.delete('projects', where: 'isGithubRepo = 1');
  }

  // ── Note CRUD ──

  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert('notes', note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'createdAt DESC');
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
