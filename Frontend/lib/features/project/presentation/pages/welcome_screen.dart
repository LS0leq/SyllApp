import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/platform_utils.dart' as platform;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/top_toast.dart';
import '../../../../core/project/project.dart';
import '../../application/project_providers.dart';
import '../widgets/create_project_dialog.dart';
import '../../../editor/presentation/pages/editor_page.dart';
import '../../../auth/presentation/widgets/auth_status_chip.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../auth/application/auth_state.dart';



class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {

  Future<void> _createNewProject() async {
    final result = await showDialog<(Project?, String?)>(
      context: context,
      builder: (context) => const CreateProjectDialog(),
    );

    if (result != null && result.$1 != null && mounted) {
      _navigateToEditor(initialFilePath: result.$2);
    }
  }

  Future<void> _openExistingProject() async {
    
    if (kIsWeb || platform.isNativeMobile) {
      TopToast.show(
        context,
        message: 'Otwieranie folderów niedostępne na tej platformie',
        color: AppTheme.errorColor,
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      await ref.read(projectNotifierProvider.notifier).openProjectByPath(result);
      if (mounted) {
        _navigateToEditor();
      }
    }
  }

  void _openRecentProject(Project project) async {
    await ref.read(projectNotifierProvider.notifier).openProject(project);
    if (mounted) {
      _navigateToEditor();
    }
  }

  void _removeRecentProject(Project project) async {
    await ref.read(projectNotifierProvider.notifier).removeFromRecent(project);
  }

  Future<void> _triggerSync() async {
    triggerSync(ref);
  }

  void _navigateToEditor({String? initialFilePath}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => EditorPage(initialFilePath: initialFilePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final padding = isMobile ? 24.0 : 48.0;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    const Color(0xFF1A1A2E).withValues(alpha: 0.3),
                    const Color(0xFF0A0A0F),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 800),
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    _buildHeader(isMobile),
                    SizedBox(height: isMobile ? 24 : 48),
                    
                    Expanded(
                      child: isMobile
                          ? _buildMobileContent()
                          : _buildDesktopContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionsSection(isMobile: true),
        const SizedBox(height: 24),
        Expanded(child: _buildRecentProjectsSection()),
      ],
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Expanded(
          flex: 3,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: _buildActionsSection(isMobile: false),
            ),
          ),
        ),
        const SizedBox(width: 48),
        
