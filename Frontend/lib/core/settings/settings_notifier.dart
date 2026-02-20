import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';



class SettingsNotifier extends Notifier<SettingsState> {
  static const String _settingsKey = 'app_settings';

  @override
  SettingsState build() {
    return const SettingsState();
  }

  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);

    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = SettingsState.fromJson(json);
      } catch (_) {
        state = const SettingsState();
      }
    }
  }

  

  void updateRhymeThreshold(double value) {
    state = state.copyWith(rhymeThreshold: value);
    _persist();
  }

  void updateEnableAssonance(bool value) {
    state = state.copyWith(enableAssonance: value);
    _persist();
  }

  void updateAutoSave(bool value) {
    state = state.copyWith(autoSave: value);
    _persist();
  }

  void updateAutoSaveIntervalMinutes(int value) {
    state = state.copyWith(autoSaveIntervalMinutes: value);
    _persist();
  }

  void updateFontSize(double value) {
    state = state.copyWith(fontSize: value.clamp(12.0, 32.0));
    _persist();
  }

  

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_settingsKey, jsonString);
  }
}
