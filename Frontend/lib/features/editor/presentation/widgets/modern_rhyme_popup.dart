import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/floating_glass_sheet.dart';
import '../../../../core/widgets/top_toast.dart';
import '../../domain/entities/rhyme_result.dart';

class ModernRhymePopup {
  static void show({
    required BuildContext context,
    required String word,
    required Future<RhymeResult> suggestionsFuture,
    required void Function(String suggestion) onInsert,
    List<String>? existingRhymeWords,
    Color? rhymeColor,
  }) {
    FloatingGlassSheet.show(
      context: context,
      child: _ModernRhymeContent(
        word: word,
        suggestionsFuture: suggestionsFuture,
        existingRhymeWords: existingRhymeWords,
        rhymeColor: rhymeColor,
        onInsert: onInsert,
      ),
    );
  }
}

class ModernRhymeContent extends StatefulWidget {
  final String word;
  final Future<RhymeResult> suggestionsFuture;
  final List<String>? existingRhymeWords;
  final Color? rhymeColor;
  final void Function(String) onInsert;
  final bool showHeader;
  final bool useWrapFilters;

  const ModernRhymeContent({
    super.key,
    required this.word,
    required this.suggestionsFuture,
    required this.onInsert,
    this.existingRhymeWords,
    this.rhymeColor,
    this.showHeader = true,
    this.useWrapFilters = false,
  });

  @override
  State<ModernRhymeContent> createState() => _ModernRhymeContentState();
}

class _ModernRhymeContent extends ModernRhymeContent {
  const _ModernRhymeContent({
    required super.word,
    required super.suggestionsFuture,
    required super.onInsert,
    super.existingRhymeWords,
    super.rhymeColor,
  });
}

class _ModernRhymeContentState extends State<ModernRhymeContent> {
  int _selectedTab = 0;
  int? _selectedSyllableFilter;
  RhymeResult? _cachedResult;

  bool get _hasExistingRhymes =>
      widget.existingRhymeWords != null && widget.existingRhymeWords!.isNotEmpty;

  List<int> get _availableSyllableCounts {
    if (_cachedResult == null || !_cachedResult!.isGrouped) return [];
    return _cachedResult!.bySyllableCount.keys.where((k) => k > 0).toList()
      ..sort();
  }

