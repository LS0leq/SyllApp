import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/result.dart';
import '../../../core/project/project.dart';
import '../../../core/utils/platform_utils.dart' as platform;
import '../domain/repositories/project_repository.dart';
import 'project_infra_providers.dart';
import 'project_state.dart';


class ProjectNotifier extends Notifier<ProjectState> {
  ProjectRepository get _repository => ref.read(projectRepositoryProvider);

  
  bool get isMobile => kIsWeb || platform.isNativeMobile;

  @override
  ProjectState build() {
    return const ProjectState(isLoading: true);
  }

  
  Future<void> init() async {
    final dirResult = await _repository.initProjectsDirectory();
    final directory = dirResult.getOrElse(() => '');
    final recentProjects = await _repository.loadRecentProjects();
    final currentProject = await _repository.loadCurrentProject();

    state = ProjectState(
      recentProjects: recentProjects,
      currentProject: currentProject,
      projectsDirectory: directory.isEmpty ? null : directory,
      isLoading: false,
    );

    
    if (isMobile) {
      await refreshProjects();
    }
  }

  
  Future<void> refreshProjects() async {
    final directory = state.projectsDirectory;
    if (directory == null) return;

    final filesResult = await _repository.listProjectFiles(directory);
    if (filesResult.isFailure) return;

    final files = (filesResult as Success).value;
    var projects = List<Project>.from(state.recentProjects);

    for (final f in files) {
      final exists = projects.any((p) => p.path == f.path);
      if (!exists) {
        projects.add(Project(
          name: f.name,
          path: f.path,
          created: f.created,
          lastOpened: f.modified,
        ));
      }
    }

    
    projects.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));

    
    final validProjects = <Project>[];
    for (final project in projects) {
      if (await _repository.fileExists(project.path)) {
        validProjects.add(project);
      }
    }

    state = state.copyWith(recentProjects: validProjects);
    await _repository.saveRecentProjects(validProjects);
  }

  
  Future<(Project?, String?)> createProject({required String name}) async {
    var directory = state.projectsDirectory;
    if (directory == null) {
      final dirResult = await _repository.initProjectsDirectory();
      if (dirResult.isSuccess) {
        directory = (dirResult as Success<String>).value;
        state = state.copyWith(projectsDirectory: () => directory);
      }
    }
    if (directory == null) return (null, null);

    try {
      final safeName = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final expectedPath = '$directory${platform.pathSeparator}$safeName.txt';

      
      if (await _repository.fileExists(expectedPath)) {
        final existing =
            state.recentProjects.where((p) => p.path == expectedPath).firstOrNull;
        if (existing != null) {
          await openProject(existing);
          return (existing, expectedPath);
        }
      }

      final fileResult = await _repository.createProjectFile(directory, safeName);
      final filePath = fileResult.getOrElse(() => '');
      if (filePath.isEmpty) return (null, null);

      final now = DateTime.now();
      final project = Project(
        name: safeName,
        path: filePath,
        created: now,
        lastOpened: now,
      );

      await _addToRecent(project);
      await setCurrentProject(project);

      return (project, filePath);
    } catch (e) {
      debugPrint('Błąd tworzenia projektu: $e');
      return (null, null);
    }
  }

  
  Future<(Project?, String?)> createProjectWithPath({
    required String name,
    required String path,
  }) async {
    String? initialFilePath;

    if (!kIsWeb && platform.isNativeDesktop) {
      final result = await _repository.createProjectFolder(path, name);
      initialFilePath = result.getOrElse(() => '');
      if (initialFilePath.isEmpty) initialFilePath = null;
    }

    final now = DateTime.now();
    final project = Project(
      name: name,
      path: path,
      created: now,
      lastOpened: now,
    );

    await _addToRecent(project);
    await setCurrentProject(project);

    return (project, initialFilePath);
  }

  
  Future<void> openProject(Project project) async {
    final updatedProject = project.copyWithLastOpened(DateTime.now());
    await _addToRecent(updatedProject);
    await setCurrentProject(updatedProject);
  }

  
  Future<String?> openProjectAndLoadContent(Project project) async {
    try {
      debugPrint('Opening project: ${project.name} at ${project.path}');
      await openProject(project);
      final result = await _repository.readProjectContent(project.path);
      final content = result.getOrElse(() => '');
      debugPrint('Loaded content: ${content.length} chars');
      return content;
    } catch (e, stackTrace) {
      debugPrint('Error opening project: $e');
      debugPrint('Stack trace: $stackTrace');
      return '';
    }
  }

  
  Future<Project?> openProjectByPath(String path) async {
    final existing =
        state.recentProjects.where((p) => p.path == path).firstOrNull;
    if (existing != null) {
      await openProject(existing);
      return state.currentProject;
    }

    final name = path.split(RegExp(r'[/\\]')).last.replaceAll('.txt', '');
    final now = DateTime.now();
    final project = Project(
      name: name,
      path: path,
      created: now,
      lastOpened: now,
    );

    await _addToRecent(project);
    await setCurrentProject(project);
    return project;
  }

  
  Future<bool> saveCurrentProject(String content) async {
    final current = state.currentProject;
    if (current == null) return false;
    final result = await _repository.writeProjectContent(current.path, content);
    if (result.isSuccess) {
      markCurrentProjectModified();
    }
    return result.isSuccess;
  }

  
  Future<String?> readProjectContent(Project project) async {
    final result = await _repository.readProjectContent(project.path);
    return switch (result) {
      Success(:final value) => value,
      Err() => null,
    };
  }

  
  Future<bool> renameProject(Project project, String newName) async {
    try {
      final safeName = newName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final renameResult = await _repository.renameProjectFile(project.path, safeName);
      if (renameResult.isFailure) return false;

      final newPath = (renameResult as Success<String>).value;
      final updatedProject = Project(
        name: safeName,
        path: newPath,
        created: project.created,
        lastOpened: DateTime.now(),
      );

      final projects = List<Project>.from(state.recentProjects);
      final index = projects.indexWhere((p) => p.path == project.path);
      if (index >= 0) {
        projects[index] = updatedProject;
      }

      final currentProject = state.currentProject?.path == project.path
          ? updatedProject
          : state.currentProject;

      state = state.copyWith(
        recentProjects: projects,
        currentProject: () => currentProject,
      );

      await _repository.saveRecentProjects(projects);
      await _repository.saveCurrentProject(currentProject);
      return true;
    } catch (e) {
      debugPrint('Błąd zmiany nazwy projektu: $e');
      return false;
    }
  }

  
  Future<bool> deleteProject(Project project) async {
    try {
      await _repository.deleteProjectFile(project.path);

      final projects = List<Project>.from(state.recentProjects)
        ..removeWhere((p) => p.path == project.path);

      final currentProject = state.currentProject?.path == project.path
          ? null
          : state.currentProject;

      state = state.copyWith(
        recentProjects: projects,
        currentProject: () => currentProject,
      );

      await _repository.saveRecentProjects(projects);
      await _repository.saveCurrentProject(currentProject);
      return true;
    } catch (e) {
      debugPrint('Błąd usuwania projektu: $e');
      return false;
    }
  }

  

  
  Future<void> updateProjectsAfterSync(List<Project> projects) async {
    state = state.copyWith(recentProjects: projects);
    await _repository.saveRecentProjects(projects);

    
    final current = state.currentProject;
    if (current != null) {
      final synced = projects.where((p) => p.path == current.path).firstOrNull;
      if (synced != null) {
        state = state.copyWith(currentProject: () => synced);
        await _repository.saveCurrentProject(synced);
      }
    }
  }

  
  Future<void> updateSingleProjectAfterSync(Project updated) async {
    final projects = List<Project>.from(state.recentProjects);
    final index = projects.indexWhere((p) => p.path == updated.path);
    if (index >= 0) {
      projects[index] = updated;
    }

    state = state.copyWith(recentProjects: projects);
    await _repository.saveRecentProjects(projects);

    
    if (state.currentProject?.path == updated.path) {
      state = state.copyWith(currentProject: () => updated);
      await _repository.saveCurrentProject(updated);
    }
  }

  
  void markCurrentProjectModified() {
    final current = state.currentProject;
    if (current == null) return;
    if (current.cloudId == null) return; 
    if (current.syncStatus == SyncStatus.modified) return; 

    final modified = current.copyWith(syncStatus: SyncStatus.modified);

    final projects = List<Project>.from(state.recentProjects);
    final index = projects.indexWhere((p) => p.path == current.path);
    if (index >= 0) {
      projects[index] = modified;
    }

    state = state.copyWith(
      recentProjects: projects,
      currentProject: () => modified,
    );

    
    _repository.saveRecentProjects(projects);
    _repository.saveCurrentProject(modified);
  }

  
  Future<void> setCurrentProject(Project? project) async {
    state = state.copyWith(currentProject: () => project);
    await _repository.saveCurrentProject(project);
  }

  
  Future<void> closeProject() async {
    state = state.copyWith(currentProject: () => null);
    await _repository.saveCurrentProject(null);
  }

  
  Future<void> removeFromRecent(Project project) async {
    final projects = List<Project>.from(state.recentProjects)
      ..removeWhere((p) => p.path == project.path);
    state = state.copyWith(recentProjects: projects);
    await _repository.saveRecentProjects(projects);
  }

  
  Future<void> _addToRecent(Project project) async {
    final projects = List<Project>.from(state.recentProjects)
      ..removeWhere((p) => p.path == project.path);

    projects.insert(0, project);

    const maxRecentProjects = 20;
    final trimmed = projects.length > maxRecentProjects
        ? projects.take(maxRecentProjects).toList()
        : projects;

    state = state.copyWith(recentProjects: trimmed);
    await _repository.saveRecentProjects(trimmed);
  }
}
