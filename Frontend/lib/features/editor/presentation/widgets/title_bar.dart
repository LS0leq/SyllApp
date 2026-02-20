import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TitleBar extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onOpen;
  final VoidCallback? onNewFile;
  final String? currentFileName;

  const TitleBar({
    super.key,
    this.onSave,
    this.onOpen,
    this.onNewFile,
    this.currentFileName,
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
          
          _buildMenuItem(context, 'Plik', [
            _MenuAction('Nowy plik', onNewFile, 'Ctrl+N'),
            _MenuAction('Otwórz plik...', onOpen, 'Ctrl+O'),
            _MenuAction('Zapisz', onSave, 'Ctrl+S'),
          ]),
          _buildMenuItem(context, 'Edycja', [
            _MenuAction('Cofnij', null, 'Ctrl+Z'),
            _MenuAction('Ponów', null, 'Ctrl+Y'),
            _MenuAction('Wytnij', null, 'Ctrl+X'),
            _MenuAction('Kopiuj', null, 'Ctrl+C'),
            _MenuAction('Wklej', null, 'Ctrl+V'),
          ]),
          _buildMenuItem(context, 'Widok', [
            _MenuAction('Pokaż/ukryj Eksplorator', null, 'Ctrl+B'),
            _MenuAction('Pokaż/ukryj Statystyki', null, 'Ctrl+Shift+S'),
          ]),
          _buildMenuItem(context, 'Pomoc', [
            _MenuAction('O programie SyllApp', () {
              showAboutDialog(
                context: context,
                applicationName: 'SyllApp',
                applicationVersion: '1.0.0',
                children: [
                  const Text('Edytor tekstów rap z wykrywaniem rymów.'),
                ],
              );
            }, null),
          ]),
          const Spacer(),
          
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
                  const Icon(Icons.description_outlined, size: 12, color: AppTheme.iconFile),
                  const SizedBox(width: 4),
                  Text(
                    currentFileName!,
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

  Widget _buildMenuItem(BuildContext context, String label, List<_MenuAction> actions) {
    return PopupMenuButton<_MenuAction>(
      tooltip: '',
      offset: const Offset(0, 32),
      color: AppTheme.sidebarBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppTheme.border, width: 1),
      ),
      itemBuilder: (ctx) => actions.map((action) => PopupMenuItem<_MenuAction>(
        value: action,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              action.label,
              style: TextStyle(
                color: action.onTap != null ? AppTheme.textPrimary : AppTheme.textMuted,
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
      )).toList(),
      onSelected: (action) => action.onTap?.call(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 32,
        alignment: Alignment.center,
        child: Text(
          label,
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

class _MenuAction {
  final String label;
  final VoidCallback? onTap;
  final String? shortcut;

  _MenuAction(this.label, this.onTap, [this.shortcut]);
}
