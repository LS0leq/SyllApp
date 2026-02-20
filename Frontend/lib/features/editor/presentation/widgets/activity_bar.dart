import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ActivityBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback? onSettingsPressed;

  const ActivityBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      color: AppTheme.activityBarBackground,
      child: Column(
        children: [
          _buildActivityItem(
            index: 0,
            icon: Icons.file_copy_outlined,
            tooltip: 'Explorer',
          ),
          _buildActivityItem(
            index: 1,
            icon: Icons.search,
            tooltip: 'Search',
          ),
          _buildActivityItem(
            index: 2,
            icon: Icons.bar_chart,
            tooltip: 'Statistics',
          ),
          const Spacer(),
          _buildSettingsButton(),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required int index,
    required IconData icon,
    required String tooltip,
  }) {
    final isSelected = selectedIndex == index;
    
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: () => onItemSelected(index),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? AppTheme.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: isSelected ? AppTheme.iconActive : AppTheme.iconInactive,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Tooltip(
      message: 'Settings',
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: onSettingsPressed,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: const Icon(
            Icons.settings_outlined,
            size: 22,
            color: AppTheme.iconInactive,
          ),
        ),
      ),
    );
  }
}
