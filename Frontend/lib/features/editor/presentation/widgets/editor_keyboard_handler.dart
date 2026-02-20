import 'package:flutter/material.dart';
import 'package:flutter/services.dart';





class EditorKeyboardHandler extends StatelessWidget {
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback? onOpen;
  final VoidCallback onNewFile;
  final VoidCallback onToggleExplorer;

  const EditorKeyboardHandler({
    super.key,
    required this.child,
    required this.onSave,
    this.onOpen,
    required this.onNewFile,
    required this.onToggleExplorer,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: child,
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isCtrl = HardwareKeyboard.instance.isControlPressed;
      final isAlt = HardwareKeyboard.instance.isAltPressed;

      
      if (isAlt) return;

      
      if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyS) {
        onSave();
      }
      
      else if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyO) {
        onOpen?.call();
      }
      
      else if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyN) {
        onNewFile();
      }
      
      else if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyB) {
        onToggleExplorer();
      }
    }
  }
}
