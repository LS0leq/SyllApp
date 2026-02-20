import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/lyric.dart';
import '../domain/repositories/lyrics_repository.dart';
import '../../../core/config/app_config.dart';
import '../../../core/settings/settings_providers.dart';
import '../../../core/utils/platform_utils.dart' as platform;
import '../../../core/utils/native_file_utils.dart' as native_io;
import '../../project/application/project_notifier.dart';
import '../../project/application/project_providers.dart';
import '../../project/domain/repositories/project_repository.dart';
import 'editor_infra_providers.dart';
import 'editor_state.dart';

final editorNotifierProvider =
    NotifierProvider<EditorNotifier, EditorState>(EditorNotifier.new);


class EditorNotifier extends Notifier<EditorState> {
  Timer? _autoSaveTimer;

  LyricsRepository get _lyricsRepository => ref.read(lyricsRepositoryProvider);
  ProjectNotifier get _projectNotifier => ref.read(projectNotifierProvider.notifier);
  ProjectRepository get _projectRepository => ref.read(projectRepositoryProvider);

  @override
  EditorState build() {
    ref.listen(settingsNotifierProvider, (previous, next) {
      _setupAutoSaveTimer();
    });
    _setupAutoSaveTimer();

    ref.onDispose(() {
      _autoSaveTimer?.cancel();
    });

    return EditorState();
  }

  

  
  Future<void> loadCurrentProjectContent() async {
    final currentProject = ref.read(currentProjectProvider);
    if (currentProject == null) return;

    if (kIsWeb) {
      await _loadCurrentProjectContentWeb(currentProject.path, currentProject.name);
      return;
    }

    
    final resolvedPath = await native_io.resolveProjectFilePath(
      currentProject.path,
      currentProject.name,
    );
    if (resolvedPath == null) return;

    try {
      final content = await native_io.readNativeFile(resolvedPath);
      if (content != null) {
        final lyric = Lyric();
        lyric.updateFromLines(content.split('\n'));
        state = state.copyWith(
          content: content,
          currentFilePath: () => resolvedPath,
          currentFileName: () => resolvedPath.split(RegExp(r'[/\\]')).last,
          isModified: false,
          isFileOpen: true,
          lyricModel: lyric,
        );
      }
    } catch (e) {
      debugPrint('Błąd ładowania zawartości projektu: $e');
    }
  }

  
  Future<void> _loadCurrentProjectContentWeb(String path, String name) async {
    try {
      final result = await _projectRepository.readProjectContent(path);
      final content = result.getOrElse(() => '');
      final lyric = Lyric();
      lyric.updateFromLines(content.isEmpty ? [] : content.split('\n'));
      state = state.copyWith(
        content: content,
        currentFilePath: () => path,
        currentFileName: () => '$name.txt',
        isModified: false,
        isFileOpen: true,
        lyricModel: lyric,
      );
    } catch (e) {
      debugPrint('Błąd ładowania zawartości projektu web: $e');
    }
  }

  
  Future<void> loadFile(String filePath) async {
    if (kIsWeb) {
      
      try {
        final result = await _projectRepository.readProjectContent(filePath);
        final content = result.getOrElse(() => '');
        final lyric = Lyric();
        lyric.updateFromLines(content.split('\n'));
        state = state.copyWith(
          content: content,
          currentFilePath: () => filePath,
          currentFileName: () => filePath.split(RegExp(r'[/\\]')).last,
          isModified: false,
          isFileOpen: true,
          lyricModel: lyric,
        );
      } catch (e) {
        debugPrint('Błąd ładowania pliku web: $e');
      }
      return;
    }

    
    try {
      final content = await native_io.readNativeFile(filePath);
      if (content != null) {
        final lyric = Lyric();
        lyric.updateFromLines(content.split('\n'));
        state = state.copyWith(
          content: content,
          currentFilePath: () => filePath,
          currentFileName: () => filePath.split(RegExp(r'[/\\]')).last,
          isModified: false,
          isFileOpen: true,
          lyricModel: lyric,
        );
      }
    } catch (e) {
      debugPrint('Błąd ładowania pliku: $e');
    }
  }

  

  
  Future<void> openFile() async {
    final content = await _lyricsRepository.openFile();
    if (content != null) {
      final lyric = Lyric();
      lyric.updateFromLines(content.split('\n'));
      state = state.copyWith(
        content: content,
        isModified: false,
        isFileOpen: true,
        lyricModel: lyric,
      );
    }
  }

  
  Future<void> saveFile() async {
    
    if (!platform.isNativeDesktop) {
      final currentProject = ref.read(currentProjectProvider);
      if (currentProject != null) {
        final success = await _projectNotifier.saveCurrentProject(state.content);
        if (success) {
          state = state.copyWith(isModified: false);
          
          if (!kOfflineOnly) triggerSyncCurrentProject(ref);
        }
      }
      return;
    }

    
    final success = await _lyricsRepository.saveFile(
      state.content,
      filePath: state.currentFilePath,
    );
    if (success) {
      state = state.copyWith(isModified: false);
    }
  }

  
  Future<void> newFile() async {
    if (!platform.isNativeDesktop) return; 

    final lyric = Lyric();
    lyric.updateFromLines([]);
    state = EditorState(lyricModel: lyric, isFileOpen: true);
  }

  
  Future<void> createNewFileInProject(String fileName) async {
    if (kIsWeb) return; 

    final currentProject = ref.read(currentProjectProvider);
    if (currentProject == null) return;

    try {
      var safeName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      if (!safeName.endsWith('.txt')) {
        safeName += '.txt';
      }

      final filePath = '${currentProject.path}${platform.pathSeparator}$safeName';

      if (!await native_io.nativeFileExists(filePath)) {
        await native_io.writeNativeFile(filePath, '');
      }

      await loadFile(filePath);
    } catch (e) {
      debugPrint('Błąd tworzenia pliku w projekcie: $e');
    }
  }

  
  Future<void> newProject(String name) async {
    final result = await _projectNotifier.createProject(name: name);
    final project = result.$1;
    final filePath = result.$2;
    if (project != null && filePath != null) {
      final lyric = Lyric();
      lyric.updateFromLines([]);
      state = EditorState(
        currentFilePath: filePath,
        currentFileName: '$name.txt',
        isFileOpen: true,
        lyricModel: lyric,
      );
    }
  }

  
  Future<void> closeProject() async {
    final lyric = Lyric();
    lyric.updateFromLines([]);
    state = EditorState(lyricModel: lyric);
    await _projectNotifier.closeProject();
  }

  

  
  void updateText(String text) {
    final lyric = Lyric();
    lyric.updateFromLines(text.split('\n'));
    state = state.copyWith(
      content: text,
      isModified: true,
      lyricModel: lyric,
    );
    
    _projectNotifier.markCurrentProjectModified();
  }

  
  void updateCursor(int line, int column) {
    state = state.copyWith(
      currentLine: line,
      currentColumn: column,
    );
  }

  
  void onFileSelected(String path, String content) {
    final lyric = Lyric();
    lyric.updateFromLines(content.split('\n'));
    state = state.copyWith(
      content: content,
      currentFilePath: () => path,
      currentFileName: () => path.split(RegExp(r'[/\\]')).last,
      isModified: false,
      isFileOpen: true,
      lyricModel: lyric,
    );
  }

  

  void _setupAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    final settings = ref.read(settingsNotifierProvider);

    if (settings.autoSave) {
      _autoSaveTimer = Timer.periodic(
        Duration(minutes: settings.autoSaveIntervalMinutes),
        (_) {
          if (state.isModified && state.currentFilePath != null) {
            saveFile();
          }
        },
      );
    }
  }
}
