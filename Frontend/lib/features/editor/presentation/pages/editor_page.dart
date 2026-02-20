import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/editor_providers.dart';
import '../../application/editor_notifier.dart';
import '../widgets/verse_editor.dart';
import '../widgets/stats_panel.dart';
import '../widgets/project_tree_panel.dart';
import '../widgets/status_bar.dart';
import '../widgets/resizable_panel.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/mobile_editor_layout.dart';
import '../widgets/editor_title_bar.dart';
import '../widgets/editor_keyboard_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../project/application/project_providers.dart';
import '../../../project/presentation/widgets/recent_projects_panel.dart';
import '../../../project/presentation/pages/welcome_screen.dart';

class EditorPage extends ConsumerStatefulWidget {
  final String? initialFilePath;
  
  const EditorPage({super.key, this.initialFilePath});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  final TextEditingController _textController = TextEditingController();
  
  
  bool _showExplorer = true;
  bool _showStats = true;

  
  bool _updatingFromState = false;

  
  final GlobalKey<ProjectTreePanelState> _projectTreeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(editorNotifierProvider.notifier);
      if (widget.initialFilePath != null) {
        notifier.loadFile(widget.initialFilePath!);
      } else {
        notifier.loadCurrentProjectContent();
      }
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_updatingFromState) return;
    ref.read(editorNotifierProvider.notifier).updateText(_textController.text);
  }

  void _onCursorChanged(int lineIndex, String currentWord) {
    if (!mounted) return;
    final text = _textController.text;
    final cursorPos = _textController.selection.baseOffset;
    int column = 1;
    if (cursorPos >= 0) {
      final beforeCursor = text.substring(0, cursorPos);
      final lines = beforeCursor.split('\n');
      column = lines.isNotEmpty ? lines.last.length + 1 : 1;
    }
    ref.read(editorNotifierProvider.notifier).updateCursor(lineIndex + 1, column);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  Future<String?> _showNameDialog(String title, [String label = 'Nazwa']) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.sidebarBackground,
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.border)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Anuluj', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Utwórz', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  
  bool get _hasNativeFileSystem => ResponsiveUtils.hasNativeFileSystem;

  void _closeProject() async {
    final navigator = Navigator.of(context);
    await ref.read(editorNotifierProvider.notifier).closeProject();
    if (mounted) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorNotifierProvider);

    
    if (_textController.text != editorState.content) {
      _updatingFromState = true;
      _textController.text = editorState.content;
      _updatingFromState = false;
    }

    
    final useDesktopLayout = ResponsiveUtils.shouldUseDesktopLayout(context);

    if (!useDesktopLayout) {
      return MobileEditorLayout(
        lyricModel: editorState.lyricModel,
        controller: _textController,
        onCursorChanged: _onCursorChanged,
        onFileSelected: (path, content) {
          ref.read(editorNotifierProvider.notifier).onFileSelected(path, content);
        },
        onSaveFile: () => ref.read(editorNotifierProvider.notifier).saveFile(),
        onNewFile: () async {
          final name = await _showNameDialog('Nowy projekt');
          if (name != null && name.isNotEmpty) {
            ref.read(editorNotifierProvider.notifier).newProject(name);
          }
        },
        onOpenFile: () => ref.read(editorNotifierProvider.notifier).openFile(),
        onShowSettings: _showSettingsDialog,
        onCloseProject: _closeProject,
        currentFileName: editorState.currentFileName,
        currentFilePath: editorState.currentFilePath,
        isModified: editorState.isModified,
        currentLine: editorState.currentLine,
        currentColumn: editorState.currentColumn,
      );
    }

    
    return _buildDesktopLayout(editorState);
  }

  Widget _buildDesktopLayout(dynamic editorState) {
    final notifier = ref.read(editorNotifierProvider.notifier);

    return EditorKeyboardHandler(
      onSave: () => notifier.saveFile(),
      onOpen: _hasNativeFileSystem ? () => notifier.openFile() : null,
      onNewFile: () async {
        if (_hasNativeFileSystem) {
          final name = await _showNameDialog('Nowy plik');
          if (name != null && name.isNotEmpty) {
            await notifier.createNewFileInProject(name);
            _projectTreeKey.currentState?.refresh();
          }
        } else {
          final name = await _showNameDialog('Nowy projekt');
          if (name != null && name.isNotEmpty) {
            notifier.newProject(name);
          }
        }
      },
      onToggleExplorer: () => setState(() => _showExplorer = !_showExplorer),
      child: Scaffold(
        body: Column(
          children: [
            
            EditorTitleBar(
              currentFileName: editorState.currentFileName,
              isModified: editorState.isModified,
              showExplorer: _showExplorer,
              showStats: _showStats,
              onToggleExplorer: () => setState(() => _showExplorer = !_showExplorer),
              onToggleStats: () => setState(() => _showStats = !_showStats),
              onShowSettings: _showSettingsDialog,
              menus: _buildMenus(notifier),
            ),
            
            Expanded(
              child: ResizablePanel(
                showLeftPanel: _showExplorer,
                showRightPanel: _showStats,
                leftPanel: _buildLeftPanel(notifier),
                centerPanel: editorState.isFileOpen
                    ? VerseEditor(
                        lyricModel: editorState.lyricModel,
                        controller: _textController,
                        onTextChanged: (text) {},
                        onCursorChanged: _onCursorChanged,
                      )
                    : _buildEmptyState(notifier),
                rightPanel: StatsPanel(
                  lyricModel: editorState.lyricModel,
                ),
              ),
            ),
            
            StatusBar(
              lineCount: editorState.lyricModel.lineCount,
              totalSyllables: editorState.lyricModel.totalSyllables,
              currentLine: editorState.currentLine,
              currentColumn: editorState.currentColumn,
              rhymeScheme: editorState.lyricModel.rhymeScheme.isNotEmpty
                  ? editorState.lyricModel.rhymeScheme
                  : null,
              fileName: editorState.currentFileName,
            ),
          ],
        ),
      ),
    );
  }

  

  
  
  
  List<TitleBarMenu> _buildMenus(EditorNotifier notifier) {
    final fileActions = <MenuAction>[
      MenuAction(
        _hasNativeFileSystem ? 'Nowy plik' : 'Nowy projekt',
        () async {
          if (_hasNativeFileSystem) {
            final name = await _showNameDialog('Nowy plik');
            if (name != null && name.isNotEmpty) {
              await notifier.createNewFileInProject(name);
              _projectTreeKey.currentState?.refresh();
            }
          } else {
            final name = await _showNameDialog('Nowy projekt');
            if (name != null && name.isNotEmpty) {
              notifier.newProject(name);
            }
          }
        },
        'Ctrl+N',
      ),
      if (_hasNativeFileSystem)
        MenuAction('Otwórz plik...', () => notifier.openFile(), 'Ctrl+O'),
      MenuAction('Zapisz', () => notifier.saveFile(), 'Ctrl+S'),
      MenuAction('Zamknij projekt', _closeProject),
    ];

    return [
      TitleBarMenu('Plik', fileActions),
      TitleBarMenu('Edycja', [
        const MenuAction('Cofnij', null, 'Ctrl+Z'),
        const MenuAction('Ponów', null, 'Ctrl+Y'),
      ]),
      TitleBarMenu('Widok', [
        MenuAction(
          _showExplorer ? '✓ Projekty' : '  Projekty',
          () => setState(() => _showExplorer = !_showExplorer),
          'Ctrl+B',
        ),
        MenuAction(
          _showStats ? '✓ Statystyki' : '  Statystyki',
          () => setState(() => _showStats = !_showStats),
          'Ctrl+Shift+S',
        ),
      ]),
    ];
  }

  
  
  
  Widget _buildLeftPanel(EditorNotifier notifier) {
    if (_hasNativeFileSystem) {
      return ProjectTreePanel(
        key: _projectTreeKey,
        currentDirectory: ref.watch(currentProjectProvider)?.path,
        selectedFilePath: ref.watch(editorNotifierProvider).currentFilePath,
        onFileSelected: (path, content) {
          notifier.onFileSelected(path, content);
        },
      );
    }

    return RecentProjectsPanel(
      onProjectSelected: (project) async {
        final content = await ref
            .read(projectNotifierProvider.notifier)
            .openProjectAndLoadContent(project);
        if (content != null) {
          notifier.onFileSelected(project.path, content);
        }
      },
    );
  }

  
  Widget _buildEmptyState(EditorNotifier notifier) {
    final actionLabel = _hasNativeFileSystem ? 'Utwórz nowy plik' : 'Utwórz nowy projekt';
    final dialogTitle = _hasNativeFileSystem ? 'Nowy plik' : 'Nowy projekt';
    final hint = _hasNativeFileSystem
        ? 'Wybierz plik z eksploratora po lewej stronie\nalbo utwórz nowy (Ctrl+N)'
        : 'Wybierz tekst z panelu po lewej stronie\nalbo utwórz nowy (Ctrl+N)';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'Nie wybrano pliku',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              final name = await _showNameDialog(dialogTitle);
              if (name != null && name.isNotEmpty) {
                if (_hasNativeFileSystem) {
                  await notifier.createNewFileInProject(name);
                  _projectTreeKey.currentState?.refresh();
                } else {
                  notifier.newProject(name);
                }
              }
            },
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accent,
              side: const BorderSide(color: AppTheme.accent),
            ),
          ),
        ],
      ),
    );
  }
}
