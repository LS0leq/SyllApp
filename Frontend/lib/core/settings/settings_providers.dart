import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_notifier.dart';
import 'settings_state.dart';


final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
