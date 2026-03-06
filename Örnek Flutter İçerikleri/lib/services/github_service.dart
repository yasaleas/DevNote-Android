import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';

class GitHubService {
  static const _baseUrl = 'https://api.github.com';

  final String _token;

  GitHubService(this._token);

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/vnd.github.v3+json',
      };

  /// Validate token and return username
  Future<String?> validateToken() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['login'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get user info (avatar, name, etc.)
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetch all repos for the authenticated user
  Future<List<Project>> fetchRepos() async {
    final allRepos = <Map<String, dynamic>>[];
    int page = 1;

    while (true) {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/repos?per_page=100&page=$page&sort=updated&affiliation=owner'),
        headers: _headers,
      );

      if (response.statusCode != 200) break;

      final List<dynamic> repos = json.decode(response.body);
      if (repos.isEmpty) break;

      allRepos.addAll(repos.cast<Map<String, dynamic>>());
      page++;
    }

    return allRepos.map((repo) {
      return Project(
        id: 'gh_${repo['id']}',
        name: repo['name'],
        createdAt: DateTime.parse(repo['created_at']),
        isGithubRepo: true,
        githubFullName: repo['full_name'],
        githubUrl: repo['html_url'],
        githubDescription: repo['description'],
        githubLanguage: repo['language'],
      );
    }).toList();
  }
}