        Expanded(
          flex: 4,
          child: _buildRecentProjectsSection(),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accent,
                    const Color(0xFF6C63FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.appleRadiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: isMobile ? 20 : 24,
                  ),
                  SizedBox(width: isMobile ? 6 : 8),
                  Text(
                    'SyllApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro Display',
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (!kOfflineOnly) const AuthStatusChip(),
          ],
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Text(
          'Witaj w SyllApp!',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 28 : 34,
            fontWeight: FontWeight.w700,
            fontFamily: 'SF Pro Display',
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Twórz i analizuj teksty muzyczne',
          style: TextStyle(
            color: AppTheme.appleSystemGray,
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w400,
            fontFamily: 'SF Pro Text',
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection({required bool isMobile}) {
    final isDesktop = !kIsWeb && platform.isNativeDesktop;
    final isLoggedIn = kOfflineOnly ? false : ref.watch(authNotifierProvider) is AuthAuthenticated;
    final syncState = kOfflineOnly ? null : ref.watch(syncNotifierProvider);
    
    return _GlassmorphicSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'SZYBKIE AKCJE',
            style: TextStyle(
              color: AppTheme.appleSystemGray2,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: AppTheme.appleSpacingM),
        _buildActionButton(
          icon: Icons.add_circle_rounded,
          label: isMobile ? 'Nowy projekt' : 'Nowy',
          tooltip: 'Utwórz nowy projekt',
          onTap: _createNewProject,
          useGradient: true,
        ),
        if (isDesktop) ...[
          const SizedBox(height: AppTheme.appleSpacingS),
          _buildActionButton(
            icon: Icons.folder_open_rounded,
            label: 'Otwórz folder',
            tooltip: 'Otwórz istniejący folder z projektem',
            onTap: _openExistingProject,
          ),
        ],
        if (isLoggedIn && syncState != null) ...[
          const SizedBox(height: AppTheme.appleSpacingS),
          _buildActionButton(
            icon: syncState.isSyncing
                ? Icons.sync_rounded
                : Icons.cloud_sync_rounded,
            label: syncState.isSyncing
                ? (isMobile ? 'Synchronizacja...' : 'Sync...')
                : (isMobile ? 'Synchronizuj' : 'Sync'),
            tooltip: syncState.isSyncing
                ? 'Trwa synchronizacja z chmurą'
                : 'Synchronizuj z chmurą',
            onTap: syncState.isSyncing ? () {} : _triggerSync,
          ),
          
          if (syncState.isSyncing && syncState.currentOperation != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                syncState.currentOperation!,
                style: const TextStyle(
                  color: AppTheme.appleSystemGray,
                  fontSize: 12,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ),
          if (!syncState.isSyncing && syncState.lastSyncTime != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                'Ostatnia sync: ${_formatTimeAgo(syncState.lastSyncTime!)}'
                '${syncState.totalSynced > 0 ? ' (↑${syncState.uploadedCount} ↓${syncState.downloadedCount} ↻${syncState.updatedCount})' : ''}',
                style: const TextStyle(
                  color: AppTheme.appleSystemGray,
                  fontSize: 12,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ),
          if (syncState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                syncState.error!,
                style: const TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 12,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ),
        ],
      ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    String? tooltip,
    required VoidCallback onTap,
    bool useGradient = false,
  }) {
    final button = _HoverButton(
      onTap: onTap,
      builder: (isHovered) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.appleSpacingL,
          vertical: AppTheme.appleSpacingM,
        ),
        decoration: BoxDecoration(
          color: useGradient 
              ? null 
              : (isHovered 
                  ? AppTheme.appleSystemGray6 
                  : AppTheme.appleCardBackground),
          gradient: useGradient
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accent,
                    const Color(0xFF6C63FF),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: useGradient
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppTheme.appleShadowSmall,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.appleSpacingS),
              decoration: BoxDecoration(
                color: useGradient 
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
              ),
              child: Icon(
                icon, 
                size: 24, 
                color: useGradient ? Colors.white : AppTheme.accent,
              ),
            ),
            const SizedBox(width: AppTheme.appleSpacingM),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: useGradient ? Colors.white : AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Text',
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.appleSpacingS),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: useGradient ? Colors.white.withValues(alpha: 0.8) : AppTheme.appleSystemGray,
            ),
          ],
        ),
      ),
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 500),
        child: button,
      );
    }
    
    return button;
  }

  Widget _buildRecentProjectsSection() {
    return _GlassmorphicSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'OSTATNIE PROJEKTY',
            style: TextStyle(
              color: AppTheme.appleSystemGray2,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: AppTheme.appleSpacingM),
          Expanded(
            child: Builder(
              builder: (context) {
                final recentProjects = ref.watch(recentProjectsProvider);
                if (recentProjects.isEmpty) {
                  return _buildEmptyRecentProjects();
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: recentProjects.length,
                  itemBuilder: (context, index) {
                    return _buildRecentProjectItem(recentProjects[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecentProjects() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.appleSpacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.appleSpacingM),
                decoration: BoxDecoration(
                  color: AppTheme.appleSystemGray6,
                  borderRadius: BorderRadius.circular(AppTheme.appleRadiusL),
                ),
                child: Icon(
                  Icons.folder_open_rounded,
                  size: 40,
                  color: AppTheme.appleSystemGray,
                ),
              ),
              const SizedBox(height: AppTheme.appleSpacingM),
              const Text(
                'Brak projektów',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppTheme.appleSpacingXS),
              const Text(
                'Utwórz nowy projekt, aby rozpocząć',
                style: TextStyle(
                  color: AppTheme.appleSystemGray,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'SF Pro Text',
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentProjectItem(Project project) {
    final timeAgo = _formatTimeAgo(project.lastOpened);

    return _HoverButton(
      onTap: () => _openRecentProject(project),
      builder: (isHovered) => Container(
        margin: const EdgeInsets.only(bottom: AppTheme.appleSpacingS),
        padding: const EdgeInsets.all(AppTheme.appleSpacingM),
        decoration: BoxDecoration(
          color: isHovered 
              ? AppTheme.appleSystemGray6 
              : AppTheme.appleCardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.appleShadowSmall,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.appleSpacingS),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accent.withValues(alpha: 0.2),
                    const Color(0xFF6C63FF).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.folder_rounded,
                size: 22,
                color: AppTheme.accent.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(width: AppTheme.appleSpacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Text',
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      color: AppTheme.appleSystemGray,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'SF Pro Text',
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.appleSpacingS),
            
            if (!kOfflineOnly && ref.watch(authNotifierProvider) is AuthAuthenticated) ...[
              _buildSyncStatusIcon(project.syncStatus),
              const SizedBox(width: 4),
            ],
            GestureDetector(
              onTap: () => _removeRecentProject(project),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.appleSystemGray5,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppTheme.appleSystemGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return const Tooltip(
          message: 'Zsynchronizowany',
          child: Icon(Icons.cloud_done_rounded, size: 16, color: Color(0xFF34C759)),
        );
      case SyncStatus.modified:
        return const Tooltip(
          message: 'Zmodyfikowany lokalnie',
          child: Icon(Icons.cloud_upload_rounded, size: 16, color: Color(0xFFFF9500)),
        );
      case SyncStatus.conflict:
        return const Tooltip(
          message: 'Konflikt',
          child: Icon(Icons.warning_rounded, size: 16, color: Color(0xFFFF3B30)),
        );
      case SyncStatus.local:
        return const Tooltip(
          message: 'Tylko lokalnie',
          child: Icon(Icons.phone_android_rounded, size: 16, color: AppTheme.appleSystemGray),
        );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mies. temu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} dni temu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} godz. temu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min temu';
    } else {
      return 'Przed chwilą';
    }
  }
}

class _HoverButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget Function(bool isHovered) builder;

  const _HoverButton({
    required this.onTap,
    required this.builder,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: widget.builder(_isHovered),
        ),
      ),
    );
  }
}

class _GlassmorphicSection extends StatelessWidget {
  final Widget child;
  const _GlassmorphicSection({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
