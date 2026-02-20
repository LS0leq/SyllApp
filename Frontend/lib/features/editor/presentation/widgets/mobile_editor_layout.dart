import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/lyric.dart';
import 'verse_editor.dart';
import 'stats_panel.dart';
import 'project_tree_panel.dart';
import '../../../auth/presentation/widgets/auth_status_chip.dart';
import '../../../project/application/project_providers.dart';
import '../../../project/presentation/widgets/recent_projects_panel.dart';



class MobileEditorLayout extends ConsumerStatefulWidget {
  final Lyric lyricModel;
  final TextEditingController controller;
  final void Function(int lineIndex, String currentWord) onCursorChanged;
  final void Function(String path, String content) onFileSelected;
  final VoidCallback onSaveFile;
  final VoidCallback onNewFile;
  final VoidCallback onOpenFile;
  final VoidCallback onShowSettings;
  final VoidCallback onCloseProject;
  final String? currentFileName;
  final String? currentFilePath;
  final bool isModified;
  final int currentLine;
  final int currentColumn;

  const MobileEditorLayout({
    super.key,
    required this.lyricModel,
    required this.controller,
    required this.onCursorChanged,
    required this.onFileSelected,
    required this.onSaveFile,
    required this.onNewFile,
    required this.onOpenFile,
    required this.onShowSettings,
    required this.onCloseProject,
    this.currentFileName,
    this.currentFilePath,
    this.isModified = false,
    this.currentLine = 1,
    this.currentColumn = 1,
  });

  @override
  ConsumerState<MobileEditorLayout> createState() => _MobileEditorLayoutState();
}

