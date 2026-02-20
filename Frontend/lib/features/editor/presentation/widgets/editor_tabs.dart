import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class EditorTab {
  final String id;
  final String fileName;
  final bool isModified;
  final IconData? icon;

  EditorTab({
    required this.id,
    required this.fileName,
    this.isModified = false,
    this.icon,
  });
}

class EditorTabs extends StatelessWidget {
  final List<EditorTab> tabs;
  final String activeTabId;
  final Function(String) onTabSelected;
  final Function(String) onTabClosed;

  const EditorTabs({
    super.key,
    required this.tabs,
    required this.activeTabId,
    required this.onTabSelected,
    required this.onTabClosed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      color: AppTheme.tabsBackground,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isActive = tab.id == activeTabId;
                return _buildTab(tab, isActive);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(EditorTab tab, bool isActive) {
    return GestureDetector(
      onTap: () => onTabSelected(tab.id),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200, minWidth: 100),
        height: 35,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.tabActiveBackground : AppTheme.tabsBackground,
          border: Border(
            right: const BorderSide(color: AppTheme.border, width: 1),
            top: BorderSide(
              color: isActive ? AppTheme.accent : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Icon(
              tab.icon ?? Icons.description_outlined,
              size: 16,
              color: AppTheme.iconFile,
            ),
            const SizedBox(width: 6),
            
            Flexible(
              child: Text(
                tab.fileName,
                style: TextStyle(
                  color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Segoe UI',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            
            if (tab.isModified)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.textSecondary,
                  shape: BoxShape.circle,
                ),
              )
            else
              _buildCloseButton(tab.id, isActive),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(String tabId, bool isActive) {
    return InkWell(
      onTap: () => onTabClosed(tabId),
      borderRadius: BorderRadius.circular(3),
      child: Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        child: Icon(
          Icons.close,
          size: 14,
          color: isActive ? AppTheme.textSecondary : Colors.transparent,
        ),
      ),
    );
  }
}
