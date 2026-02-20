import '../../../../core/error/result.dart';
import '../../../../core/project/project.dart';





abstract class ProjectRepository {

  

  
  Future<Result<String>> initProjectsDirectory();

  
  Future<Result<List<({String name, String path, DateTime created, DateTime modified})>>>
      listProjectFiles(String directory);

  

  
  Future<Result<String>> createProjectFile(String directory, String safeName);

  
  Future<Result<String>> createProjectFolder(String path, String name);

  
  Future<Result<String>> readProjectContent(String path);

  
  Future<Result<void>> writeProjectContent(String path, String content);

  
  Future<Result<String>> renameProjectFile(String oldPath, String newName);

  
  Future<Result<void>> deleteProjectFile(String path);

  
  Future<bool> fileExists(String path);

  

  
  Future<List<Project>> loadRecentProjects();

  
  Future<void> saveRecentProjects(List<Project> projects);

  
  Future<Project?> loadCurrentProject();

  
  Future<void> saveCurrentProject(Project? project);
}