class _MobileEditorLayoutState extends ConsumerState<MobileEditorLayout> {
  int _currentIndex = 1; 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.editorBackground,
      appBar: _buildAppBar(),
      drawer: _buildExplorerDrawer(),
      endDrawer: _buildStatsDrawer(),
      onDrawerChanged: (isOpen) {
        if (!isOpen) {
          setState(() => _currentIndex = 1);
        }
      },
      onEndDrawerChanged: (isOpen) {
        if (!isOpen) {
          setState(() => _currentIndex = 1);
        }
      },
      body: Column(
        children: [
          Expanded(
            child: VerseEditor(
              lyricModel: widget.lyricModel,
              controller: widget.controller,
              onTextChanged: (text) {},
              onCursorChanged: widget.onCursorChanged,
            ),
          ),
          _buildMobileStatusBar(),
        ],
      ),
      floatingActionButton: widget.isModified
          ? Container(
              margin: const EdgeInsets.only(bottom: 72),
              child: FloatingActionButton(
                onPressed: widget.onSaveFile,
                backgroundColor: AppTheme.accent,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.appleRadiusM),
                ),
                child: const Icon(
                  Icons.save_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final currentProject = ref.watch(currentProjectProvider);
    final title = widget.currentFileName != null
        ? '${widget.isModified ? "● " : ""}${widget.currentFileName}'
        : currentProject?.name ?? 'SyllApp';

    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppTheme.appleRadiusM)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.appleBlur,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.border.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              boxShadow: AppTheme.appleShadowSmall,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.appleSpacingM,
                  vertical: AppTheme.appleSpacingXS,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.appleSystemGray5,
                          borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: AppTheme.textPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.appleSpacingM),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro Display',
                          letterSpacing: -0.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTheme.appleSpacingS),
                    if (!kOfflineOnly) const AuthStatusChip(compact: true),
                    if (!kOfflineOnly) const SizedBox(width: AppTheme.appleSpacingS),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.appleSystemGray5,
                          borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
                        ),
                        child: const Icon(
                          Icons.more_horiz_rounded,
                          color: AppTheme.textPrimary,
                          size: 22,
                        ),
                      ),
                      color: AppTheme.appleCardBackground,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.appleRadiusM),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'new':
                            widget.onNewFile();
                            break;
                          case 'open':
                            widget.onOpenFile();
                            break;
                          case 'save':
                            widget.onSaveFile();
                            break;
                          case 'settings':
                            widget.onShowSettings();
                            break;
                          case 'close':
                            widget.onCloseProject();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        _buildMenuItem(Icons.add_rounded, 'Nowy plik', 'new'),
                        _buildMenuItem(Icons.folder_open_rounded, 'Otwórz plik', 'open'),
                        _buildMenuItem(Icons.save_rounded, 'Zapisz', 'save'),
                        const PopupMenuDivider(),
                        _buildMenuItem(Icons.settings_rounded, 'Ustawienia', 'settings'),
                        _buildMenuItem(Icons.close_rounded, 'Zamknij projekt', 'close'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(IconData icon, String label, String value) {
    return PopupMenuItem<String>(
      value: value,
      height: 50,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.appleSpacingM,
        vertical: AppTheme.appleSpacingXS,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppTheme.accent),
          const SizedBox(width: AppTheme.appleSpacingS),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'SF Pro Text',
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplorerDrawer() {
    final currentProject = ref.watch(currentProjectProvider);
    
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(AppTheme.appleRadiusL)),
      child: Drawer(
        backgroundColor: AppTheme.appleCardBackground,
        elevation: 0,
        width: MediaQuery.of(context).size.width * 0.80,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: AppTheme.appleShadow,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.appleSpacingL),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.border.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.appleSpacingS),
                        decoration: BoxDecoration(
                          color: AppTheme.appleSystemGray5,
                          borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
                        ),
                        child: const Icon(
                          Icons.folder_rounded,
                          color: AppTheme.iconFolder,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppTheme.appleSpacingM),
                      Expanded(
                        child: Text(
                          currentProject?.name ?? 'Projekty',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro Display',
                            letterSpacing: -0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ResponsiveUtils.hasNativeFileSystem
                      ? ProjectTreePanel(
                          currentDirectory: currentProject?.path,
                          selectedFilePath: widget.currentFilePath,
                          onFileSelected: (path, content) {
                            widget.onFileSelected(path, content);
                            Navigator.of(context).pop();
                          },
                        )
                      : RecentProjectsPanel(
                          onProjectSelected: (project) async {
                            final navigator = Navigator.of(context);
                            final content = await ref.read(projectNotifierProvider.notifier).openProjectAndLoadContent(project);
                            if (!context.mounted) return;
                            if (content != null) {
                              widget.onFileSelected(project.path, content);
                              navigator.pop();
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsDrawer() {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppTheme.appleRadiusL)),
      child: Drawer(
        backgroundColor: AppTheme.appleCardBackground,
        elevation: 0,
        width: MediaQuery.of(context).size.width * 0.80,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: AppTheme.appleShadow,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.appleSpacingL),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.border.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.appleSpacingS),
                        decoration: BoxDecoration(
                          color: AppTheme.appleSystemGray5,
                          borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: AppTheme.accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppTheme.appleSpacingM),
                      const Text(
                        'Analiza',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro Display',
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StatsPanel(lyricModel: widget.lyricModel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileStatusBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.appleSpacingM,
        vertical: AppTheme.appleSpacingXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.appleSystemGray6.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: AppTheme.border.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.appleSpacingS,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.appleSystemGray5,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Ln ${widget.currentLine}, Col ${widget.currentColumn}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'SF Mono',
                letterSpacing: -0.2,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${widget.lyricModel.lineCount} linii',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              fontFamily: 'SF Pro Text',
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.appleRadiusL)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.appleBlur,
            border: Border(
              top: BorderSide(
                color: AppTheme.border.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.appleSpacingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.folder_outlined,
                    activeIcon: Icons.folder,
                    label: 'Pliki',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.edit_note_outlined,
                    activeIcon: Icons.edit_note,
                    label: 'Edytor',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.bar_chart_rounded,
                    activeIcon: Icons.bar_chart_rounded,
                    label: 'Analiza',
                    index: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = index);
          if (index == 0) {
            _scaffoldKey.currentState?.openDrawer();
          } else if (index == 2) {
            _scaffoldKey.currentState?.openEndDrawer();
          } else if (index == 1) {
            if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
              Navigator.of(context).pop();
            }
            if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
              Navigator.of(context).pop();
            }
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppTheme.accent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive ? AppTheme.accent : AppTheme.appleSystemGray,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppTheme.accent : AppTheme.appleSystemGray,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontFamily: 'SF Pro Text',
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
