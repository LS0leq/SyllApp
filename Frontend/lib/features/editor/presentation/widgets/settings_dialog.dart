import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/settings/settings_providers.dart';
import '../../../../core/utils/responsive_utils.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  int _selectedCategory = 0;

  final List<String> _categories = [
    'Ogólne',
    'Wykrywanie rymów',
    'Edytor',
    'Automatyczny zapis',
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context) || ResponsiveUtils.isMobilePlatform;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    if (isMobile) {
      return _buildMobileDialog(screenWidth, screenHeight);
    }
    return _buildDesktopDialog();
  }
  
  Widget _buildMobileDialog(double screenWidth, double screenHeight) {
    return Dialog(
      backgroundColor: AppTheme.sidebarBackground,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: screenWidth - 32,
        height: screenHeight * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Column(
          children: [
            _buildMobileTitleBar(),
            _buildMobileCategoryTabs(),
            Expanded(child: _buildSettingsContent(isMobile: true)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMobileTitleBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.titleBarBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ustawienia',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 24, color: AppTheme.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMobileCategoryTabs() {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: AppTheme.editorBackground,
        border: Border(
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: _categories.asMap().entries.map((entry) {
            final isSelected = _selectedCategory == entry.key;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = entry.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accent.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected 
                        ? Border.all(color: AppTheme.accent, width: 1)
                        : null,
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildDesktopDialog() {
    return Dialog(
      backgroundColor: AppTheme.sidebarBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Container(
        width: 700,
        height: 500,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Column(
          children: [
            _buildTitleBar(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoriesSidebar(),
                  Container(width: 1, color: AppTheme.border),
                  Expanded(child: _buildSettingsContent(isMobile: false)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppTheme.titleBarBackground,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          const Text(
            'Ustawienia',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontFamily: 'Segoe UI',
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(3),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSidebar() {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: _categories.asMap().entries.map((entry) {
          final isSelected = _selectedCategory == entry.key;
          return InkWell(
            onTap: () => setState(() => _selectedCategory = entry.key),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.selectionBackground : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected ? AppTheme.accent : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Segoe UI',
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsContent({required bool isMobile}) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final padding = isMobile ? 16.0 : 20.0;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedCategory == 0 || _selectedCategory == 2) ...[
            _buildSectionHeader('Edytor', isMobile),
            const SizedBox(height: 12),
            _buildIncrementalSetting(
              title: 'Rozmiar czcionki',
              description: 'Rozmiar tekstu w edytorze',
              value: settings.fontSize.toInt(),
              min: 12,
              max: 32,
              displayValue: '${settings.fontSize.toInt()} px',
              onIncrement: () => notifier.updateFontSize(settings.fontSize + 1),
              onDecrement: () => notifier.updateFontSize(settings.fontSize - 1),
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
          ],
          if (_selectedCategory == 0 || _selectedCategory == 1) ...[
            _buildSectionHeader('Wykrywanie rymów', isMobile),
            const SizedBox(height: 12),
            _buildSliderSetting(
              title: 'Próg podobieństwa rymów',
              description: 'Określa jak podobne muszą być słowa, aby uznać je za rymy',
              value: settings.rhymeThreshold,
              min: 0.4,
              max: 1.0,
              displayValue: '${(settings.rhymeThreshold * 100).toInt()}%',
              onChanged: (value) => notifier.updateRhymeThreshold(value),
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            _buildSwitchSetting(
              title: 'Włącz wykrywanie asonansu',
              description: 'Uwzględniaj rymy oparte na samogłoskach',
              value: settings.enableAssonance,
              onChanged: (value) => notifier.updateEnableAssonance(value),
              isMobile: isMobile,
            ),
          ],
          if (_selectedCategory == 0 || _selectedCategory == 3) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Automatyczny zapis', isMobile),
            const SizedBox(height: 12),
            _buildSwitchSetting(
              title: 'Włącz automatyczny zapis',
              description: 'Automatycznie zapisuj pracę w regularnych odstępach czasu',
              value: settings.autoSave,
              onChanged: (value) => notifier.updateAutoSave(value),
              isMobile: isMobile,
            ),
            const SizedBox(height: 16),
            _buildSliderSetting(
              title: 'Interwał automatycznego zapisu',
              description: 'Czas między automatycznymi zapisami',
              value: settings.autoSaveIntervalMinutes.toDouble(),
              min: 1,
              max: 30,
              displayValue: '${settings.autoSaveIntervalMinutes} min',
              onChanged: settings.autoSave 
                  ? (value) => notifier.updateAutoSaveIntervalMinutes(value.toInt())
                  : null,
              enabled: settings.autoSave,
              isMobile: isMobile,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isMobile) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.accent,
        fontSize: isMobile ? 13 : 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        fontFamily: 'Segoe UI',
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 12),
      decoration: BoxDecoration(
        color: AppTheme.editorBackground,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: isMobile ? 15 : 13,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: isMobile ? 13 : 11,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accent,
            activeTrackColor: AppTheme.accent.withValues(alpha: 0.5),
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.border,
          ),
        ],
      ),
    );
  }

  Widget _buildIncrementalSetting({
    required String title,
    required String description,
    required int value,
    required int min,
    required int max,
    required String displayValue,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    bool enabled = true,
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 12),
      decoration: BoxDecoration(
        color: AppTheme.editorBackground,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: enabled ? AppTheme.textPrimary : AppTheme.textMuted,
                    fontSize: isMobile ? 15 : 13,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: enabled ? AppTheme.textMuted : AppTheme.textMuted.withValues(alpha: 0.5),
                    fontSize: isMobile ? 13 : 11,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              IconButton(
                onPressed: value > min ? onDecrement : null,
                icon: const Icon(Icons.remove),
                iconSize: isMobile ? 20 : 16,
                color: AppTheme.accent,
                disabledColor: AppTheme.textMuted,
                constraints: BoxConstraints(
                  minWidth: isMobile ? 40 : 32,
                  minHeight: isMobile ? 40 : 32,
                ),
                padding: EdgeInsets.zero,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 12, 
                  vertical: isMobile ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.sidebarBackground,
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 3),
                  border: Border.all(color: AppTheme.border, width: 1),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: enabled ? AppTheme.accent : AppTheme.textMuted,
                    fontSize: isMobile ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Consolas',
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? onIncrement : null,
                icon: const Icon(Icons.add),
                iconSize: isMobile ? 20 : 16,
                color: AppTheme.accent,
                disabledColor: AppTheme.textMuted,
                constraints: BoxConstraints(
                  minWidth: isMobile ? 40 : 32,
                  minHeight: isMobile ? 40 : 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required String description,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    Function(double)? onChanged,
    bool enabled = true,
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 12),
      decoration: BoxDecoration(
        color: AppTheme.editorBackground,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: enabled ? AppTheme.textPrimary : AppTheme.textMuted,
                        fontSize: isMobile ? 15 : 13,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: enabled ? AppTheme.textMuted : AppTheme.textMuted.withValues(alpha: 0.5),
                        fontSize: isMobile ? 13 : 11,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 8, 
                  vertical: isMobile ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.sidebarBackground,
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 3),
                  border: Border.all(color: AppTheme.border, width: 1),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: enabled ? AppTheme.accent : AppTheme.textMuted,
                    fontSize: isMobile ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Consolas',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: enabled ? AppTheme.accent : AppTheme.textMuted,
              inactiveTrackColor: AppTheme.border,
              thumbColor: enabled ? AppTheme.accent : AppTheme.textMuted,
              overlayColor: AppTheme.accent.withValues(alpha: 0.2),
              trackHeight: isMobile ? 6 : 4,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: isMobile ? 10 : 6),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
