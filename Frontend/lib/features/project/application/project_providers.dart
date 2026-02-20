import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/project/project.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/application/auth_state.dart';
import 'project_notifier.dart';
import 'project_state.dart';
import 'sync/sync_notifier.dart';
import 'sync/sync_state.dart';

export 'project_infra_providers.dart'
    show
        projectRepositoryProvider,
        cloudProjectDataSourceProvider,
        cloudProjectRepositoryProvider;



final projectNotifierProvider =
    NotifierProvider<ProjectNotifier, ProjectState>(ProjectNotifier.new);


final currentProjectProvider = Provider<Project?>((ref) {
  return ref.watch(projectNotifierProvider).currentProject;
});


final recentProjectsProvider = Provider<List<Project>>((ref) {
  return ref.watch(projectNotifierProvider).recentProjects;
});


final syncNotifierProvider =
    NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);


Future<void> triggerSync(WidgetRef ref) async {
  final authState = ref.read(authNotifierProvider);
  if (authState is! AuthAuthenticated) return;

  final syncNotifier = ref.read(syncNotifierProvider.notifier);
  if (ref.read(syncNotifierProvider).isSyncing) return;

  final projectNotifier = ref.read(projectNotifierProvider.notifier);
  final currentProjects = ref.read(projectNotifierProvider).recentProjects;

  final updatedProjects = await syncNotifier.syncAll(currentProjects);
  await projectNotifier.updateProjectsAfterSync(updatedProjects);
}



Future<void> triggerSyncCurrentProject(Ref ref) async {
  final authState = ref.read(authNotifierProvider);
  if (authState is! AuthAuthenticated) return;

  final project = ref.read(currentProjectProvider);
  if (project == null) return;

  final syncNotifier = ref.read(syncNotifierProvider.notifier);
  final projectNotifier = ref.read(projectNotifierProvider.notifier);

  final updated = await syncNotifier.syncSingleProject(project);
  if (updated != null) {
    await projectNotifier.updateSingleProjectAfterSync(updated);
  }
}
