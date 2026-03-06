import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/app_state.dart';

class GithubSettingsScreen extends StatefulWidget {
  final AppState appState;

  const GithubSettingsScreen({super.key, required this.appState});

  @override
  State<GithubSettingsScreen> createState() => _GithubSettingsScreenState();
}

class _GithubSettingsScreenState extends State<GithubSettingsScreen> {
  final _tokenController = TextEditingController();
  bool _isTokenVisible = false;
  String? _error;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _error = 'Lütfen bir token girin');
      return;
    }

    final err = await widget.appState.connectGithub(token);
    if (err != null) {
      setState(() => _error = err);
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _disconnect() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('GitHub Bağlantısını Kes', style: TextStyle(color: Colors.white)),
        content: const Text(
          'GitHub hesabının bağlantısı kesilecek ve tüm GitHub repoları projeler listesinden kaldırılacak. Devam etmek istiyor musun?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kes', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.appState.disconnectGithub();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('GitHub', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListenableBuilder(
        listenable: widget.appState,
        builder: (context, _) {
          if (widget.appState.isGithubConnected) {
            return _buildConnectedView();
          }
          return _buildConnectView();
        },
      ),
    );
  }

  Widget _buildConnectedView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: widget.appState.githubAvatarUrl != null
                      ? Image.network(
                          widget.appState.githubAvatarUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          color: const Color(0xFF2A2A2A),
                          child: const Icon(Icons.person, color: Colors.white54),
                        ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.appState.githubUsername ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.appState.githubProjects.length} repo bağlı',
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Bağlı',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          _buildActionTile(
            icon: Icons.refresh_rounded,
            title: 'Repoları Yenile',
            subtitle: 'GitHub\'dan en güncel repo listesini çek',
            onTap: () async {
              await widget.appState.refreshGithubRepos();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Repolar güncellendi'),
                    backgroundColor: Color(0xFF1E1E1E),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 12),

          _buildActionTile(
            icon: Icons.link_off_rounded,
            title: 'Bağlantıyı Kes',
            subtitle: 'GitHub hesabını kaldır',
            color: Colors.redAccent,
            onTap: _disconnect,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GitHub logo & title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(Icons.code, color: Colors.black, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'GitHub\'a Bağlan',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'GitHub repolarını proje olarak ekle ve notlarını yönet',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Token input
          const Text('Personal Access Token', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _tokenController,
            obscureText: !_isTokenVisible,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'ghp_xxxxxxxxxxxx',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white38),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isTokenVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: () => setState(() => _isTokenVisible = !_isTokenVisible),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],

          const SizedBox(height: 16),

          // Connect button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.appState.isGithubLoading ? null : _connect,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: widget.appState.isGithubLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Bağlan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),

          const SizedBox(height: 24),

          // How to get token
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF222222)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Token nasıl alınır?',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _buildStep('1', 'GitHub → Settings → Developer settings'),
                _buildStep('2', 'Personal access tokens → Tokens (classic)'),
                _buildStep('3', 'Generate new token → "repo" iznini seç'),
                _buildStep('4', 'Token\'ı kopyala ve yukarıya yapıştır'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(
                      text: 'https://github.com/settings/tokens/new',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link kopyalandı! Tarayıcıda açın.'),
                        backgroundColor: Color(0xFF1E1E1E),
                      ),
                    );
                  },
                  child: const Text(
                    'GitHub Token Sayfasını Aç →',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(number, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
