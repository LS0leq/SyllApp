import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/top_toast.dart';

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
  
  List<FileSystemEntity> _visibleItems = [];
  
  final Set<String> _expandedPaths = {};
  
  final Map<String, List<FileSystemEntity>> _directoryCache = {};
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRootDirectory();
  }

  @override
  void didUpdateWidget(ProjectTreePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentDirectory != oldWidget.currentDirectory) {
      _loadRootDirectory();
    }
  }

  Future<void> _loadRootDirectory() async {
    if (widget.currentDirectory == null) {
      setState(() {
        _visibleItems = [];
        _expandedPaths.clear();
        _directoryCache.clear();
      });
      return;
    }

    setState(() => _isLoading = true);
    
    
    _visibleItems.clear();
    _expandedPaths.clear();
    _directoryCache.clear();

    
    final rootDir = Directory(widget.currentDirectory!);
    _visibleItems.add(rootDir);
    
    
    await _expandDirectory(widget.currentDirectory!);
    _expandedPaths.add(widget.currentDirectory!);

    setState(() => _isLoading = false);
  }

  Future<void> _expandDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) return;

      List<FileSystemEntity> children;
      if (_directoryCache.containsKey(path)) {
        children = _directoryCache[path]!;
      } else {
        children = await dir.list().toList();
        
        children.sort((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });
        _directoryCache[path] = children;
      }

      
      
      if (path == widget.currentDirectory) {
        _visibleItems.addAll(children);
      } else {
        final parentIndex = _visibleItems.indexWhere((e) => e.path == path);
        if (parentIndex != -1) {
          _visibleItems.insertAll(parentIndex + 1, children);
        }
      }
      
      _expandedPaths.add(path);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error expanding directory: $e');
    }
  }

  void _collapseDirectory(String path) {
    if (!_expandedPaths.contains(path)) return;
    
    
    final parentIndex = _visibleItems.indexWhere((e) => e.path == path);
    if (parentIndex == -1) return;

    int countToRemove = 0;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    final pathSeparator = Platform.pathSeparator;
    final parentPathWithSep = path.endsWith(pathSeparator) ? path : '$path$pathSeparator';

    for (int i = parentIndex + 1; i < _visibleItems.length; i++) {
        final itemPath = _visibleItems[i].path;
        if (itemPath.startsWith(parentPathWithSep)) {
            countToRemove++;
            
            if (_visibleItems[i] is Directory) {
                _expandedPaths.remove(itemPath);
            }
        } else {
            break;
        }
    }

    _visibleItems.removeRange(parentIndex + 1, parentIndex + 1 + countToRemove);
    _expandedPaths.remove(path);
    setState(() {});
  }

  Future<void> refresh() async {
    
    _directoryCache.clear();
    final previouslyExpanded = List<String>.from(_expandedPaths);
    
    previouslyExpanded.sort((a, b) => a.length.compareTo(b.length));
    
    await _loadRootDirectory();
    
    for (final path in previouslyExpanded) {
        if (path != widget.currentDirectory) {
             
             await _expandDirectory(path);
        }
    }
  }

  Future<void> _refreshPath(String path) async {
    _directoryCache.remove(path);
    if (path == widget.currentDirectory) {
      await refresh();
    } else if (_expandedPaths.contains(path)) {
      
      final pathSep = Platform.pathSeparator;
      final parentPathWithSep = path.endsWith(pathSep) ? path : '$path$pathSep';
      final descendants = _expandedPaths.where((p) => p.startsWith(parentPathWithSep)).toList();
      descendants.sort((a, b) => a.length.compareTo(b.length));

      _collapseDirectory(path);
      await _expandDirectory(path);
      
      
      for (final p in descendants) {
         
         await _expandDirectory(p); 
      }
    }
  }

  void _onFileClick(File file) async {
    
    try {
      final content = await file.readAsString();
      widget.onFileSelected(file.path, content);
    } catch (e) {
      debugPrint('Error reading file: $e');
      if (mounted) {
        TopToast.show(
          context,
          message: 'Błąd odczytu pliku: $e',
          color: AppTheme.errorColor,
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  void _onDirectoryClick(Directory dir) {
    if (_expandedPaths.contains(dir.path)) {
      _collapseDirectory(dir.path);
    } else {
      _expandDirectory(dir.path);
    }
  }
  
  
  
  Future<void> _createNew(String parentPath, bool isFolder) async {
    
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => _NameDialog(
        title: isFolder ? 'Nowy folder' : 'Nowy plik',
        action: 'Utwórz',
      ),
    );
    
    if (name == null || name.isEmpty) return;
    
    final newPath = '$parentPath${Platform.pathSeparator}$name${!isFolder && !name.endsWith(".txt") ? ".txt" : ""}'; 
    
    try {
      if (isFolder) {
        await Directory(newPath).create();
      } else {
        await File(newPath).create();
      }
      
      
      await _refreshPath(parentPath);
    } catch (e) {
       debugPrint('Error creating: $e');
    }
  }
  
  Future<void> _delete(FileSystemEntity entity) async {
     final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.sidebarBackground,
          title: Text(entity is Directory ? 'Usuń folder' : 'Usuń plik', style: const TextStyle(color: AppTheme.textPrimary)),
          content: Text('Czy na pewno chcesz usunąć ${entity.path.split(Platform.pathSeparator).last}?', style: const TextStyle(color: AppTheme.textSecondary)),
          actions: [
            TextButton(child: const Text('Anuluj'), onPressed: () => Navigator.pop(ctx, false)),
            TextButton(child: const Text('Usuń', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
          ],
        )
     );
     
     if (confirm != true) return;
     
     try {
       await entity.delete(recursive: true);
       final parent = entity.parent.path;
       await _refreshPath(parent);
     } catch (e) {
       debugPrint('Error deleting: $e');
     }
  }

  Future<void> _rename(FileSystemEntity entity) async {
      final oldName = entity.path.split(Platform.pathSeparator).last;
      
      final newName = await showDialog<String>(
        context: context,
        builder: (ctx) => _NameDialog(
          title: 'Zmień nazwę',
          initialValue: oldName,
          action: 'Zmień',
        ),
      );
      
      if (newName == null || newName.isEmpty || newName == oldName) return;
      
      try {
        final newPath = '${entity.parent.path}${Platform.pathSeparator}$newName';
        await entity.rename(newPath);
        
        
        final parent = entity.parent.path;
        await _refreshPath(parent);
      } catch (e) {
        debugPrint('Error renaming: $e');
      }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentDirectory == null) {
      return const Center(
        child: Text(
          'Brak otwartego projektu', 
          style: TextStyle(color: AppTheme.textMuted)
        )
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Column(
      children: [
        
        
        
        Expanded(
          child: _visibleItems.isEmpty
              ? const Center(child: Text('Folder jest pusty', style: TextStyle(color: AppTheme.textMuted)))
              : ListView.builder(
                  itemCount: _visibleItems.length,
                  itemBuilder: (context, index) {
                    final item = _visibleItems[index];
                    return _buildTreeItem(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTreeItem(FileSystemEntity item) {
    
    final rootPath = widget.currentDirectory!;
    final isRoot = item.path == rootPath;
    
    
    int depth = 0;
    if (!isRoot && item.path.length > rootPath.length) {
       final relPath = item.path.substring(rootPath.length);
       depth = relPath.split(Platform.pathSeparator).length - 1;
    }
    
    final isDir = item is Directory;
    final isExpanded = _expandedPaths.contains(item.path);
    final isSelected = item.path == widget.selectedFilePath;
    final fileName = item.path.split(Platform.pathSeparator).last;
    
    
    const double indentWidth = 20.0;

    return GestureDetector(
      onSecondaryTapUp: (details) {
         _showContextMenu(details.globalPosition, item);
      },
      child: Draggable<FileSystemEntity>(
         data: item,
         feedback: Material(
           color: Colors.transparent,
           child: Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
             decoration: BoxDecoration(
               color: AppTheme.sidebarBackground,
               border: Border.all(color: AppTheme.accent),
               borderRadius: BorderRadius.circular(4),
               boxShadow: [
                 BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
               ],
             ),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(isDir ? Icons.folder : _getFileIcon(fileName), color: AppTheme.textSecondary, size: 16),
                 const SizedBox(width: 8),
                 Text(fileName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, decoration: TextDecoration.none)),
               ],
             )
           ),
         ),
         childWhenDragging: _buildItemRow(item, depth, isDir, isExpanded, isSelected, fileName, indentWidth, opacity: 0.5, isRoot: isRoot),
         child: DragTarget<FileSystemEntity>(
           onWillAcceptWithDetails: (details) {
             final incoming = details.data;
             
             if (!isDir) return false;
             if (incoming.path == item.path) return false;
             
             if (item.path.startsWith(incoming.path)) return false;
             return true;
           },
           onAcceptWithDetails: (details) async {
             final incoming = details.data;
             
             try {
                final newPath = '${item.path}${Platform.pathSeparator}${incoming.path.split(Platform.pathSeparator).last}';
                await incoming.rename(newPath);
                
                
                await _refreshPath(incoming.parent.path);
                
                await _refreshPath(item.path);
             } catch (e) {
               debugPrint('Error moving: $e');
             }
           },
           builder: (context, candidateData, rejectedData) {
             final isDragTarget = candidateData.isNotEmpty;
             return _buildItemRow(item, depth, isDir, isExpanded, isSelected, fileName, indentWidth, isDragTarget: isDragTarget, isRoot: isRoot);
           }
         ),
      )
    );
  }

  Widget _buildItemRow(
    FileSystemEntity item, 
    int depth, 
    bool isDir, 
    bool isExpanded, 
    bool isSelected, 
    String fileName, 
    double indentWidth,
    {double opacity = 1.0, bool isDragTarget = false, bool isRoot = false}
  ) {
    return InkWell(
      onTap: () {
        if (isDir) {
          _onDirectoryClick(item as Directory);
        } else {
          _onFileClick(item as File);
        }
      },
      child: Container(
        height: 24, 
        color: isDragTarget 
            ? AppTheme.accent.withValues(alpha: 0.2)
            : (isSelected ? AppTheme.selectionBackground : Colors.transparent),
        child: Opacity(
          opacity: opacity,
          child: Row(
            children: [
              
              for (int i = 0; i < depth; i++)
                Container(
                  width: indentWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: AppTheme.border.withValues(alpha: 0.05), 
                        width: 1,
                      ),
                    ),
                  ),
                ),
                
              
              SizedBox(
                width: indentWidth,
                child: isDir
                  ? Icon(
                      isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                      size: 16,
                      color: AppTheme.textMuted,
                    )
                  : null,
              ),
               
              
              Icon(
                isDir 
                 ? (isExpanded ? Icons.folder_open : Icons.folder)
                 : _getFileIcon(fileName),
                size: 16,
                color: isDir ? AppTheme.iconFolder : _getFileIconColor(fileName),
              ),
              const SizedBox(width: 6),
              
              
              Expanded(
                child: Text(
                  isRoot ? fileName.toUpperCase() : fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontSize: 13,
                    fontFamily: 'Segoe UI',
                    fontWeight: isRoot ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getFileIconColor(String fileName) {
    if (fileName.endsWith('.dart')) return const Color(0xFF00B4AB); 
    if (fileName.endsWith('.json')) return const Color(0xFFFFC107); 
    if (fileName.endsWith('.yaml')) return const Color(0xFFE91E63); 
    if (fileName.endsWith('.html')) return const Color(0xFFFF5722); 
    if (fileName.endsWith('.css')) return const Color(0xFF2196F3); 
    if (fileName.endsWith('.js')) return const Color(0xFFFFEB3B); 
    if (fileName.endsWith('.md')) return const Color(0xFF9E9E9E); 
    return AppTheme.textSecondary;
  }
  
  IconData _getFileIcon(String fileName) {
    if (fileName.endsWith('.dart')) return Icons.code;
    if (fileName.endsWith('.txt')) return Icons.description;
    if (fileName.endsWith('.json')) return Icons.data_object;
    if (fileName.endsWith('.yaml')) return Icons.settings_applications;
    if (fileName.endsWith('.png') || fileName.endsWith('.jpg')) return Icons.image;
    return Icons.insert_drive_file_outlined;
  }

  void _showContextMenu(Offset position, FileSystemEntity item) {
    final List<PopupMenuEntry> items = [
      if (item is Directory) ...[
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, () => _createNew(item.path, false)),
          child: const _MenuItem('Nowy plik', Icons.note_add_outlined),
        ),
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, () => _createNew(item.path, true)),
          child: const _MenuItem('Nowy folder', Icons.create_new_folder_outlined),
        ),
        const PopupMenuDivider(),
      ],
      PopupMenuItem(
        onTap: () => Future.delayed(Duration.zero, () => _rename(item)),
        child: const _MenuItem('Zmień nazwę', Icons.edit_outlined),
      ),
      PopupMenuItem(
        onTap: () => Future.delayed(Duration.zero, () => _delete(item)),
        child: const _MenuItem('Usuń', Icons.delete_outline, color: Colors.red),
      ),
    ];

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      color: AppTheme.sidebarBackground,
      items: items,
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _MenuItem(this.label, this.icon, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppTheme.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color ?? AppTheme.textPrimary, fontSize: 13)),
      ],
    );
  }
}

class _NameDialog extends StatefulWidget {
  final String title;
  final String action;
  final String? initialValue;

  const _NameDialog({required this.title, required this.action, this.initialValue});

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.sidebarBackground,
      title: Text(widget.title, style: const TextStyle(color: AppTheme.textPrimary)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: const InputDecoration(
           enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.border)),
           focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accent)),
        ),
        onSubmitted: (val) => Navigator.pop(context, val),
      ),
      actions: [
        TextButton(child: const Text('Anuluj'), onPressed: () => Navigator.pop(context)),
        TextButton(
          child: Text(widget.action, style: const TextStyle(color: AppTheme.accent)), 
          onPressed: () => Navigator.pop(context, _controller.text)
        ),
      ],
    );
  }
}
