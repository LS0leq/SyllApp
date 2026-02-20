import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';




class ProjectTreePanel extends StatefulWidget {
  final String? currentDirectory;
  final String? selectedFilePath;
  final void Function(String path, String content) onFileSelected;

  const ProjectTreePanel({
    super.key,
    required this.currentDirectory,
    this.selectedFilePath,
    required this.onFileSelected,
  });

  @override
  State<ProjectTreePanel> createState() => ProjectTreePanelState();
}

class ProjectTreePanelState extends State<ProjectTreePanel> {
  Future<void> refresh() async {}

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Eksplorator plików nie jest dostępny w wersji web.\nUżyj panelu „Twoje teksty" aby zarządzać projektami.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
