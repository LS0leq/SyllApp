import 'package:flutter/material.dart';
import '../../domain/entities/lyric.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_utils.dart';

class StatsPanel extends StatefulWidget {
  final Lyric lyricModel;

  const StatsPanel({
    super.key,
    required this.lyricModel,
  });

  @override
  State<StatsPanel> createState() => _StatsPanelState();
}

class _StatsPanelState extends State<StatsPanel> {
  bool _rhymeSchemeExpanded = true;
  bool _overviewExpanded = true;
  bool _rhymeGroupsExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.sidebarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Text(
              'STATYSTYKI',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  
                  _buildCollapsibleSection(
                    title: 'Schemat rymów',
                    isExpanded: _rhymeSchemeExpanded,
                    onToggle: () => setState(() => _rhymeSchemeExpanded = !_rhymeSchemeExpanded),
                    child: _buildRhymeSchemeContent(),
                  ),
                  
                  _buildCollapsibleSection(
                    title: 'Przegląd',
                    isExpanded: _overviewExpanded,
                    onToggle: () => setState(() => _overviewExpanded = !_overviewExpanded),
                    child: _buildOverviewContent(),
                  ),
                  
                  _buildCollapsibleSection(
                    title: 'Grupy rymów',
                    isExpanded: _rhymeGroupsExpanded,
                    onToggle: () => setState(() => _rhymeGroupsExpanded = !_rhymeGroupsExpanded),
                    child: _buildRhymeGroupsContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    final isMobile = ResponsiveUtils.isMobilePlatform;
    final touchHeight = isMobile ? 48.0 : 32.0;
    final iconSize = isMobile ? 20.0 : 16.0;
    final fontSize = isMobile ? 13.0 : 11.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          hoverColor: AppTheme.hoverBackground,
          child: Container(
            height: touchHeight,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 12),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: iconSize,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(
              left: isMobile ? 16 : 12, 
              right: isMobile ? 16 : 12, 
              bottom: isMobile ? 12 : 8,
            ),
            child: child,
          ),
      ],
    );
  }

  Widget _buildRhymeSchemeContent() {
    final scheme = widget.lyricModel.rhymeScheme;
    if (scheme.isEmpty || scheme == '-' * scheme.length) {
      return const Text(
        'Brak wykrytych rymów',
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          fontStyle: FontStyle.italic,
          fontFamily: 'Segoe UI',
        ),
      );
    }
    
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: scheme.split('').asMap().entries.map((entry) {
        final letter = entry.value;
        final isRhyme = letter != '-';
        final colorIndex = isRhyme ? letter.codeUnitAt(0) - 65 : 0;
        
        return Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isRhyme 
                ? AppTheme.getRhymeColor(colorIndex).withValues(alpha: 0.2)
                : AppTheme.editorBackground,
            borderRadius: BorderRadius.circular(4),
            border: isRhyme
                ? Border.all(color: AppTheme.getRhymeColor(colorIndex), width: 1)
                : null,
          ),
          child: Text(
            letter,
            style: TextStyle(
              color: isRhyme ? AppTheme.getRhymeColor(colorIndex) : AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Consolas',
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOverviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatRow('Wersy', widget.lyricModel.lineCount.toString()),
        _buildStatRow('Sylaby', widget.lyricModel.totalSyllables.toString()),
        _buildStatRow('Średnio sylab/wers', 
          widget.lyricModel.lineCount > 0 
              ? (widget.lyricModel.totalSyllables / widget.lyricModel.lineCount).toStringAsFixed(1)
              : '0'),
        _buildStatRow('Grupy rymów', widget.lyricModel.rhymeGroups.length.toString()),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontFamily: 'Segoe UI',
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.editorBackground,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Consolas',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRhymeGroupsContent() {
    final groups = widget.lyricModel.rhymeGroups;
    
    if (groups.isEmpty) {
      return const Text(
        'Brak wykrytych grup rymów',
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          fontStyle: FontStyle.italic,
          fontFamily: 'Segoe UI',
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.asMap().entries.map((entry) {
        final int index = entry.key;
        final words = entry.value;
        final color = AppTheme.getRhymeColor(index);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(4),
            border: Border(
              left: BorderSide(color: color, width: 3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Consolas',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${words.length} słów',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: words.map((word) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.editorBackground,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    word,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontFamily: 'Consolas',
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
