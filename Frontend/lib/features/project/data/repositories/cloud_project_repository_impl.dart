import '../../../../core/error/result.dart';
import '../../domain/repositories/cloud_project_repository.dart';
import '../datasources/cloud_project_datasource.dart';

class CloudProjectRepositoryImpl implements CloudProjectRepository {
  final CloudProjectDataSource _dataSource;

  CloudProjectRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<CloudProject>>> fetchProjects() {
    return _dataSource.fetchProjects();
  }

  @override
  Future<Result<CloudProject>> createProject(String name, String content) {
    return _dataSource.createProject(name, content);
  }

  @override
  Future<Result<CloudProject>> updateProject(
    String id, {
    String? name,
    String? content,
  }) {
    return _dataSource.updateProject(id, name: name, content: content);
  }

  @override
  Future<Result<void>> deleteProject(String id) {
    return _dataSource.deleteProject(id);
  }

  @override
  Future<Result<CloudProject>> getProject(String id) {
    return _dataSource.getProject(id);
  }
}
