import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/result.dart';
import '../../../../core/project/project.dart';
import '../../domain/repositories/project_repository.dart';



class ProjectRepositoryImpl implements ProjectRepository {
  static const String _recentProjectsKey = 'recent_projects';
  static const String _currentProjectKey = 'current_project';

  

  @override
  Future<Result<String>> initProjectsDirectory() async {
    if (kIsWeb) {
      return const Err(ProjectFailure('Web platform not supported'));
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final path = '${appDir.path}${Platform.pathSeparator}SyllApp';

      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return Success(path);
    } catch (e) {
      return Err(ProjectFailure('Błąd inicjalizacji katalogu projektów: $e'));
    }
  }

  @override
  Future<Result<List<({String name, String path, DateTime created, DateTime modified})>>>
      listProjectFiles(String directory) async {
    final result = <({String name, String path, DateTime created, DateTime modified})>[];
    try {
      final dir = Directory(directory);
      if (!await dir.exists()) return Success(result);

      final files = await dir.list().toList();
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.txt')) {
          final name = entity.path
              .split(Platform.pathSeparator)
              .last
              .replaceAll('.txt', '');
          final stat = await entity.stat();
          result.add((
            name: name,
            path: entity.path,
            created: stat.changed,
            modified: stat.modified,
          ));
        }
      }
      return Success(result);
    } catch (e) {
      return Err(ProjectFailure('Błąd listowania plików: $e'));
    }
  }

  

  @override
  Future<Result<String>> createProjectFile(String directory, String safeName) async {
    try {
      final filePath = '$directory${Platform.pathSeparator}$safeName.txt';
      final file = File(filePath);
      await file.writeAsString('');
      return Success(filePath);
    } catch (e) {
      return Err(ProjectFailure('Błąd tworzenia pliku projektu: $e'));
    }
  }

  @override
  Future<Result<String>> createProjectFolder(String path, String name) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final txtFile = File('$path${Platform.pathSeparator}$name.txt');
      if (!await txtFile.exists()) {
        await txtFile.writeAsString('');
      }
      return Success(txtFile.path);
    } catch (e) {
      return Err(ProjectFailure('Błąd tworzenia folderu projektu: $e'));
    }
  }

  @override
  Future<Result<String>> readProjectContent(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return Success(await file.readAsString());
      }
      return const Success('');
    } catch (e) {
      return Err(FileFailure('Błąd odczytu projektu: $e'));
    }
  }

  @override
  Future<Result<void>> writeProjectContent(String path, String content) async {
    try {
      final file = File(path);
      await file.writeAsString(content);
      return const Success(null);
    } catch (e) {
      return Err(FileFailure('Błąd zapisywania projektu: $e'));
    }
  }

  @override
  Future<Result<String>> renameProjectFile(String oldPath, String newName) async {
    try {
      final oldFile = File(oldPath);
      final dir = oldFile.parent;
      final newPath = '${dir.path}${Platform.pathSeparator}$newName.txt';
      await oldFile.rename(newPath);
      return Success(newPath);
    } catch (e) {
      return Err(FileFailure('Błąd zmiany nazwy: $e'));
    }
  }

  @override
  Future<Result<void>> deleteProjectFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      return const Success(null);
    } catch (e) {
      return Err(FileFailure('Błąd usuwania: $e'));
    }
  }

  @override
  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  

  @override
  Future<List<Project>> loadRecentProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentProjectsKey);

      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        return jsonList
            .map((json) => Project.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Błąd ładowania ostatnich projektów: $e');
    }
    return [];
  }

  @override
  Future<void> saveRecentProjects(List<Project> projects) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = projects.map((p) => p.toJson()).toList();
      await prefs.setString(_recentProjectsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Błąd zapisywania ostatnich projektów: $e');
    }
  }

  @override
  Future<Project?> loadCurrentProject() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_currentProjectKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final project = Project.fromJson(json);

        if (await File(project.path).exists()) {
          return project;
        } else {
          await prefs.remove(_currentProjectKey);
        }
      }
    } catch (e) {
      debugPrint('Błąd ładowania aktualnego projektu: $e');
    }
    return null;
  }

  @override
  Future<void> saveCurrentProject(Project? project) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (project != null) {
        await prefs.setString(
            _currentProjectKey, jsonEncode(project.toJson()));
      } else {
        await prefs.remove(_currentProjectKey);
      }
    } catch (e) {
      debugPrint('Błąd zapisywania aktualnego projektu: $e');
    }
  }
}
