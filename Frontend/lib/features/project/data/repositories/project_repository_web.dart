import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/result.dart';
import '../../../../core/project/project.dart';
import '../../domain/repositories/project_repository.dart';





class ProjectRepositoryWeb implements ProjectRepository {
  static const String _recentProjectsKey = 'recent_projects';
  static const String _currentProjectKey = 'current_project';
  static const String _projectContentPrefix = 'project_content_';
  static const String _projectListKey = 'web_project_list';

  

  @override
  Future<Result<String>> initProjectsDirectory() async {
    
    return const Success('web_projects');
  }

  @override
  Future<Result<List<({String name, String path, DateTime created, DateTime modified})>>>
      listProjectFiles(String directory) async {
    final result = <({String name, String path, DateTime created, DateTime modified})>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_projectListKey);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        for (final item in jsonList) {
          final map = item as Map<String, dynamic>;
          result.add((
            name: map['name'] as String,
            path: map['path'] as String,
            created: DateTime.parse(map['created'] as String),
            modified: DateTime.parse(map['modified'] as String),
          ));
        }
      }
      return Success(result);
    } catch (e) {
      return Err(ProjectFailure('Błąd listowania projektów web: $e'));
    }
  }

  

  @override
  Future<Result<String>> createProjectFile(String directory, String safeName) async {
    try {
      final filePath = 'web_projects/$safeName.txt';
      final prefs = await SharedPreferences.getInstance();

      
      await prefs.setString('$_projectContentPrefix$filePath', '');

      
      await _addToProjectList(prefs, safeName, filePath);

      return Success(filePath);
    } catch (e) {
      return Err(ProjectFailure('Błąd tworzenia projektu web: $e'));
    }
  }

  @override
  Future<Result<String>> createProjectFolder(String path, String name) async {
    
    final filePath = '$path/$name.txt';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_projectContentPrefix$filePath', '');
      await _addToProjectList(prefs, name, filePath);
      return Success(filePath);
    } catch (e) {
      return Err(ProjectFailure('Błąd tworzenia projektu web: $e'));
    }
  }

  @override
  Future<Result<String>> readProjectContent(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final content = prefs.getString('$_projectContentPrefix$path') ?? '';
      return Success(content);
    } catch (e) {
      return Err(FileFailure('Błąd odczytu projektu web: $e'));
    }
  }

  @override
  Future<Result<void>> writeProjectContent(String path, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_projectContentPrefix$path', content);
      return const Success(null);
    } catch (e) {
      return Err(FileFailure('Błąd zapisywania projektu web: $e'));
    }
  }

  @override
  Future<Result<String>> renameProjectFile(String oldPath, String newName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newPath = 'web_projects/$newName.txt';

      
      final content = prefs.getString('$_projectContentPrefix$oldPath') ?? '';
      await prefs.setString('$_projectContentPrefix$newPath', content);
      await prefs.remove('$_projectContentPrefix$oldPath');

      
      await _updateProjectListPath(prefs, oldPath, newName, newPath);

      return Success(newPath);
    } catch (e) {
      return Err(FileFailure('Błąd zmiany nazwy web: $e'));
    }
  }

  @override
  Future<Result<void>> deleteProjectFile(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_projectContentPrefix$path');
      await _removeFromProjectList(prefs, path);
      return const Success(null);
    } catch (e) {
      return Err(FileFailure('Błąd usuwania web: $e'));
    }
  }

  @override
  Future<bool> fileExists(String path) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_projectContentPrefix$path');
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
      debugPrint('Błąd ładowania ostatnich projektów web: $e');
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
      debugPrint('Błąd zapisywania ostatnich projektów web: $e');
    }
  }

  @override
  Future<Project?> loadCurrentProject() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_currentProjectKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return Project.fromJson(json);
      }
    } catch (e) {
      debugPrint('Błąd ładowania aktualnego projektu web: $e');
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
      debugPrint('Błąd zapisywania aktualnego projektu web: $e');
    }
  }

  

  Future<void> _addToProjectList(SharedPreferences prefs, String name, String path) async {
    final list = await _getProjectList(prefs);
    list.add({
      'name': name,
      'path': path,
      'created': DateTime.now().toIso8601String(),
      'modified': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_projectListKey, jsonEncode(list));
  }

  Future<void> _removeFromProjectList(SharedPreferences prefs, String path) async {
    final list = await _getProjectList(prefs);
    list.removeWhere((item) => item['path'] == path);
    await prefs.setString(_projectListKey, jsonEncode(list));
  }

  Future<void> _updateProjectListPath(
      SharedPreferences prefs, String oldPath, String newName, String newPath) async {
    final list = await _getProjectList(prefs);
    for (final item in list) {
      if (item['path'] == oldPath) {
        item['name'] = newName;
        item['path'] = newPath;
        item['modified'] = DateTime.now().toIso8601String();
        break;
      }
    }
    await prefs.setString(_projectListKey, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> _getProjectList(SharedPreferences prefs) async {
    final jsonString = prefs.getString(_projectListKey);
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.cast<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
