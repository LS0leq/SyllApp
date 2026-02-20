import '../../../../core/error/result.dart';


class CloudProject {
  final String id;
  final String name;
  final String text;
  final String userId;

  const CloudProject({
    required this.id,
    required this.name,
    this.text = '',
    this.userId = '',
  });
}




abstract class CloudProjectRepository {
  
  Future<Result<List<CloudProject>>> fetchProjects();

  
  Future<Result<CloudProject>> createProject(String name, String content);

  
  
  Future<Result<CloudProject>> updateProject(
    String id, {
    String? name,
    String? content,
  });

  
  Future<Result<void>> deleteProject(String id);

  
  Future<Result<CloudProject>> getProject(String id);
}
