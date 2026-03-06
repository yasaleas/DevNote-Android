import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/note.dart';
import '../services/database_service.dart';
import '../services/github_service.dart';

class AppState extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<Project> _projects = [];
  List<Note> _notes = [];
  bool _isLoaded = false;

  // GitHub state
  String? _githubUsername;
  String? _githubAvatarUrl;
  bool _isGithubConnected = false;
  bool _isGithubLoading = false;

  List<Project> get projects => List.unmodifiable(_projects);
  List<Note> get notes => List.unmodifiable(_notes);
  bool get isLoaded => _isLoaded;

  String? get githubUsername => _githubUsername;
  String? get githubAvatarUrl => _githubAvatarUrl;
  bool get isGithubConnected => _isGithubConnected;
  bool get isGithubLoading => _isGithubLoading;

  List<Project> get manualProjects =>
      _projects.where((p) => !p.isGithubRepo).toList();
  List<Project> get githubProjects =>
      _projects.where((p) => p.isGithubRepo).toList();

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    _projects = await _db.getProjects();
    _notes = await _db.getNotes();
    _isLoaded = true;
    notifyListeners();

    // Check for existing GitHub token
    final token = await _db.getGithubToken();
    if (token != null) {
      await _connectGithubSilently(token);
    }
  }

  // ── GitHub ──

  Future<String?> connectGithub(String token) async {
    _isGithubLoading = true;
    notifyListeners();

    try {
      final service = GitHubService(token);
      final username = await service.validateToken();

      if (username == null) {
        _isGithubLoading = false;
        notifyListeners();
        return 'Geçersiz token. Lütfen kontrol edin.';
      }

      await _db.saveGithubToken(token);

      final userInfo = await service.getUserInfo();
      _githubUsername = username;
      _githubAvatarUrl = userInfo?['avatar_url'];
      _isGithubConnected = true;

      // Fetch and sync repos
      await _syncGithubRepos(service);

      _isGithubLoading = false;
      notifyListeners();
      return null; // success
    } catch (e) {
      _isGithubLoading = false;
      notifyListeners();
      return 'Bağlantı hatası: $e';
    }
  }

  Future<void> _connectGithubSilently(String token) async {
    try {
      final service = GitHubService(token);
      final username = await service.validateToken();
      if (username != null) {
        final userInfo = await service.getUserInfo();
        _githubUsername = username;
        _githubAvatarUrl = userInfo?['avatar_url'];
        _isGithubConnected = true;
        notifyListeners();
      }
    } catch (_) {
      // silently fail
    }
  }

  Future<void> refreshGithubRepos() async {
    final token = await _db.getGithubToken();
    if (token == null) return;

    _isGithubLoading = true;
    notifyListeners();

    try {
      final service = GitHubService(token);
      await _syncGithubRepos(service);
    } catch (_) {}

    _isGithubLoading = false;
    notifyListeners();
  }

  Future<void> _syncGithubRepos(GitHubService service) async {
    final repos = await service.fetchRepos();

    // Remove old github projects from memory
    _projects.removeWhere((p) => p.isGithubRepo);

    // Delete old github projects from DB
    await _db.deleteGithubProjects();

    // Insert new repos
    for (final repo in repos) {
      _projects.add(repo);
      await _db.insertProject(repo);
    }

    notifyListeners();
  }

  Future<void> disconnectGithub() async {
    await _db.deleteGithubToken();
    await _db.deleteGithubProjects();
    _projects.removeWhere((p) => p.isGithubRepo);
    // Also remove notes for github projects
    final ghIds = _projects.where((p) => p.isGithubRepo).map((p) => p.id).toSet();
    _notes.removeWhere((n) => ghIds.contains(n.projectId));
    _githubUsername = null;
    _githubAvatarUrl = null;
    _isGithubConnected = false;
    notifyListeners();
  }

  // ── Project CRUD ──

  void addProject(Project project) {
    _projects.insert(0, project);
    notifyListeners();
    _db.insertProject(project);
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    _notes.removeWhere((n) => n.projectId == id);
    notifyListeners();
    _db.deleteProject(id);
  }

  // ── Note CRUD ──

  void addNote(Note note) {
    _notes.insert(0, note);
    notifyListeners();
    _db.insertNote(note);
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    _db.deleteNote(id);
  }

  List<Note> getNotesForProject(String projectId) {
    return _notes.where((n) => n.projectId == projectId).toList();
  }

  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } catch (_) {
      return null;
    }
  }
}
