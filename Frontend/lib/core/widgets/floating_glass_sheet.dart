import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class FloatingGlassSheet extends StatefulWidget {
  final Widget child;
  final double? initialHeight;
  final double? maxHeight;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final double blurSigma;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final bool showDragHandle;
  final VoidCallback? onDismiss;

  const FloatingGlassSheet({
    super.key,
    required this.child,
    this.initialHeight,
    this.maxHeight,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 24),
    this.backgroundColor,
    this.blurSigma = 20.0,
    this.borderRadius,
    this.shadows,
    this.showDragHandle = true,
    this.onDismiss,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? initialHeight,
    double? maxHeight,
    EdgeInsets? margin,
    Color? backgroundColor,
    double blurSigma = 20.0,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    bool showDragHandle = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    HapticFeedback.lightImpact();

    final completer = Completer<T?>();
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _FloatingGlassOverlay<T>(
        initialHeight: initialHeight,
        maxHeight: maxHeight,
        margin: margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 24),
        backgroundColor: backgroundColor,
        blurSigma: blurSigma,
        borderRadius: borderRadius,
        shadows: shadows,
        showDragHandle: showDragHandle,
        isDismissible: isDismissible,
        onDismissed: () {
          entry.remove();
          if (!completer.isCompleted) completer.complete(null);
        },
        child: child,
      ),
    );

    overlayState.insert(entry);
    return completer.future;
  }

  @override
  State<FloatingGlassSheet> createState() => _FloatingGlassSheetState();
}

class _FloatingGlassOverlay<T> extends StatefulWidget {
  final Widget child;
  final double? initialHeight;
  final double? maxHeight;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final double blurSigma;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final bool showDragHandle;
  final bool isDismissible;
  final VoidCallback onDismissed;

  const _FloatingGlassOverlay({
    required this.child,
    this.initialHeight,
    this.maxHeight,
    required this.margin,
    this.backgroundColor,
    required this.blurSigma,
    this.borderRadius,
    this.shadows,
    required this.showDragHandle,
    required this.isDismissible,
    required this.onDismissed,
  });

  @override
  State<_FloatingGlassOverlay<T>> createState() =>
      _FloatingGlassOverlayState<T>();
}

class _FloatingGlassOverlayState<T> extends State<_FloatingGlassOverlay<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideCurve;
  late final Animation<double> _fadeCurve;
  late final Animation<double> _barrierFade;
  bool _dismissing = false;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _slideCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _fadeCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      reverseCurve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    _barrierFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_dismissing) return;
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0.0, double.infinity);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dismissing) return;
    final velocity = details.velocity.pixelsPerSecond.dy;
    if (velocity > 300 || _dragOffset > 100) {
      _dismiss();
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  void _dismiss() {
    if (_dismissing) return;
    _dismissing = true;
    HapticFeedback.lightImpact();
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
    final screenHeight = MediaQuery.of(context).size.height;
    final defaultMaxHeight = screenHeight * 0.6;
    final actualMaxHeight = widget.maxHeight ?? defaultMaxHeight;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.isDismissible ? _dismiss : null,
                  child: ColoredBox(
                    color: Colors.black
                        .withValues(alpha: 0.3 * _barrierFade.value),
                  ),
                ),
              ),
              
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(_slideCurve),
                  child: FadeTransition(
                    opacity: _fadeCurve,
                    child: Transform.translate(
                      offset: Offset(0, _dragOffset),
                      child: GestureDetector(
                        onVerticalDragUpdate: _onDragUpdate,
                        onVerticalDragEnd: _onDragEnd,
                        child: Container(
                      margin: widget.margin,
                      constraints: BoxConstraints(maxHeight: actualMaxHeight),
                      child: ClipRRect(
                        borderRadius: widget.borderRadius ??
                            BorderRadius.circular(AppTheme.appleRadiusL),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: widget.blurSigma,
                            sigmaY: widget.blurSigma,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: widget.backgroundColor ??
                                  AppTheme.appleCardBackground
                                      .withValues(alpha: 0.85),
                              borderRadius: widget.borderRadius ??
                                  BorderRadius.circular(AppTheme.appleRadiusL),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1.5,
                              ),
                              boxShadow: widget.shadows ??
                                  [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.4),
                                      blurRadius: 30,
                                      offset: const Offset(0, -8),
                                    ),
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, -2),
                                    ),
                                  ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.showDragHandle)
                                  _buildDragHandle(),
                                Flexible(child: widget.child),
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDragHandle() {
    return GestureDetector(
      onTap: _dismiss,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingGlassSheetState extends State<FloatingGlassSheet> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
