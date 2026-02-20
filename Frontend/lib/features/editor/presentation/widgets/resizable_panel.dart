import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ResizablePanel extends StatefulWidget {
  final Widget leftPanel;
  final Widget centerPanel;
  final Widget rightPanel;
  final double initialLeftWidth;
  final double initialRightWidth;
  final double minPanelWidth;
  final bool showLeftPanel;
  final bool showRightPanel;

  const ResizablePanel({
    super.key,
    required this.leftPanel,
    required this.centerPanel,
    required this.rightPanel,
    this.initialLeftWidth = 240,
    this.initialRightWidth = 280,
    this.minPanelWidth = 160,
    this.showLeftPanel = true,
    this.showRightPanel = true,
  });

  @override
  State<ResizablePanel> createState() => _ResizablePanelState();
}

class _ResizablePanelState extends State<ResizablePanel> {
  late double _leftWidth;
  late double _rightWidth;
  bool _isHoveringLeft = false;
  bool _isHoveringRight = false;
  bool _isDraggingLeft = false;
  bool _isDraggingRight = false;

  @override
  void initState() {
    super.initState();
    _leftWidth = widget.initialLeftWidth;
    _rightWidth = widget.initialRightWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        
        return Row(
          children: [
            if (widget.showLeftPanel) ...[
              SizedBox(
                width: _leftWidth,
                child: widget.leftPanel,
              ),
              _buildSashDivider(
                onDragUpdate: (delta) {
                  setState(() {
                    final newWidth = _leftWidth + delta;
                    _leftWidth = newWidth.clamp(
                      widget.minPanelWidth, 
                      availableWidth - widget.minPanelWidth - (widget.showRightPanel ? _rightWidth : 0) - 10
                    );
                  });
                },
                onHoverChange: (isHovering) => setState(() => _isHoveringLeft = isHovering),
                onDragChange: (isDragging) => setState(() => _isDraggingLeft = isDragging),
                isHovering: _isHoveringLeft,
                isDragging: _isDraggingLeft,
              ),
            ],
            Expanded(
              child: widget.centerPanel,
            ),
            if (widget.showRightPanel) ...[
              _buildSashDivider(
                onDragUpdate: (delta) {
                  setState(() {
                    final newWidth = _rightWidth - delta;
                    _rightWidth = newWidth.clamp(
                      widget.minPanelWidth, 
                      availableWidth - widget.minPanelWidth - (widget.showLeftPanel ? _leftWidth : 0) - 10
                    );
                  });
                },
                onHoverChange: (isHovering) => setState(() => _isHoveringRight = isHovering),
                onDragChange: (isDragging) => setState(() => _isDraggingRight = isDragging),
                isHovering: _isHoveringRight,
                isDragging: _isDraggingRight,
              ),
              SizedBox(
                width: _rightWidth,
                child: widget.rightPanel,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSashDivider({
    required Function(double) onDragUpdate,
    required Function(bool) onHoverChange,
    required Function(bool) onDragChange,
    required bool isHovering,
    required bool isDragging,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => onHoverChange(true),
      onExit: (_) => onHoverChange(false),
      child: GestureDetector(
        onHorizontalDragStart: (_) => onDragChange(true),
        onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
        onHorizontalDragEnd: (_) => onDragChange(false),
        child: Container(
          width: 4,
          color: (isHovering || isDragging)
              ? AppTheme.accent
              : AppTheme.border,
        ),
      ),
    );
  }
}
