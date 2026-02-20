import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/repositories/cloud_project_repository.dart';
import '../domain/repositories/project_repository.dart';
import '../data/datasources/cloud_project_datasource.dart';
import '../data/repositories/cloud_project_repository_impl.dart';
import '../data/repositories/project_repository_factory_stub.dart'
    if (dart.library.io) '../data/repositories/project_repository_factory_native.dart'
    if (dart.library.html) '../data/repositories/project_repository_factory_web.dart';



final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return createProjectRepository();
});


final cloudProjectDataSourceProvider = Provider<CloudProjectDataSource>((ref) {
  return CloudProjectDataSource(ref.watch(apiClientProvider).dio);
});

final cloudProjectRepositoryProvider = Provider<CloudProjectRepository>((ref) {
  return CloudProjectRepositoryImpl(ref.watch(cloudProjectDataSourceProvider));
});
