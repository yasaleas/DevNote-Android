class Project {
  final String id;
  final String name;
  final DateTime createdAt;
  final bool isGithubRepo;
  final String? githubFullName; // e.g. "yusufyasar333/devnote"
  final String? githubUrl;
  final String? githubDescription;
  final String? githubLanguage;

  Project({
    required this.id,
    required this.name,
    required this.createdAt,
    this.isGithubRepo = false,
    this.githubFullName,
    this.githubUrl,
    this.githubDescription,
    this.githubLanguage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'isGithubRepo': isGithubRepo ? 1 : 0,
      'githubFullName': githubFullName,
      'githubUrl': githubUrl,
      'githubDescription': githubDescription,
      'githubLanguage': githubLanguage,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
      isGithubRepo: (map['isGithubRepo'] ?? 0) == 1,
      githubFullName: map['githubFullName'],
      githubUrl: map['githubUrl'],
      githubDescription: map['githubDescription'],
      githubLanguage: map['githubLanguage'],
    );
  }
}
