import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../widgets/add_note_sheet.dart';
import 'github_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  final bool openAddNote;

  const HomeScreen({super.key, required this.appState, this.openAddNote = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _hasAutoOpened = false;

  @override
  void initState() {
    super.initState();
    if (widget.openAddNote) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasAutoOpened) {
          _hasAutoOpened = true;
          _openAddNoteSheet();
        }
      });
    }
  }

  void _openAddNoteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddNoteSheet(appState: widget.appState),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: _currentIndex == 0
            ? _buildNotesView()
            : _buildProjectsView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddNoteSheet,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.sticky_note_2_outlined, Icons.sticky_note_2, 'Notlar'),
              const SizedBox(width: 56), // space for FAB
              _buildNavItem(1, Icons.folder_outlined, Icons.folder, 'Projeler'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.35),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.35),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DevNote',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Geliştirici Notları',
                    style: TextStyle(
                      color: Color(0xFF6B6B6B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 22,
                ),
              ),
            ],
          ),
        ),

        // Notes list
        Expanded(
          child: widget.appState.notes.isEmpty
              ? _buildEmptyState(
                  Icons.note_add_outlined,
                  'Henüz not eklenmedi',
                  'Yeni bir not eklemek için + butonuna tıklayın',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.appState.notes.length,
                  itemBuilder: (context, index) {
                    final note = widget.appState.notes.reversed.toList()[index];
                    final project = widget.appState.getProjectById(note.projectId);
                    return _buildNoteCard(note, project);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(Note note, Project? project) {
    Color categoryColor;
    String categoryLabel;
    switch (note.category) {
      case NoteCategory.bugFix:
        categoryColor = const Color(0xFFE53935);
        categoryLabel = 'Hata Düzeltme';
        break;
      case NoteCategory.newFeature:
        categoryColor = const Color(0xFF43A047);
        categoryLabel = 'Yeni Özellik';
        break;
    }

    Color priorityColor;
    String priorityLabel;
    switch (note.priority) {
      case NotePriority.low:
        priorityColor = const Color(0xFF78909C);
        priorityLabel = 'Düşük';
        break;
      case NotePriority.medium:
        priorityColor = const Color(0xFFFFA726);
        priorityLabel = 'Orta';
        break;
      case NotePriority.high:
        priorityColor = const Color(0xFFEF5350);
        priorityLabel = 'Yüksek';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project name & priority
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (project != null)
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      project.name,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  priorityLabel,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Note content
          Text(
            note.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  categoryLabel,
                  style: TextStyle(
                    color: categoryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsView() {
    final manualProjects = widget.appState.manualProjects;
    final githubProjects = widget.appState.githubProjects;
    final isGithubConnected = widget.appState.isGithubConnected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Projeler',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tüm projeleriniz',
                    style: TextStyle(
                      color: Color(0xFF6B6B6B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GithubSettingsScreen(appState: widget.appState),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isGithubConnected
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.code_rounded,
                    color: isGithubConnected ? Colors.greenAccent : Colors.white.withValues(alpha: 0.5),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: manualProjects.isEmpty && githubProjects.isEmpty
              ? _buildEmptyState(
                  Icons.folder_open_rounded,
                  'Henüz proje yok',
                  'Not eklerken yeni proje oluşturabilir veya GitHub bağlayabilirsiniz',
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Manual projects
                    if (manualProjects.isNotEmpty) ...[
                      _buildSectionHeader('Yerel Projeler', Icons.folder_rounded),
                      ...manualProjects.map((p) {
                        final noteCount = widget.appState.getNotesForProject(p.id).length;
                        return _buildProjectCard(p, noteCount);
                      }),
                      const SizedBox(height: 8),
                    ],

                    // GitHub projects
                    if (githubProjects.isNotEmpty) ...[
                      _buildSectionHeader('GitHub Repoları', Icons.code_rounded),
                      ...githubProjects.map((p) {
                        final noteCount = widget.appState.getNotesForProject(p.id).length;
                        return _buildProjectCard(p, noteCount);
                      }),
                    ],

                    // Connect GitHub prompt
                    if (!isGithubConnected && githubProjects.isEmpty)
                      _buildGithubPrompt(),

                    const SizedBox(height: 80),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGithubPrompt() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GithubSettingsScreen(appState: widget.appState),
          ),
        ).then((_) => setState(() {}));
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A), style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.code_rounded, color: Colors.white38, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GitHub\'a Bağlan',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Repolarını proje olarak ekle',
                    style: TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.2), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Project project, int noteCount) {
    final isGithub = project.isGithubRepo;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isGithub
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isGithub ? Icons.code_rounded : Icons.folder_rounded,
              color: Colors.white.withValues(alpha: 0.5),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isGithub && project.githubLanguage != null) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getLanguageColor(project.githubLanguage!),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project.githubLanguage!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      '$noteCount not',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'dart': return const Color(0xFF00B4AB);
      case 'javascript': return const Color(0xFFF1E05A);
      case 'typescript': return const Color(0xFF3178C6);
      case 'python': return const Color(0xFF3572A5);
      case 'java': return const Color(0xFFB07219);
      case 'kotlin': return const Color(0xFFA97BFF);
      case 'swift': return const Color(0xFFFF6F43);
      case 'c++': return const Color(0xFFF34B7D);
      case 'c#': return const Color(0xFF178600);
      case 'go': return const Color(0xFF00ADD8);
      case 'rust': return const Color(0xFFDEA584);
      case 'ruby': return const Color(0xFF701516);
      case 'php': return const Color(0xFF4F5D95);
      case 'html': return const Color(0xFFE34C26);
      case 'css': return const Color(0xFF563D7C);
      default: return Colors.white38;
    }
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.1),
            size: 72,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
