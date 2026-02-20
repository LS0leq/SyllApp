import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/result.dart';
import '../../../../core/project/project.dart';
import '../../domain/repositories/cloud_project_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../project_infra_providers.dart';
import 'sync_state.dart';


class SyncNotifier extends Notifier<SyncState> {
  CloudProjectRepository get _cloud => ref.read(cloudProjectRepositoryProvider);
  ProjectRepository get _local => ref.read(projectRepositoryProvider);

  @override
  SyncState build() {
    return const SyncState();
  }

  
  
  
  
  
  
  
  
  
  
  Future<List<Project>> syncAll(List<Project> localProjects) async {
    if (state.isSyncing) return localProjects;

    state = state.copyWith(
      isSyncing: true,
      error: () => null,
      uploadedCount: 0,
      downloadedCount: 0,
      updatedCount: 0,
      currentOperation: () => 'Łączenie z serwerem...',
    );

    var projects = List<Project>.from(localProjects);
    int uploaded = 0;
    int downloaded = 0;
    int updated = 0;

    try {
      
      state = state.copyWith(currentOperation: () => 'Pobieranie listy z chmury...');
      final cloudResult = await _cloud.fetchProjects();
      if (cloudResult.isFailure) {
        final failure = (cloudResult as Err).failure;
        state = state.copyWith(
          isSyncing: false,
          error: () => failure.message,
          currentOperation: () => null,
        );
        return localProjects;
      }

      final cloudProjects = (cloudResult as Success<List<CloudProject>>).value;

      
      final cloudProjectsByName = <String, CloudProject>{};
      for (final cp in cloudProjects) {
        cloudProjectsByName[cp.name] = cp;
      }

      
      for (int i = 0; i < projects.length; i++) {
        final project = projects[i];
        if (project.cloudId == null) {
          
          final existingCloud = cloudProjectsByName[project.name];
          if (existingCloud != null) {
            
            state = state.copyWith(
              currentOperation: () => 'Łączenie: ${project.name}...',
            );
            projects[i] = project.copyWith(
              cloudId: () => existingCloud.id,
              syncStatus: SyncStatus.synced,
            );
            
            final content = await _readLocalContent(project);
            await _cloud.updateProject(existingCloud.id, content: content);
            updated++;
          } else {
            
            state = state.copyWith(
              currentOperation: () => 'Wysyłanie: ${project.name}...',
            );
            final content = await _readLocalContent(project);
            final result = await _cloud.createProject(project.name, content);
            if (result.isSuccess) {
              final cloudProject = (result as Success<CloudProject>).value;
              projects[i] = project.copyWith(
                cloudId: () => cloudProject.id,
                syncStatus: SyncStatus.synced,
              );
              uploaded++;
            } else {
              debugPrint('[SyncNotifier] Upload failed for ${project.name}');
            }
          }
        }
      }

      
      for (int i = 0; i < projects.length; i++) {
        final project = projects[i];
        if (project.cloudId != null && project.syncStatus == SyncStatus.modified) {
          state = state.copyWith(
            currentOperation: () => 'Aktualizacja: ${project.name}...',
          );
          final content = await _readLocalContent(project);
          final result = await _cloud.updateProject(
            project.cloudId!,
            name: project.name,
            content: content,
          );
          if (result.isSuccess) {
            projects[i] = project.copyWith(syncStatus: SyncStatus.synced);
            updated++;
          } else {
            debugPrint('[SyncNotifier] Push failed for ${project.name}');
          }
        }
      }

      
      final localCloudIds = projects
          .where((p) => p.cloudId != null)
          .map((p) => p.cloudId!)
          .toSet();

      for (final cloudProject in cloudProjects) {
        if (!localCloudIds.contains(cloudProject.id)) {
          state = state.copyWith(
            currentOperation: () => 'Pobieranie: ${cloudProject.name}...',
          );

          
          final fullResult = await _cloud.getProject(cloudProject.id);
          if (fullResult.isFailure) {
            debugPrint('[SyncNotifier] Download failed for ${cloudProject.name}');
            continue;
          }
          final fullProject = (fullResult as Success<CloudProject>).value;

          
          final directory = await _getProjectsDirectory();
          if (directory == null) continue;

          
          final fileResult = await _local.createProjectFile(directory, fullProject.name);
          if (fileResult.isFailure) continue;
          final filePath = (fileResult as Success<String>).value;

          
          await _local.writeProjectContent(filePath, fullProject.text);

          
          final existingIndex = projects.indexWhere((p) => p.path == filePath);
          if (existingIndex >= 0) {
            
            projects[existingIndex] = projects[existingIndex].copyWith(
              cloudId: () => fullProject.id,
              syncStatus: SyncStatus.synced,
            );
          } else {
            
            final now = DateTime.now();
            final newProject = Project(
              name: fullProject.name,
              path: filePath,
              created: now,
              lastOpened: now,
              cloudId: fullProject.id,
              syncStatus: SyncStatus.synced,
            );
            projects.add(newProject);
          }
          downloaded++;
        }
      }

      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: () => DateTime.now(),
        syncedCount: uploaded + downloaded + updated,
        uploadedCount: uploaded,
        downloadedCount: downloaded,
        updatedCount: updated,
        currentOperation: () => null,
      );
    } catch (e) {
      debugPrint('[SyncNotifier] Unexpected error: $e');
      state = state.copyWith(
        isSyncing: false,
        error: () => 'Nieoczekiwany błąd synchronizacji',
        currentOperation: () => null,
      );
    }

    return projects;
  }

  
  
  Future<Project?> syncSingleProject(Project project) async {
    try {
      final content = await _readLocalContent(project);

      if (project.cloudId == null) {
        
        final result = await _cloud.createProject(project.name, content);
        if (result.isSuccess) {
          final cloudProject = (result as Success<CloudProject>).value;
          return project.copyWith(
            cloudId: () => cloudProject.id,
            syncStatus: SyncStatus.synced,
          );
        }
      } else if (project.syncStatus == SyncStatus.modified) {
        
        final result = await _cloud.updateProject(
          project.cloudId!,
          name: project.name,
          content: content,
        );
        if (result.isSuccess) {
          return project.copyWith(syncStatus: SyncStatus.synced);
        }
      } else {
        
        return project;
      }
    } catch (e) {
      debugPrint('[SyncNotifier] Single sync failed for ${project.name}: $e');
    }
    return null;
  }

  
  Future<bool> deleteCloudProject(String cloudId) async {
    final result = await _cloud.deleteProject(cloudId);
    return result.isSuccess;
  }

  
  Future<CloudProject?> uploadProject(Project project) async {
    final content = await _readLocalContent(project);
    final result = await _cloud.createProject(project.name, content);
    return switch (result) {
      Success(:final value) => value,
      Err() => null,
    };
  }

  
  Future<String?> downloadProjectContent(String cloudId) async {
    final result = await _cloud.getProject(cloudId);
    return switch (result) {
      Success(:final value) => value.text,
      Err() => null,
    };
  }

  Future<String> _readLocalContent(Project project) async {
    final result = await _local.readProjectContent(project.path);
    return result.getOrElse(() => '');
  }

  Future<String?> _getProjectsDirectory() async {
    final result = await _local.initProjectsDirectory();
    return result.getOrElse(() => '');
  }
}