  List<String> get _filteredWords {
    if (_cachedResult == null) return [];
    if (_selectedSyllableFilter == null) return _cachedResult!.flat;
    return _cachedResult!.bySyllableCount[_selectedSyllableFilter] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.rhymeColor ?? AppTheme.accent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHeader) _buildHeader(color),
        if (_hasExistingRhymes) _buildTabSwitch(color),
        if (_hasExistingRhymes)
          const SizedBox(height: AppTheme.appleSpacingS)
        else
          const SizedBox(height: AppTheme.appleSpacingXS),
        Flexible(
          child: _selectedTab == 0
              ? _buildSuggestionsContent(color)
              : _buildExistingRhymesContent(color),
        ),
      ],
    );
  }

  Widget _buildHeader(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.appleSpacingL,
        AppTheme.appleSpacingM,
        AppTheme.appleSpacingL,
        AppTheme.appleSpacingS,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
            ),
            child: Icon(
              Icons.auto_fix_high,
              size: 20,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.word,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro Display',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitch(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.appleSpacingL),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.appleSystemGray6.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                label: 'Słownik rymów',
                icon: Icons.auto_awesome,
                isSelected: _selectedTab == 0,
                color: color,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTab = 0);
                },
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildTabButton(
                label: 'Grupa',
                icon: Icons.group_work,
                isSelected: _selectedTab == 1,
                color: color,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTab = 1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.appleSpacingS,
          horizontal: AppTheme.appleSpacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.appleRadiusS - 2),
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : AppTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppTheme.textMuted,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsContent(Color color) {
    return FutureBuilder<RhymeResult>(
      future: widget.suggestionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingShimmer();
        }

        final result = snapshot.data;
        if (result == null || result.isEmpty) {
          return _buildEmptyState();
        }

        _cachedResult = result;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (result.isGrouped) _buildSyllableFilters(color),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.appleSpacingL,
                  AppTheme.appleSpacingM,
                  AppTheme.appleSpacingL,
                  AppTheme.appleSpacingL,
                ),
                child: _buildWordCloud(_filteredWords, color),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSyllableFilters(Color color) {
    final syllableCounts = _availableSyllableCounts;

    final pills = <Widget>[
      _buildFilterPill(
        label: 'Wszystkie',
        count: _cachedResult?.totalCount ?? 0,
        isSelected: _selectedSyllableFilter == null,
        color: color,
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedSyllableFilter = null);
        },
      ),
      for (final syllableCount in syllableCounts)
        _buildFilterPill(
          label: _getSyllableLabel(syllableCount),
          count: (_cachedResult?.bySyllableCount[syllableCount] ?? []).length,
          isSelected: _selectedSyllableFilter == syllableCount,
          color: color,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedSyllableFilter = syllableCount);
          },
        ),
    ];

    if (widget.useWrapFilters) {
      final desktopPills = <Widget>[
        _buildDesktopFilterPill(
          label: 'Wszystkie',
          count: _cachedResult?.totalCount ?? 0,
          isSelected: _selectedSyllableFilter == null,
          color: color,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedSyllableFilter = null);
          },
        ),
        for (final syllableCount in syllableCounts)
          _buildDesktopFilterPill(
            label: _getSyllableLabel(syllableCount),
            count: (_cachedResult?.bySyllableCount[syllableCount] ?? []).length,
            isSelected: _selectedSyllableFilter == syllableCount,
            color: color,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedSyllableFilter = syllableCount);
            },
          ),
      ];

      return Padding(
        padding: const EdgeInsets.only(
          top: AppTheme.appleSpacingS,
          left: AppTheme.appleSpacingM,
          right: AppTheme.appleSpacingM,
        ),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: desktopPills,
        ),
      );
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: AppTheme.appleSpacingS),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.appleSpacingL),
        children: pills,
      ),
    );
  }

  Widget _buildDesktopFilterPill({
    required String label,
    required int count,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : AppTheme.appleSystemGray5.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.3)
                      : AppTheme.textMuted.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? color : AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required int count,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.appleSpacingXS),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.appleSpacingM,
            vertical: AppTheme.appleSpacingXS,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : AppTheme.appleSystemGray5.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.3)
                      : AppTheme.textMuted.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? color : AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordCloud(List<String> words, Color color) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Wrap(
        key: ValueKey(_selectedSyllableFilter),
        spacing: AppTheme.appleSpacingXS,
        runSpacing: AppTheme.appleSpacingXS,
        children: words.map((word) {
          return _buildWordChip(word, color);
        }).toList(),
      ),
    );
  }

  Widget _buildWordChip(String word, Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Clipboard.setData(ClipboardData(text: word));
        TopToast.show(
          context,
          message: 'Skopiowano "$word" do schowka',
          color: color,
          icon: Icons.content_copy_rounded,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.appleSpacingM,
          vertical: AppTheme.appleSpacingS,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Text(
          word,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Consolas',
          ),
        ),
      ),
    );
  }

  Widget _buildExistingRhymesContent(Color color) {
    final words = widget.existingRhymeWords!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.appleSpacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.group, size: 16, color: color),
              ),
              const SizedBox(width: AppTheme.appleSpacingS),
              Text(
                'Rymuje się z',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.appleSpacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${words.length} ${_pluralize(words.length, "słowo", "słowa", "słów")}',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.appleSpacingM),
          Wrap(
            spacing: AppTheme.appleSpacingXS,
            runSpacing: AppTheme.appleSpacingXS,
            children: words.map((w) {
              final isCurrent = w.toLowerCase() == widget.word.toLowerCase();
              return GestureDetector(
                onTap: isCurrent
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(ClipboardData(text: w));
                        TopToast.show(
                          context,
                          message: 'Skopiowano "$w" do schowka',
                          color: color,
                          icon: Icons.content_copy_rounded,
                        );
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.appleSpacingM,
                    vertical: AppTheme.appleSpacingS,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? color.withValues(alpha: 0.3)
                        : color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
                    border: Border.all(
                      color: isCurrent
                          ? color.withValues(alpha: 0.6)
                          : color.withValues(alpha: 0.25),
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCurrent)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: color,
                          ),
                        ),
                      Text(
                        w,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.w500,
                          fontFamily: 'Consolas',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.appleSpacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShimmerBox(width: double.infinity, height: 40),
          const SizedBox(height: AppTheme.appleSpacingM),
          Wrap(
            spacing: AppTheme.appleSpacingXS,
            runSpacing: AppTheme.appleSpacingXS,
            children: List.generate(
              12,
              (i) => _ShimmerBox(
                width: 80.0 + (i % 3) * 30,
                height: 44,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.appleSpacingXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.appleSpacingL),
            decoration: BoxDecoration(
              color: AppTheme.appleSystemGray6.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 48,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppTheme.appleSpacingM),
          Text(
            'Brak rymów',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Display',
            ),
          ),
          const SizedBox(height: AppTheme.appleSpacingXS),
          Text(
            'Nie znaleziono podpowiedzi dla tego słowa',
            style: TextStyle(
              color: AppTheme.textMuted.withValues(alpha: 0.7),
              fontSize: 14,
              fontFamily: 'SF Pro Display',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getSyllableLabel(int count) {
    if (count == 1) return '1 sylaba';
    if (count >= 2 && count <= 4) return '$count sylaby';
    return '$count sylab';
  }

  String _pluralize(int count, String one, String few, String many) {
    if (count == 1) return one;
    if (count >= 2 && count <= 4) return few;
    return many;
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.appleRadiusS),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(1.0 + _controller.value * 2, 0),
              colors: [
                AppTheme.appleSystemGray6.withValues(alpha: 0.3),
                AppTheme.appleSystemGray5.withValues(alpha: 0.5),
                AppTheme.appleSystemGray6.withValues(alpha: 0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}
