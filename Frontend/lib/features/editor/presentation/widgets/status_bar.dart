import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StatusBar extends StatelessWidget {
  final int lineCount;
  final int totalSyllables;
  final int currentLine;
  final int currentColumn;
  final String? rhymeScheme;
  final String? fileName;

  const StatusBar({
    super.key,
    required this.lineCount,
    required this.totalSyllables,
    this.currentLine = 1,
    this.currentColumn = 1,
    this.rhymeScheme,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      color: AppTheme.statusBarBackground,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _buildStatusItem(text: 'SyllApp'),
          const SizedBox(width: 8),
          Expanded(child: Container()),
          _buildStatusItem(text: 'Ln $currentLine, Kol $currentColumn'),
          _buildDivider(),
          _buildStatusItem(text: '$lineCount wersów'),
          _buildDivider(),
          _buildStatusItem(text: '$totalSyllables sylab'),
          if (rhymeScheme != null && rhymeScheme!.isNotEmpty) ...[
            _buildDivider(),
            Flexible(
              child: _buildStatusItem(text: 'Rymy: $rhymeScheme'),
            ),
          ],
          _buildDivider(),
          _buildStatusItem(text: 'UTF-8'),
        ],
      ),
    );
  }

  Widget _buildStatusItem({required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Segoe UI',
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white38,
    );
  }
}
