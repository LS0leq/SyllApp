import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/rhyme_result.dart';
import 'modern_rhyme_popup.dart';

class RhymeSuggestionPopup {
  static OverlayEntry? _activeOverlay;

  static void removeOverlay() {
    _activeOverlay?.remove();
    _activeOverlay = null;
  }

  static void show({
    required BuildContext context,
    required String word,
    required Future<RhymeResult> suggestionsFuture,
    required Offset globalPosition,
    required void Function(String suggestion) onInsert,
    List<String>? existingRhymeWords,
    Color? rhymeColor,
  }) {
    final useMobileSheet = ResponsiveUtils.isMobilePlatform ||
        (kIsWeb && ResponsiveUtils.isMobile(context));
    
    if (useMobileSheet) {
      ModernRhymePopup.show(
        context: context,
        word: word,
        suggestionsFuture: suggestionsFuture,
        existingRhymeWords: existingRhymeWords,
        rhymeColor: rhymeColor,
        onInsert: onInsert,
      );
    } else {
      _showDesktopOverlay(
        context: context,
        word: word,
        globalPosition: globalPosition,
        suggestionsFuture: suggestionsFuture,
        existingRhymeWords: existingRhymeWords,
        rhymeColor: rhymeColor,
        onInsert: onInsert,
      );
    }
  }

  static void _showDesktopOverlay({
    required BuildContext context,
    required String word,
    required Offset globalPosition,
    required Future<RhymeResult> suggestionsFuture,
    required void Function(String) onInsert,
    List<String>? existingRhymeWords,
    Color? rhymeColor,
  }) {
    removeOverlay();

    final screenSize = MediaQuery.of(context).size;
    const maxWidth = 420.0;
    const maxHeight = 600.0;

    double left = globalPosition.dx + 8;
    double top = globalPosition.dy + 20;

    if (left + maxWidth > screenSize.width) {
      left = screenSize.width - maxWidth - 16;
    }
    if (top + maxHeight > screenSize.height) {
      top = globalPosition.dy - maxHeight - 8;
    }
    if (top < 0) top = 8;

    _activeOverlay = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: removeOverlay,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: _DesktopPopupWrapper(
                word: word,
                suggestionsFuture: suggestionsFuture,
                existingRhymeWords: existingRhymeWords,
                rhymeColor: rhymeColor,
                onInsert: (s) {
                  removeOverlay();
                  onInsert(s);
                },
                onDismiss: removeOverlay,
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_activeOverlay!);
  }
}

class _DesktopPopupWrapper extends StatelessWidget {
  final String word;
  final Future<RhymeResult> suggestionsFuture;
  final List<String>? existingRhymeWords;
  final Color? rhymeColor;
  final void Function(String) onInsert;
  final VoidCallback onDismiss;

  const _DesktopPopupWrapper({
    required this.word,
    required this.suggestionsFuture,
    required this.onInsert,
    required this.onDismiss,
    this.existingRhymeWords,
    this.rhymeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = rhymeColor ?? AppTheme.accent;
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
      decoration: BoxDecoration(
        color: AppTheme.appleCardBackground.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppTheme.appleRadiusM),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(color),
          const Divider(height: 1, color: AppTheme.border),
          Flexible(
            child: ModernRhymeContent(
              word: word,
              suggestionsFuture: suggestionsFuture,
              existingRhymeWords: existingRhymeWords,
              rhymeColor: rhymeColor,
              onInsert: onInsert,
              showHeader: false,
              useWrapFilters: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.appleSpacingM,
        AppTheme.appleSpacingS,
        AppTheme.appleSpacingXS,
        AppTheme.appleSpacingS,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.auto_fix_high,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: AppTheme.appleSpacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rymy',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  word,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro Display',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onDismiss();
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.close,
                size: 16,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
