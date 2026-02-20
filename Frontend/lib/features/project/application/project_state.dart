import '../../../core/project/project.dart';


class ProjectState {
  final List<Project> recentProjects;
  final Project? currentProject;
  final String? projectsDirectory;
  final bool isLoading;

  const ProjectState({
    this.recentProjects = const [],
    this.currentProject,
    this.projectsDirectory,
    this.isLoading = false,
  });

  ProjectState copyWith({
    List<Project>? recentProjects,
    Project? Function()? currentProject,
    String? Function()? projectsDirectory,
    bool? isLoading,
  }) {
    return ProjectState(
      recentProjects: recentProjects ?? this.recentProjects,
      currentProject:
          currentProject != null ? currentProject() : this.currentProject,
      projectsDirectory: projectsDirectory != null
          ? projectsDirectory()
          : this.projectsDirectory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
