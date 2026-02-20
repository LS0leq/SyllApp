import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HardwareKeyboard, LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/syllable_counter.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/settings/settings_providers.dart';
import '../../application/editor_providers.dart';
import '../../domain/entities/lyric.dart';
import '../../domain/entities/verse.dart';
import 'rhyme_overlay.dart';
import 'rhyme_suggestion_popup.dart';








class VerseEditor extends ConsumerStatefulWidget {
  final Lyric lyricModel;
  final TextEditingController controller;
  final void Function(String text)? onTextChanged;
  final void Function(int lineIndex, String currentWord)? onCursorChanged;

  const VerseEditor({
    super.key,
    required this.lyricModel,
    required this.controller,
    this.onTextChanged,
    this.onCursorChanged,
  });

  @override
  ConsumerState<VerseEditor> createState() => _VerseEditorState();
}

class _VerseEditorState extends ConsumerState<VerseEditor> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _verticalScrollController = ScrollController();
  final ValueNotifier<double> _verticalOffsetNotifier = ValueNotifier(0.0);

  
  Timer? _longPressTimer;
  Offset? _longPressStartLocal;
  Offset? _longPressStartGlobal;

  
  List<double> _cachedLineYOffsets = [];
  double _cachedContentWidth = 0;

  static const double _lineNumberWidthDesktop = 52.0;
  static const double _syllableCountWidthDesktop = 36.0;
  static const double _lineNumberWidthMobile = 30.0;
  static const double _syllableCountWidthMobile = 20.0;
  static const double _editorPaddingLeft = 12.0;
  static const double _editorPaddingTop = 8.0;
  static const double _editorPaddingRight = 32.0;

  double _getLineNumberWidth(BuildContext context) =>
      ResponsiveUtils.isMobile(context) ? _lineNumberWidthMobile : _lineNumberWidthDesktop;

  double _getSyllableCountWidth(BuildContext context) =>
      ResponsiveUtils.isMobile(context) ? _syllableCountWidthMobile : _syllableCountWidthDesktop;

  double _getGutterWidth(BuildContext context) =>
      _getLineNumberWidth(context) + _getSyllableCountWidth(context);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleCursorChange);
    _verticalScrollController.addListener(_onVerticalScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleCursorChange);
    _verticalScrollController.removeListener(_onVerticalScroll);
    _verticalScrollController.dispose();
    _verticalOffsetNotifier.dispose();
    _longPressTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  

  void _onVerticalScroll() {
    _verticalOffsetNotifier.value = _verticalScrollController.offset;
  }

  

  
  
  
  List<double> _computeLineYOffsets(
    List<String> lines,
    double fontSize,
    double contentWidth,
  ) {
    final singleLineHeight = _computeLineHeight(fontSize);

    if (contentWidth <= 0) {
      return List.generate(lines.length + 1, (i) => i * singleLineHeight);
    }

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontFamily: 'Consolas',
      height: 1.6,
    );
    final strut = StrutStyle(
      fontSize: fontSize,
      height: 1.6,
      forceStrutHeight: true,
    );

    final offsets = <double>[0.0];
    for (final line in lines) {
      final tp = TextPainter(
        text: TextSpan(text: line.isEmpty ? ' ' : line, style: textStyle),
        textDirection: TextDirection.ltr,
        strutStyle: strut,
      );
      tp.layout(maxWidth: contentWidth);
      offsets.add(offsets.last + tp.height);
    }
    return offsets;
  }

  

  void _handleCursorChange() {
    if (widget.onCursorChanged == null) return;

    final text = widget.controller.text;
    final cursorPos = widget.controller.selection.baseOffset;
    if (cursorPos < 0 || cursorPos > text.length) return;

    final lines = text.split('\n');
    int currentPos = 0;
    int lineIndex = 0;
    String currentWord = '';

    for (int i = 0; i < lines.length; i++) {
      final lineLength = lines[i].length + 1; 
      if (currentPos + lineLength > cursorPos) {
        lineIndex = i;
        final posInLine = cursorPos - currentPos;
        currentWord = _getWordAtPosition(lines[i], posInLine);
        break;
      }
      currentPos += lineLength;
    }

    widget.onCursorChanged?.call(lineIndex, currentWord);
  }

  String _getWordAtPosition(String line, int position) {
    if (position < 0 || position > line.length) return '';

    int start = position;
    int end = position;

    while (start > 0 && !_isWordBoundary(line[start - 1])) {
      start--;
    }
    while (end < line.length && !_isWordBoundary(line[end])) {
      end++;
    }

    return line.substring(start, end);
  }

  bool _isWordBoundary(String char) {
    return char == ' ' ||
        char == '\t' ||
        char == '\n' ||
        char == ',' ||
        char == '.' ||
        char == '!' ||
        char == '?' ||
        char == ';' ||
        char == ':';
  }

  

  
  int _getLineIndexAtY(double y, List<double> lineYOffsets) {
    for (int i = 0; i < lineYOffsets.length - 1; i++) {
      if (y < lineYOffsets[i + 1]) return i;
    }
    return (lineYOffsets.length - 2).clamp(0, lineYOffsets.length - 2);
  }

  
  
  String? _getWordAtTapPosition(Offset localPosition, double fontSize) {
    final lineYOffsets = _cachedLineYOffsets;
    final contentWidth = _cachedContentWidth;
    if (lineYOffsets.length < 2) return null;

    final scrollOffset = _verticalScrollController.hasClients
        ? _verticalScrollController.offset
        : 0.0;

    final adjustedY = localPosition.dy + scrollOffset - _editorPaddingTop;
    final adjustedX = localPosition.dx - _editorPaddingLeft;

    if (adjustedY < 0 || adjustedX < 0) return null;

    final lines = widget.controller.text.split('\n');
    final lineIndex = _getLineIndexAtY(adjustedY, lineYOffsets);
    if (lineIndex < 0 || lineIndex >= lines.length) return null;

    final line = lines[lineIndex];
    if (line.isEmpty) return null;

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontFamily: 'Consolas',
      height: 1.6,
    );
    final tp = TextPainter(
      text: TextSpan(text: line, style: textStyle),
      textDirection: TextDirection.ltr,
      strutStyle: StrutStyle(fontSize: fontSize, height: 1.6, forceStrutHeight: true),
    );
    tp.layout(maxWidth: contentWidth > 0 ? contentWidth : double.infinity);

    
    final yInLine = adjustedY - lineYOffsets[lineIndex];
    final offset = tp.getPositionForOffset(Offset(adjustedX, yInLine));
    final charIndex = offset.offset;

    final word = _getWordAtPosition(line, charIndex);
    return word.isEmpty ? null : word;
  }

  
  
  ({int groupIndex, List<String> words, Color color})? _findRhymeGroupForWord(
    String word,
    Map<int, Map<String, int>> stanzaRhymes,
  ) {
    final lowerWord = word.toLowerCase();
    for (final lineEntry in stanzaRhymes.entries) {
      for (final wordEntry in lineEntry.value.entries) {
        if (wordEntry.key == lowerWord) {
          final groupIndex = wordEntry.value;
          
          final groupWords = <String>{};
          for (final le in stanzaRhymes.entries) {
            for (final we in le.value.entries) {
              if (we.value == groupIndex) {
                groupWords.add(we.key);
              }
            }
          }
          return (
            groupIndex: groupIndex,
            words: groupWords.toList(),
            color: AppTheme.getRhymeColor(groupIndex),
          );
        }
      }
    }
    return null;
  }

  Widget _buildMobileContextMenu(
    BuildContext context,
    EditableTextState editableTextState,
    double fontSize,
    Map<int, Map<String, int>> stanzaRhymes,
  ) {
    final buttonItems = editableTextState.contextMenuButtonItems;

    final sel = widget.controller.selection;
    final text = widget.controller.text;
    String? selectedWord;
    if (sel.isValid && !sel.isCollapsed) {
      selectedWord = text.substring(sel.start, sel.end).trim();
      if (selectedWord.contains(' ') || selectedWord.isEmpty) {
        selectedWord = null;
      }
    }

    if (selectedWord != null) {
      buttonItems.add(
        ContextMenuButtonItem(
          label: 'Rymy',
          onPressed: () {
            ContextMenuController.removeAny();
            final word = selectedWord!;
            final rhymeGroup = _findRhymeGroupForWord(word, stanzaRhymes);
            final repo = ref.read(rhymeSuggestionRepositoryProvider);

            final renderBox = context.findRenderObject() as RenderBox?;
            final globalPos = renderBox != null
                ? renderBox.localToGlobal(Offset.zero) + const Offset(100, 100)
                : Offset.zero;

            RhymeSuggestionPopup.show(
              context: this.context,
              word: word,
              suggestionsFuture: repo.getRhymeSuggestions(word),
              globalPosition: globalPos,
              existingRhymeWords: rhymeGroup?.words,
              rhymeColor: rhymeGroup?.color,
              onInsert: _insertSuggestionAtCursor,
            );
          },
        ),
      );
    }

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }

  void _insertSuggestionAtCursor(String suggestion) {
    final controller = widget.controller;
    final selection = controller.selection;
    final text = controller.text;
    final cursorPos = selection.baseOffset;

    if (cursorPos < 0 || cursorPos > text.length) return;

    
    final prefix =
        cursorPos > 0 && text[cursorPos - 1] != ' ' && text[cursorPos - 1] != '\n'
            ? ' '
            : '';
    final insertText = '$prefix$suggestion';

    final newText =
        text.substring(0, cursorPos) + insertText + text.substring(cursorPos);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: cursorPos + insertText.length),
    );
    widget.onTextChanged?.call(newText);
  }

  

  void _handleSecondaryTapDown(TapDownDetails details, double fontSize,
      Map<int, Map<String, int>> stanzaRhymes) {
    final word = _getWordAtTapPosition(details.localPosition, fontSize);
    if (word == null) return;

    final rhymeGroup = _findRhymeGroupForWord(word, stanzaRhymes);
    final repo = ref.read(rhymeSuggestionRepositoryProvider);

    RhymeSuggestionPopup.show(
      context: context,
      word: word,
      suggestionsFuture: repo.getRhymeSuggestions(word),
      globalPosition: details.globalPosition,
      existingRhymeWords: rhymeGroup?.words,
      rhymeColor: rhymeGroup?.color,
      onInsert: _insertSuggestionAtCursor,
    );
  }

  

  void _onPointerDown(PointerDownEvent event, double fontSize,
      Map<int, Map<String, int>> stanzaRhymes) {
    _longPressStartLocal = event.localPosition;
    _longPressStartGlobal = event.position;

    final delay = ResponsiveUtils.isMobilePlatform ? 350 : 500;

    _longPressTimer = Timer(Duration(milliseconds: delay), () {
      if (_longPressStartLocal == null) return;

      final word = _getWordAtTapPosition(_longPressStartLocal!, fontSize);
      if (word == null) return;

      if (ResponsiveUtils.isMobilePlatform) {
        final sel = widget.controller.selection;
        if (sel.isValid && !sel.isCollapsed) {
          widget.controller.selection =
              TextSelection.collapsed(offset: sel.baseOffset);
        }
        _focusNode.unfocus();
      }

      final rhymeGroup = _findRhymeGroupForWord(word, stanzaRhymes);
      final repo = ref.read(rhymeSuggestionRepositoryProvider);

      RhymeSuggestionPopup.show(
        context: context,
        word: word,
        suggestionsFuture: repo.getRhymeSuggestions(word),
        globalPosition: _longPressStartGlobal!,
        existingRhymeWords: rhymeGroup?.words,
        rhymeColor: rhymeGroup?.color,
        onInsert: _insertSuggestionAtCursor,
      );
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_longPressStartLocal != null &&
        (event.localPosition - _longPressStartLocal!).distance > 10) {
      _longPressTimer?.cancel();
      _longPressStartLocal = null;
      _longPressStartGlobal = null;
    }
  }

  void _onPointerUpOrCancel() {
    _longPressTimer?.cancel();
    _longPressStartLocal = null;
    _longPressStartGlobal = null;
  }

  

  double _computeLineHeight(double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'Ag',
        style: TextStyle(fontSize: fontSize, fontFamily: 'Consolas', height: 1.6),
      ),
      textDirection: TextDirection.ltr,
      strutStyle: StrutStyle(fontSize: fontSize, height: 1.6, forceStrutHeight: true),
    );
    tp.layout();
    return tp.preferredLineHeight;
  }

  

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);
    final fontSize = settings.fontSize;
    final lineHeight = _computeLineHeight(fontSize);
    final lines = widget.controller.text.split('\n');

    
    final rhymeState = ref.watch(rhymeNotifierProvider);
    final stanzaRhymes = rhymeState.stanzaRhymes;

    final editorTextStyle = TextStyle(
      color: AppTheme.textPrimary,
      fontSize: fontSize,
      fontFamily: 'Consolas',
      height: 1.6,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final gutterWidth = _getGutterWidth(context);
        final lineNumberWidth = _getLineNumberWidth(context);
        final syllableCountWidth = _getSyllableCountWidth(context);

        final totalWidth = constraints.maxWidth;
        final editorAreaWidth = totalWidth - gutterWidth;
        final contentWidth =
            editorAreaWidth - _editorPaddingLeft - _editorPaddingRight;
        final lineYOffsets =
            _computeLineYOffsets(lines, fontSize, contentWidth);

        
        _cachedLineYOffsets = lineYOffsets;
        _cachedContentWidth = contentWidth;

        return Container(
          color: AppTheme.editorBackground,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Container(
                width: gutterWidth,
                decoration: AppTheme.gutterDecoration,
                child: ValueListenableBuilder<double>(
                  valueListenable: _verticalOffsetNotifier,
                  builder: (context, scrollOffset, _) {
                    return CustomPaint(
                      painter: _GutterPainter(
                        lines: lines,
                        verses: widget.lyricModel.verses,
                        scrollOffset: scrollOffset,
                        fontSize: fontSize,
                        lineHeight: lineHeight,
                        lineYOffsets: lineYOffsets,
                        lineNumberWidth: lineNumberWidth,
                        syllableCountWidth: syllableCountWidth,
                      ),
                      size: Size(gutterWidth, double.infinity),
                    );
                  },
                ),
              ),

              
              Expanded(
                child: Stack(
                  children: [
                    
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      
                      onSecondaryTapDown: ResponsiveUtils.isDesktopPlatform
                          ? (details) => _handleSecondaryTapDown(
                                details, fontSize, stanzaRhymes)
                          : null,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) => false,
                        child: SingleChildScrollView(
                          controller: _verticalScrollController,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _EditorLinesPainter(
                                    lines: lines,
                                    fontSize: fontSize,
                                    lineHeight: lineHeight,
                                    lineYOffsets: lineYOffsets,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: _editorPaddingLeft,
                                  top: _editorPaddingTop,
                                  right: _editorPaddingRight,
                                  bottom: 200,
                                ),
                                child: TextField(
                                  controller: widget.controller,
                                  focusNode: _focusNode,
                                  maxLines: null,
                                  style: editorTextStyle,
                                  strutStyle: StrutStyle(
                                    fontSize: fontSize,
                                    height: 1.6,
                                    forceStrutHeight: true,
                                  ),
                                  
                                  
                                  contextMenuBuilder: ResponsiveUtils.isMobilePlatform
                                      ? (context, editableTextState) =>
                                          _buildMobileContextMenu(
                                              context, editableTextState, fontSize, stanzaRhymes)
                                      : (context, editableTextState) => const SizedBox.shrink(),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    hintText: 'Zacznij pisać...',
                                    hintStyle: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                  onChanged: (text) {
                                    setState(() {}); 
                                    widget.onTextChanged?.call(text);
                                  },
                                ),
                              ),

                              
                              if (stanzaRhymes.isNotEmpty)
                                Positioned.fill(
                                  child: RhymeOverlay(
                                    lines: lines,
                                    stanzaRhymes: stanzaRhymes,
                                    fontSize: fontSize,
                                    lineHeight: lineHeight,
                                    lineYOffsets: lineYOffsets,
                                    editorContentWidth: contentWidth,
                                    editorPaddingLeft: _editorPaddingLeft,
                                    editorPaddingTop: _editorPaddingTop,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    
                    if (kIsWeb)
                      Positioned.fill(
                        child: Listener(
                          behavior: HitTestBehavior.translucent,
                          onPointerDown: (event) {
                            final keys = HardwareKeyboard.instance.logicalKeysPressed;
                            if (keys.contains(LogicalKeyboardKey.controlLeft) ||
                                keys.contains(LogicalKeyboardKey.controlRight)) {
                              _handleSecondaryTapDown(
                                TapDownDetails(
                                  localPosition: event.localPosition,
                                  globalPosition: event.position,
                                ),
                                fontSize,
                                stanzaRhymes,
                              );
                            }
                          },
                          child: const SizedBox.expand(),
                        ),
                      ),

                    
                    if (ResponsiveUtils.isMobilePlatform || kIsWeb)
                      Positioned.fill(
                        child: Listener(
                          behavior: HitTestBehavior.translucent,
                          onPointerDown: (event) =>
                              _onPointerDown(event, fontSize, stanzaRhymes),
                          onPointerMove: _onPointerMove,
                          onPointerUp: (_) => _onPointerUpOrCancel(),
                          onPointerCancel: (_) => _onPointerUpOrCancel(),
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}




class _GutterPainter extends CustomPainter {
  final List<String> lines;
  final List<Verse> verses;
  final double scrollOffset;
  final double fontSize;
  final double lineHeight;
  final List<double> lineYOffsets;
  final double lineNumberWidth;
  final double syllableCountWidth;

  _GutterPainter({
    required this.lines,
    required this.verses,
    required this.scrollOffset,
    required this.fontSize,
    required this.lineHeight,
    required this.lineYOffsets,
    required this.lineNumberWidth,
    required this.syllableCountWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lineNumberPainter = TextPainter(textDirection: TextDirection.ltr);
    final syllablePainter = TextPainter(textDirection: TextDirection.ltr);

    const paddingTop = 8.0;

    final editorRefPainter = TextPainter(
      text: TextSpan(
        text: 'Ag',
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Consolas',
          height: 1.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    editorRefPainter.layout();
    final editorBaseline = editorRefPainter.computeDistanceToActualBaseline(
        TextBaseline.alphabetic);

    final linePaint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;

    final gutterWidth = lineNumberWidth + syllableCountWidth;

    for (int i = 0; i < lines.length; i++) {
      final lineY = (i < lineYOffsets.length) ? lineYOffsets[i] : i * lineHeight;
      final nextLineY = (i + 1 < lineYOffsets.length)
          ? lineYOffsets[i + 1]
          : lineY + lineHeight;
      final rowHeight = nextLineY - lineY;

      final baseYPosition = paddingTop + lineY - scrollOffset;

      if (baseYPosition + rowHeight < 0 || baseYPosition > size.height) continue;

      
      final lineBottomY = baseYPosition + rowHeight;
      canvas.drawLine(
        Offset(0, lineBottomY),
        Offset(gutterWidth, lineBottomY),
        linePaint,
      );

      
      lineNumberPainter.text = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: fontSize * 0.8,
          fontFamily: 'Consolas',
          height: 1.6,
        ),
      );
      lineNumberPainter.layout();

      final lineNumberBaseline = lineNumberPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      final yPosition = baseYPosition + editorBaseline - lineNumberBaseline;

      final lineNumberPadding = lineNumberWidth < 40 ? 4.0 : 8.0;
      lineNumberPainter.paint(
        canvas,
        Offset(lineNumberWidth - lineNumberPainter.width - lineNumberPadding, yPosition),
      );

      
      int syllableCount = 0;
      if (i < verses.length) {
        syllableCount = verses[i].syllableCount;
      } else {
        syllableCount = SyllableCounter.countInLine(lines[i]);
      }

      if (syllableCount > 0) {
        syllablePainter.text = TextSpan(
          text: syllableCount.toString(),
          style: TextStyle(
            color: AppTheme.textAccent,
            fontSize: fontSize * 0.75,
            fontFamily: 'Consolas',
            fontWeight: FontWeight.w500,
            height: 1.6,
          ),
        );
        syllablePainter.layout();

        final syllableBaseline = syllablePainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
        final syllableYPosition = baseYPosition + editorBaseline - syllableBaseline;

        syllablePainter.paint(
          canvas,
          Offset(
            lineNumberWidth +
                (syllableCountWidth - syllablePainter.width) / 2,
            syllableYPosition,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GutterPainter oldDelegate) {
    return oldDelegate.lines.length != lines.length ||
        oldDelegate.verses != verses ||
        oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.fontSize != fontSize ||
        oldDelegate.lineYOffsets != lineYOffsets;
  }
}

class _EditorLinesPainter extends CustomPainter {
  final List<String> lines;
  final double fontSize;
  final double lineHeight;
  final List<double> lineYOffsets;

  _EditorLinesPainter({
    required this.lines,
    required this.fontSize,
    required this.lineHeight,
    required this.lineYOffsets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const paddingTop = 8.0;

    final linePaint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;

    for (int i = 0; i < lines.length; i++) {
      final lineY = (i < lineYOffsets.length) ? lineYOffsets[i] : i * lineHeight;
      final nextLineY = (i + 1 < lineYOffsets.length)
          ? lineYOffsets[i + 1]
          : lineY + lineHeight;
      final lineBottomY = paddingTop + nextLineY;

      if (lineBottomY < 0 || paddingTop + lineY > size.height) continue;

      canvas.drawLine(
        Offset(0, lineBottomY),
        Offset(size.width, lineBottomY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_EditorLinesPainter oldDelegate) {
    return oldDelegate.lines.length != lines.length ||
        oldDelegate.fontSize != fontSize ||
        oldDelegate.lineYOffsets != lineYOffsets;
  }
}
