import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/project/project.dart';
import '../../application/project_providers.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../auth/application/auth_state.dart';



class RecentProjectsPanel extends ConsumerStatefulWidget {
  final Function(Project project)? onProjectSelected;
  final Function(String name)? onNewProject;

  const RecentProjectsPanel({
    super.key,
    this.onProjectSelected,
    this.onNewProject,
  });

  @override
  ConsumerState<RecentProjectsPanel> createState() => _RecentProjectsPanelState();
}

class _RecentProjectsPanelState extends ConsumerState<RecentProjectsPanel> {
  @override
  void initState() {
    super.initState();
    
    _refreshProjects();
  }

  Future<void> _refreshProjects() async {
    await ref.read(projectNotifierProvider.notifier).refreshProjects();
  }

  Future<void> _createNewProject() async {
    final name = await _showNewProjectDialog();
    if (!mounted) return;
    if (name != null && name.isNotEmpty) {
      final result = await ref.read(projectNotifierProvider.notifier).createProject(name: name);
      final project = result.$1;
      if (project != null && mounted) {
        
        
        widget.onProjectSelected?.call(project);
      }
    }
  }
  
  Future<String?> _showNewProjectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.sidebarBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: AppTheme.accent, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Nowy tekst', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Nazwa tekstu...',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.editorBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (v) => Navigator.of(ctx).pop(v),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Anuluj', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Utwórz'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showProjectOptions(Project project) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.sidebarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.editorBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.description_outlined, color: AppTheme.iconFile, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.name, style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                        Text(_formatDate(project.lastOpened), style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.border),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined, color: AppTheme.accent, size: 22),
              ),
              title: const Text('Zmień nazwę', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
              onTap: () {
                Navigator.of(ctx).pop();
                _renameProject(project);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 22),
              ),
              title: const Text('Usuń', style: TextStyle(color: AppTheme.errorColor, fontSize: 15)),
              onTap: () {
                Navigator.of(ctx).pop();
                _deleteProject(project);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Future<void> _renameProject(Project project) async {
    final controller = TextEditingController(text: project.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.sidebarBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Zmień nazwę', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Nowa nazwa...',
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.editorBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.accent, width: 2),
            ),
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Anuluj', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
    
    if (newName != null && newName.isNotEmpty && newName != project.name) {
      await ref.read(projectNotifierProvider.notifier).renameProject(project, newName);
    }
  }
  
  Future<void> _deleteProject(Project project) async {
    
    bool deleteFromCloud = false;
    if (project.cloudId != null) {
      final choice = await showDialog<bool?>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.sidebarBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Usuń tekst?', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
            ],
          ),
          content: Text(
            '"${project.name}" jest zsynchronizowany z chmurą.\nCzy chcesz usunąć go również z serwera?',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Anuluj', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Tylko lokalnie'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Usuń wszędzie'),
            ),
          ],
        ),
      );
      if (choice == null) return; 
      deleteFromCloud = choice;
    } else {
      
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.sidebarBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Usuń tekst?', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
            ],
          ),
          content: Text(
            'Czy na pewno chcesz usunąć "${project.name}"?\n\nTej akcji nie można cofnąć.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Anuluj', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Usuń'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    
    if (deleteFromCloud && project.cloudId != null) {
      await ref.read(syncNotifierProvider.notifier).deleteCloudProject(project.cloudId!);
    }
    await ref.read(projectNotifierProvider.notifier).deleteProject(project);
  }

  @override
  Widget build(BuildContext context) {
    final recentProjects = ref.watch(recentProjectsProvider);
    final currentProject = ref.watch(currentProjectProvider);

    return Container(
      color: AppTheme.sidebarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'TWOJE TEKSTY',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                const Spacer(),
                
                Material(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: _createNewProject,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.add, size: 20, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: AppTheme.textSecondary),
                  onPressed: _refreshProjects,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.editorBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app, size: 16, color: AppTheme.textMuted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Przytrzymaj tekst, aby zmienić nazwę lub usunąć',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          if (currentProject != null)
            _buildCurrentProject(currentProject),
          
          if (currentProject != null && recentProjects.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Divider(color: AppTheme.border, height: 1),
            ),
          
          Expanded(
            child: recentProjects.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: recentProjects.length,
                    itemBuilder: (context, index) {
                      final project = recentProjects[index];
                      
                      if (currentProject != null && project.path == currentProject.path) {
                        return const SizedBox.shrink();
                      }
                      return _buildProjectItem(project);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentProject(Project project) {
    final isLoggedIn = ref.watch(authNotifierProvider) is AuthAuthenticated;
    return GestureDetector(
      onLongPress: () => _showProjectOptions(project),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => widget.onProjectSelected?.call(project),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_document, size: 22, color: AppTheme.accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Segoe UI',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Aktualny',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoggedIn) _buildSyncIcon(project.syncStatus),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectItem(Project project) {
    final isLoggedIn = ref.watch(authNotifierProvider) is AuthAuthenticated;
    return GestureDetector(
      onLongPress: () => _showProjectOptions(project),
      child: InkWell(
        onTap: () {
          widget.onProjectSelected?.call(project);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.editorBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_outlined, size: 22, color: AppTheme.iconFile),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Segoe UI',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(project.lastOpened),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoggedIn) ...[
                _buildSyncIcon(project.syncStatus),
                const SizedBox(width: 4),
              ],
              const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Dzisiaj';
    if (diff.inDays == 1) return 'Wczoraj';
    if (diff.inDays < 7) return '${diff.inDays} dni temu';
    return '${date.day}.${date.month}.${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.editorBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.note_add_outlined, size: 40, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            const Text(
              'Brak tekstów',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kliknij + aby utworzyć nowy tekst',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createNewProject,
              icon: const Icon(Icons.add),
              label: const Text('Nowy tekst'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncIcon(SyncStatus status) {
    final isSyncing = ref.watch(syncNotifierProvider).isSyncing;
    if (isSyncing) {
      return const Tooltip(
        message: 'Synchronizacja...',
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.accent,
          ),
        ),
      );
    }

    switch (status) {
      case SyncStatus.synced:
        return const Tooltip(
          message: 'Zsynchronizowany',
          child: Icon(Icons.cloud_done_rounded, size: 18, color: Color(0xFF34C759)),
        );
      case SyncStatus.modified:
        return const Tooltip(
          message: 'Zmodyfikowany lokalnie',
          child: Icon(Icons.cloud_upload_rounded, size: 18, color: Color(0xFFFF9500)),
        );
      case SyncStatus.conflict:
        return const Tooltip(
          message: 'Konflikt',
          child: Icon(Icons.warning_rounded, size: 18, color: Color(0xFFFF3B30)),
        );
      case SyncStatus.local:
        return const Tooltip(
          message: 'Tylko lokalnie',
          child: Icon(Icons.phone_android_rounded, size: 18, color: AppTheme.textMuted),
        );
    }
  }
}
