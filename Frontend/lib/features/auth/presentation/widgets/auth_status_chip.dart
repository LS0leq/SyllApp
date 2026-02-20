import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/auth_providers.dart';
import '../../application/auth_state.dart';
import '../../../project/application/project_providers.dart';






class AuthStatusChip extends ConsumerStatefulWidget {
  
  final bool compact;

  const AuthStatusChip({super.key, this.compact = false});

  @override
  ConsumerState<AuthStatusChip> createState() => _AuthStatusChipState();
}

class _AuthStatusChipState extends ConsumerState<AuthStatusChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    if (authState is AuthAuthenticated) {
      return _buildAuthenticated(context, ref, authState);
    }

    return _buildUnauthenticated(context);
  }

  Widget _buildAuthenticated(
    BuildContext context,
    WidgetRef ref,
    AuthAuthenticated state,
  ) {
    final syncState = ref.watch(syncNotifierProvider);
    final recentProjects = ref.watch(recentProjectsProvider);
    final cloudProjectsCount = recentProjects.where((p) => p.cloudId != null).length;
    
    if (widget.compact) {
      return PopupMenuButton<String>(
        tooltip: state.user.username,
        offset: const Offset(0, 32),
        color: AppTheme.sidebarBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppTheme.border, width: 1),
        ),
        onSelected: (value) {
          if (value == 'logout') {
            ref.read(authNotifierProvider.notifier).logout();
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem<String>(
            enabled: false,
            height: 40,
            child: Row(
              children: [
                const Icon(Icons.person, size: 14, color: AppTheme.accent),
                const SizedBox(width: 8),
                Text(
                  state.user.username,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            enabled: false,
            height: 28,
            child: Text(
              'Projekty w chmurze: $cloudProjectsCount',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          if (syncState.lastSyncTime != null && syncState.totalSynced > 0)
            PopupMenuItem<String>(
              enabled: false,
              height: 28,
              child: Text(
                'Ostatnia sync: ↑${syncState.uploadedCount} ↓${syncState.downloadedCount} ↻${syncState.updatedCount}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          const PopupMenuDivider(height: 8),
          const PopupMenuItem<String>(
            value: 'logout',
            height: 32,
            child: Row(
              children: [
                Icon(Icons.logout_rounded,
                    size: 14, color: AppTheme.textSecondary),
                SizedBox(width: 8),
                Text(
                  'Wyloguj się',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppTheme.accent.withValues(alpha: 0.3)
                  : AppTheme.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppTheme.accent, width: 1),
            ),
            child: const Icon(Icons.person, size: 16, color: AppTheme.accent),
          ),
        ),
      );
    }

    
    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 40),
      color: AppTheme.sidebarBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.border, width: 1),
      ),
      onSelected: (value) {
        if (value == 'logout') {
          ref.read(authNotifierProvider.notifier).logout();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          height: 36,
          child: Text(
            'Projekty w chmurze: $cloudProjectsCount',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        if (syncState.lastSyncTime != null && syncState.totalSynced > 0)
          PopupMenuItem<String>(
            enabled: false,
            height: 36,
            child: Text(
              'Ostatnia sync: ↑${syncState.uploadedCount} ↓${syncState.downloadedCount} ↻${syncState.updatedCount}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        const PopupMenuDivider(height: 8),
        const PopupMenuItem<String>(
          value: 'logout',
          height: 36,
          child: Row(
            children: [
              Icon(Icons.logout_rounded,
                  size: 16, color: AppTheme.textSecondary),
              SizedBox(width: 8),
              Text(
                'Wyloguj się',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.accent.withValues(alpha: 0.2)
                : AppTheme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                state.user.username,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthenticated(BuildContext context) {
    if (widget.compact) {
      return Tooltip(
        message: 'Zaloguj się',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/login'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _isHovered
                    ? Colors.grey.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Icon(
                Icons.person_outline,
                size: 16,
                color: _isHovered ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/login'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.grey.shade800
                : AppTheme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? Colors.grey.shade600
                  : AppTheme.accent.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.login_rounded,
                size: 16,
                color: _isHovered ? Colors.white : AppTheme.accent,
              ),
              const SizedBox(width: 6),
              Text(
                'Zaloguj się',
                style: TextStyle(
                  color: _isHovered ? Colors.white : AppTheme.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
