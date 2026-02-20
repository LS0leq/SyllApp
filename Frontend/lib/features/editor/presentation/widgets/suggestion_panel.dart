import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SuggestionPanel extends StatelessWidget {
  final String currentWord;
  final List<String> suggestions;
  final Function(String) onSuggestionSelected;

  const SuggestionPanel({
    super.key,
    required this.currentWord,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty || currentWord.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200, maxWidth: 320),
      decoration: BoxDecoration(
        color: AppTheme.sidebarBackground,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: AppTheme.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 14,
                  color: AppTheme.accent,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Suggestions',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.editorBackground,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppTheme.border, width: 1),
                  ),
                  child: const Text(
                    'Tab',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontFamily: 'Consolas',
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return _buildSuggestionItem(suggestions[index], index == 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String suggestion, bool isFirst) {
    return InkWell(
      onTap: () => onSuggestionSelected(suggestion),
      hoverColor: AppTheme.hoverBackground,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isFirst 
              ? AppTheme.selectionBackground 
              : Colors.transparent,
        ),
        child: Row(
          children: [
            
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.syntaxVariable.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.abc,
                size: 12,
                color: AppTheme.syntaxVariable,
              ),
            ),
            
            Expanded(
              child: Text(
                suggestion,
                style: TextStyle(
                  color: isFirst ? AppTheme.textPrimary : AppTheme.textPrimary,
                  fontSize: 13,
                  fontFamily: 'Consolas',
                ),
              ),
            ),
            
            Text(
              'rhyme',
              style: TextStyle(
                color: AppTheme.textMuted.withValues(alpha: 0.7),
                fontSize: 11,
                fontFamily: 'Segoe UI',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
