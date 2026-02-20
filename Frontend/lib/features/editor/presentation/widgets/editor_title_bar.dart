import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/widgets/auth_status_chip.dart';





class EditorTitleBar extends StatelessWidget {
  final String? currentFileName;
  final bool isModified;
  final bool showExplorer;
  final bool showStats;
  final VoidCallback onToggleExplorer;
  final VoidCallback onToggleStats;
  final VoidCallback onShowSettings;
  final List<TitleBarMenu> menus;

  const EditorTitleBar({
    super.key,
    this.currentFileName,
    this.isModified = false,
    required this.showExplorer,
    required this.showStats,
    required this.onToggleExplorer,
    required this.onToggleStats,
    required this.onShowSettings,
    required this.menus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: AppTheme.titleBarBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 13,
                ),
                SizedBox(width: 4),
                Text(
                  'SyllApp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          for (final menu in menus) _buildMenuItem(menu),
          const Spacer(),
          
          _buildToggleButton(
            icon: Icons.folder_outlined,
            tooltip: 'Eksplorator',
            isActive: showExplorer,
            onPressed: onToggleExplorer,
          ),
          const SizedBox(width: 4),
          _buildToggleButton(
            icon: Icons.bar_chart,
            tooltip: 'Statystyki',
            isActive: showStats,
            onPressed: onToggleStats,
          ),
          const SizedBox(width: 4),
          if (!kOfflineOnly) const AuthStatusChip(compact: true),
          if (!kOfflineOnly) const SizedBox(width: 4),
          
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 16),
            color: AppTheme.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: onShowSettings,
            tooltip: 'Ustawienia',
          ),
          const SizedBox(width: 8),
          
          if (currentFileName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.editorBackground,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description_outlined,
                      size: 12, color: AppTheme.iconFile),
                  const SizedBox(width: 4),
                  Text(
                    '${isModified ? "● " : ""}$currentFileName',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accent.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
            border:
                isActive ? Border.all(color: AppTheme.accent, width: 1) : null,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive ? AppTheme.accent : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(TitleBarMenu menu) {
    return PopupMenuButton<MenuAction>(
      tooltip: '',
      offset: const Offset(0, 32),
      color: AppTheme.sidebarBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppTheme.border, width: 1),
      ),
      itemBuilder: (ctx) => menu.actions
          .map((action) => PopupMenuItem<MenuAction>(
                value: action,
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      action.label,
                      style: TextStyle(
                        color: action.onTap != null
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                        fontSize: 12,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                    if (action.shortcut != null)
                      Text(
                        action.shortcut!,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                  ],
                ),
              ))
          .toList(),
      onSelected: (action) => action.onTap?.call(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 32,
        alignment: Alignment.center,
        child: Text(
          menu.label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontFamily: 'Segoe UI',
          ),
        ),
      ),
    );
  }
}


class TitleBarMenu {
  final String label;
  final List<MenuAction> actions;

  const TitleBarMenu(this.label, this.actions);
}


class MenuAction {
  final String label;
  final VoidCallback? onTap;
  final String? shortcut;

  const MenuAction(this.label, this.onTap, [this.shortcut]);
}
