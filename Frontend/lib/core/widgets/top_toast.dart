import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TopToast {
  static OverlayEntry? _active;

  static void show(
    BuildContext context, {
    required String message,
    Color? color,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    _active?.remove();
    _active = null;

    final overlay = Overlay.of(context);
    final accentColor = color ?? AppTheme.accent;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopToastWidget(
        message: message,
        color: accentColor,
        icon: icon ?? Icons.content_copy_rounded,
        duration: duration,
        onDismissed: () {
          entry.remove();
          if (_active == entry) _active = null;
        },
      ),
    );

    _active = entry;
    overlay.insert(entry);
  }
}

class _TopToastWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopToastWidget({
    required this.message,
    required this.color,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 0),
            child: GestureDetector(
              onVerticalDragEnd: (d) {
                if (d.velocity.pixelsPerSecond.dy < -100) _dismiss();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.appleRadiusM),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.appleCardBackground
                          .withValues(alpha: 0.85),
                      borderRadius:
                          BorderRadius.circular(AppTheme.appleRadiusM),
                      border: Border.all(
                        color: widget.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 18,
                            color: widget.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'SF Pro Display',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
