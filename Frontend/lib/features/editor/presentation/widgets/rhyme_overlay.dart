import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/rhyme_detector.dart';
import '../../../../core/utils/responsive_utils.dart';


class RhymeOverlay extends StatefulWidget {
  final List<String> lines;
  final Map<int, Map<String, int>> stanzaRhymes;
  final double fontSize;
  final double lineHeight;
  final List<double> lineYOffsets;
  final double editorContentWidth;
  final double editorPaddingLeft;
  final double editorPaddingTop;

  const RhymeOverlay({
    super.key,
    required this.lines,
    required this.stanzaRhymes,
    required this.fontSize,
    required this.lineHeight,
    required this.lineYOffsets,
    required this.editorContentWidth,
    this.editorPaddingLeft = 12.0,
    this.editorPaddingTop = 8.0,
  });

  @override
  State<RhymeOverlay> createState() => _RhymeOverlayState();
}

class _RhymeOverlayState extends State<RhymeOverlay> {
  OverlayEntry? _tooltipOverlay;
  RhymeWordInfo? _hoveredRhyme;

  
  
  List<_CachedRhymeLayout> _cachedLayoutData = const [];

  @override
  void initState() {
    super.initState();
    _rebuildLayoutCache();
  }

  @override
  void didUpdateWidget(RhymeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.lines != widget.lines ||
        oldWidget.stanzaRhymes != widget.stanzaRhymes ||
        oldWidget.fontSize != widget.fontSize ||
        oldWidget.lineYOffsets != widget.lineYOffsets ||
        oldWidget.editorContentWidth != widget.editorContentWidth) {
      _rebuildLayoutCache();
    }
  }

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  
  
  void _rebuildLayoutCache() {
    final result = <_CachedRhymeLayout>[];
    final textStyle = TextStyle(
      fontSize: widget.fontSize,
      fontFamily: 'Consolas',
      height: 1.6,
    );

    final padLeft = widget.editorPaddingLeft;
    final padTop = widget.editorPaddingTop;
    final contentWidth = widget.editorContentWidth;
    final lineYOffsets = widget.lineYOffsets;

    for (int lineIndex = 0; lineIndex < widget.lines.length; lineIndex++) {
      final line = widget.lines[lineIndex];
      if (!widget.stanzaRhymes.containsKey(lineIndex)) continue;

      final lineY = (lineIndex < lineYOffsets.length)
          ? lineYOffsets[lineIndex]
          : lineIndex * widget.lineHeight;

      final rhymesInLine = widget.stanzaRhymes[lineIndex]!;
      final matches =
          RegExp(r'[a-ząćęłńóśźżA-ZĄĆĘŁŃÓŚŹŻ]+').allMatches(line);

      
      final tp = TextPainter(
        text: TextSpan(text: line, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: contentWidth > 0 ? contentWidth : double.infinity);

      for (final match in matches) {
        final wordText = match.group(0)!;
        final cleanWord = wordText.toLowerCase();

        if (rhymesInLine.containsKey(cleanWord)) {
          
          final caretOffset = tp.getOffsetForCaret(
            TextPosition(offset: match.start),
            Rect.zero,
          );

          final tpWord = TextPainter(
            text: TextSpan(text: wordText, style: textStyle),
            textDirection: TextDirection.ltr,
          );
          tpWord.layout();
          final wordWidth = tpWord.width;

          final rhymeGroup = rhymesInLine[cleanWord]!;

          result.add(_CachedRhymeLayout(
            word: cleanWord,
            lineIndex: lineIndex,
            baseX: padLeft + caretOffset.dx,
            baseY: padTop + lineY + caretOffset.dy,
            width: wordWidth,
            groupIndex: rhymeGroup,
            color: AppTheme.getRhymeColor(rhymeGroup),
          ));
        }
      }
    }
    _cachedLayoutData = result;
  }

  void _removeTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  List<String> _getRhymeGroupWords(int groupIndex) {
    final words = <String>{};
    for (var lineEntry in widget.stanzaRhymes.entries) {
      for (var wordEntry in lineEntry.value.entries) {
        if (wordEntry.value == groupIndex) {
          words.add(wordEntry.key);
        }
      }
    }
    return words.toList();
  }

  String _getRhymeEnding(String word) {
    return RhymeDetector.getRhymePart(word.toLowerCase());
  }

  
  List<RhymeWordInfo> _buildRhymeWordPositions() {
    final result = <RhymeWordInfo>[];
    final lineHeight = widget.lineHeight;

    for (final cached in _cachedLayoutData) {
      
      final yTop = cached.baseY;
      final xStart = cached.baseX;

      result.add(RhymeWordInfo(
        word: cached.word,
        lineIndex: cached.lineIndex,
        rect: Rect.fromLTWH(
            xStart - 1, yTop - 1, cached.width + 2, lineHeight),
        groupIndex: cached.groupIndex,
        color: cached.color,
      ));
    }
    return result;
  }

  RhymeWordInfo? _findRhymeAtPosition(
      Offset localPosition, List<RhymeWordInfo> rhymeWords) {
    for (final info in rhymeWords) {
      if (info.rect.contains(localPosition)) {
        return info;
      }
    }
    return null;
  }

  void _showTooltip(
      BuildContext context, Offset globalPosition, RhymeWordInfo info) {
    _removeTooltip();

    final rhymeWords = _getRhymeGroupWords(info.groupIndex);
    final rhymeEnding = _getRhymeEnding(info.word);

    
    final screenSize = MediaQuery.of(context).size;
    double left = globalPosition.dx + 10;
    double top = globalPosition.dy + 20;
    const tooltipMaxWidth = 280.0;

    if (left + tooltipMaxWidth > screenSize.width) {
      left = screenSize.width - tooltipMaxWidth - 16;
    }
    if (top + 200 > screenSize.height) {
      top = globalPosition.dy - 120;
    }

    _tooltipOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: tooltipMaxWidth),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.tooltipBackground,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: info.color.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: info.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rym: „-$rhymeEnding"',
                      style: TextStyle(
                        color: info.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'Consolas',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: AppTheme.border),
                const SizedBox(height: 8),
                const Text(
                  'Rymuje się z:',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: rhymeWords.map((w) {
                    final isCurrentWord =
                        w.toLowerCase() == info.word.toLowerCase();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrentWord
                            ? info.color.withValues(alpha: 0.3)
                            : info.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: isCurrentWord
                            ? Border.all(color: info.color, width: 1)
                            : null,
                      ),
                      child: Text(
                        w,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontFamily: 'Consolas',
                          fontWeight:
                              isCurrentWord ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  '${rhymeWords.length} ${_pluralize(rhymeWords.length, "słowo", "słowa", "słów")} w grupie',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontFamily: 'Segoe UI',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_tooltipOverlay!);
  }

  String _pluralize(int count, String one, String few, String many) {
    if (count == 1) return one;
    if (count >= 2 && count <= 4) return few;
    return many;
  }

  void _onHover(PointerHoverEvent event, List<RhymeWordInfo> rhymeWords) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPosition = box.globalToLocal(event.position);
    final hitRhyme = _findRhymeAtPosition(localPosition, rhymeWords);

    if (hitRhyme != _hoveredRhyme) {
      setState(() => _hoveredRhyme = hitRhyme);

      if (hitRhyme != null) {
        _showTooltip(context, event.position, hitRhyme);
      } else {
        _removeTooltip();
      }
    }
  }

  void _onExit(PointerExitEvent event) {
    setState(() => _hoveredRhyme = null);
    _removeTooltip();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stanzaRhymes.isEmpty) return const SizedBox.shrink();

    final isMobile = ResponsiveUtils.isMobilePlatform ||
        (kIsWeb && ResponsiveUtils.isMobile(context));

    
    final rhymeWords = _buildRhymeWordPositions();

    if (isMobile) {
      
      
      
      return IgnorePointer(
        child: CustomPaint(
          painter: _RhymeHighlightPainter(
            rhymeWords: rhymeWords,
            hoveredWord: _hoveredRhyme,
          ),
          size: Size.infinite,
        ),
      );
    }

    return MouseRegion(
      hitTestBehavior: HitTestBehavior.translucent,
      opaque: false,
      onHover: (event) => _onHover(event, rhymeWords),
      onExit: _onExit,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _RhymeHighlightPainter(
            rhymeWords: rhymeWords,
            hoveredWord: _hoveredRhyme,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}


class RhymeWordInfo {
  final String word;
  final int lineIndex;
  final Rect rect;
  final int groupIndex;
  final Color color;

  RhymeWordInfo({
    required this.word,
    required this.lineIndex,
    required this.rect,
    required this.groupIndex,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RhymeWordInfo &&
          word == other.word &&
          lineIndex == other.lineIndex;

  @override
  int get hashCode => word.hashCode ^ lineIndex.hashCode;
}

class _RhymeHighlightPainter extends CustomPainter {
  final List<RhymeWordInfo> rhymeWords;
  final RhymeWordInfo? hoveredWord;

  _RhymeHighlightPainter({
    required this.rhymeWords,
    required this.hoveredWord,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final info in rhymeWords) {
      
      if (info.rect.right < 0 || info.rect.left > size.width) continue;
      if (info.rect.bottom < 0 || info.rect.top > size.height) continue;

      final isHovered = hoveredWord == info;

      
      final bgPaint = Paint()
        ..color = info.color.withValues(alpha: isHovered ? 0.2 : 0.1)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(info.rect, const Radius.circular(3)),
        bgPaint,
      );

      
      final underlinePaint = Paint()
        ..color = info.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHovered ? 3.0 : 2.5;

      final underlineY = info.rect.bottom - 3;
      canvas.drawLine(
        Offset(info.rect.left + 1, underlineY),
        Offset(info.rect.right - 1, underlineY),
        underlinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RhymeHighlightPainter oldDelegate) =>
      oldDelegate.rhymeWords != rhymeWords ||
      oldDelegate.hoveredWord != hoveredWord;
}



class _CachedRhymeLayout {
  final String word;
  final int lineIndex;
  final double baseX; 
  final double baseY; 
  final double width;
  final int groupIndex;
  final Color color;

  const _CachedRhymeLayout({
    required this.word,
    required this.lineIndex,
    required this.baseX,
    required this.baseY,
    required this.width,
    required this.groupIndex,
    required this.color,
  });
}
