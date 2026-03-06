import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../providers/app_state.dart';

class AddNoteSheet extends StatefulWidget {
  final AppState appState;

  const AddNoteSheet({super.key, required this.appState});

  @override
  State<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<AddNoteSheet> {
  Project? _selectedProject;
  NoteCategory _selectedCategory = NoteCategory.bugFix;
  NotePriority _selectedPriority = NotePriority.medium;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _newProjectController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _newProjectController.dispose();
    super.dispose();
  }

  void _showNewProjectDialog() {
    _newProjectController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Yeni Proje',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: _newProjectController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Proje adı',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'İptal',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = _newProjectController.text.trim();
              if (name.isNotEmpty) {
                final project = Project(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  createdAt: DateTime.now(),
                );
                widget.appState.addProject(project);
                setState(() {
                  _selectedProject = project;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text(
              'Oluştur',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _saveNote() {
    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen bir proje seçin'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen bir not yazın'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: _selectedProject!.id,
      content: _noteController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      createdAt: DateTime.now(),
    );

    widget.appState.addNote(note);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Hızlı Not',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Project selector
              GestureDetector(
                onTap: () => _showProjectPicker(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _selectedProject != null
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedProject?.name ?? 'Proje Seç',
                          style: TextStyle(
                            color: _selectedProject != null
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Note text field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Notunuzu buraya yazın...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category label
              Text(
                'KATEGORİ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // Category buttons
              Row(
                children: [
                  _buildCategoryChip(
                    NoteCategory.bugFix,
                    'Hata Düzeltme',
                    const Color(0xFFE53935),
                  ),
                  const SizedBox(width: 10),
                  _buildCategoryChip(
                    NoteCategory.newFeature,
                    'Yeni Özellik',
                    const Color(0xFF43A047),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Priority label
              Text(
                'ÖNCELİK',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // Priority buttons
              Row(
                children: [
                  _buildPriorityChip(NotePriority.low, 'Düşük'),
                  const SizedBox(width: 10),
                  _buildPriorityChip(NotePriority.medium, 'Orta'),
                  const SizedBox(width: 10),
                  _buildPriorityChip(NotePriority.high, 'Yüksek'),
                ],
              ),
              const SizedBox(height: 28),

              // Save button (black & white, not blue)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildCategoryChip(NoteCategory category, String label, Color color) {
    final isSelected = _selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(NotePriority priority, String label) {
    final isSelected = _selectedPriority == priority;

    Color indicatorColor = const Color(0xFF78909C);
    switch (priority) {
      case NotePriority.low:
        indicatorColor = const Color(0xFF78909C);
        break;
      case NotePriority.medium:
        indicatorColor = const Color(0xFFFFA726);
        break;
      case NotePriority.high:
        indicatorColor = const Color(0xFFEF5350);
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = priority),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? indicatorColor.withValues(alpha: 0.12)
                : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? indicatorColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Priority bars
              _buildPriorityBars(priority, isSelected, indicatorColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? indicatorColor : Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBars(NotePriority priority, bool isSelected, Color color) {
    final activeColor = isSelected ? color : Colors.white.withValues(alpha: 0.3);
    final inactiveColor = Colors.white.withValues(alpha: 0.1);

    int activeBars = 1;
    switch (priority) {
      case NotePriority.low:
        activeBars = 1;
        break;
      case NotePriority.medium:
        activeBars = 2;
        break;
      case NotePriority.high:
        activeBars = 3;
        break;
    }

    return Row(
      children: List.generate(3, (index) {
        return Container(
          width: 3,
          height: 8 + (index * 3).toDouble(),
          margin: const EdgeInsets.only(right: 1.5),
          decoration: BoxDecoration(
            color: index < activeBars ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  void _showProjectPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF222222),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Proje Seç',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showNewProjectDialog();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Yeni Proje',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (widget.appState.projects.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Henüz bir proje yok',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Yeni bir proje oluşturun',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.25),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: widget.appState.projects.length,
                    itemBuilder: (ctx, index) {
                      final project = widget.appState.projects[index];
                      final isSelected = _selectedProject?.id == project.id;
                      return ListTile(
                        onTap: () {
                          setState(() => _selectedProject = project);
                          Navigator.pop(ctx);
                        },
                        leading: project.isGithubRepo
                            ? Icon(Icons.code_rounded, color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3), size: 18)
                            : Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                        title: Text(
                          project.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.7),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                            : null,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
