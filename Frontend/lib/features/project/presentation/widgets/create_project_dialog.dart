import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/utils/platform_utils.dart' as platform;
import '../../../../core/utils/native_file_utils.dart' as native_io;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/project/project.dart';
import '../../application/project_providers.dart';


class CreateProjectDialog extends ConsumerStatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  ConsumerState<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends ConsumerState<CreateProjectDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedPath;
  bool _isCreating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initDefaultPath();
  }

  Future<void> _initDefaultPath() async {
    if (!kIsWeb && platform.isNativeDesktop) {
      final docsDir = await getApplicationDocumentsDirectory();
      setState(() {
        _selectedPath = '${docsDir.path}${platform.pathSeparator}SyllApp';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() => _selectedPath = result);
    }
  }

  Future<void> _createProject() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Podaj nazwę projektu');
      return;
    }

    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      String projectPath;

      if (kIsWeb) {
        
        projectPath = 'web_projects/$name';
      } else if (platform.isNativeMobile) {
        
        final appDir = await getApplicationDocumentsDirectory();
        projectPath = '${appDir.path}/$name';
      } else {
        
        if (_selectedPath == null) {
          setState(() {
            _error = 'Wybierz lokalizację projektu';
            _isCreating = false;
          });
          return;
        }
        projectPath = '$_selectedPath${platform.pathSeparator}$name';
      }

      
      if (!kIsWeb) {
        if (await native_io.nativeDirectoryExists(projectPath)) {
          
          
          setState(() {
            _error = 'Folder już istnieje';
            _isCreating = false;
          });
          return;
        }
      }

      
      (Project?, String?) result;
      final notifier = ref.read(projectNotifierProvider.notifier);
      
      if (kIsWeb) {
        
        result = await notifier.createProject(name: name);
      } else if (platform.isNativeMobile) {
        
        result = await notifier.createProject(name: name);
      } else {
        
        result = await notifier.createProjectWithPath(
          name: name,
          path: projectPath,
        );
      }
      
      final project = result.$1;
      final initialFilePath = result.$2;

      if (mounted) {
        Navigator.of(context).pop((project, initialFilePath));
      }
    } catch (e) {
      setState(() {
        _error = 'Błąd tworzenia projektu: $e';
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = !kIsWeb && platform.isNativeDesktop;

    return Dialog(
      backgroundColor: AppTheme.sidebarBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.border, width: 1),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                const Icon(Icons.create_new_folder, color: AppTheme.accent, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Nowy projekt',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: AppTheme.textSecondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Nazwa projektu',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Segoe UI',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontFamily: 'Segoe UI',
              ),
              decoration: InputDecoration(
                hintText: 'Mój tekst',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.editorBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppTheme.accent),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onSubmitted: (_) => _createProject(),
            ),
            
            if (isDesktop) ...[
              const SizedBox(height: 20),
              const Text(
                'Lokalizacja',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.editorBackground,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        _selectedPath ?? 'Nie wybrano',
                        style: TextStyle(
                          color: _selectedPath != null
                              ? AppTheme.textPrimary
                              : AppTheme.textMuted,
                          fontSize: 13,
                          fontFamily: 'Segoe UI',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _pickDirectory,
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.hoverBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Przeglądaj...',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 12,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Anuluj',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isCreating ? null : _createProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Utwórz projekt',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
