
class SettingsState {
  final double rhymeThreshold;
  final bool enableAssonance;
  final bool autoSave;
  final int autoSaveIntervalMinutes;
  final double fontSize;

  const SettingsState({
    this.rhymeThreshold = 0.6,
    this.enableAssonance = true,
    this.autoSave = true,
    this.autoSaveIntervalMinutes = 1,
    this.fontSize = 16.0,
  });

  SettingsState copyWith({
    double? rhymeThreshold,
    bool? enableAssonance,
    bool? autoSave,
    int? autoSaveIntervalMinutes,
    double? fontSize,
  }) {
    return SettingsState(
      rhymeThreshold: rhymeThreshold ?? this.rhymeThreshold,
      enableAssonance: enableAssonance ?? this.enableAssonance,
      autoSave: autoSave ?? this.autoSave,
      autoSaveIntervalMinutes:
          autoSaveIntervalMinutes ?? this.autoSaveIntervalMinutes,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() => {
        'rhymeThreshold': rhymeThreshold,
        'enableAssonance': enableAssonance,
        'autoSave': autoSave,
        'autoSaveIntervalMinutes': autoSaveIntervalMinutes,
        'fontSize': fontSize,
      };

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      rhymeThreshold: (json['rhymeThreshold'] as num?)?.toDouble() ?? 0.6,
      enableAssonance: json['enableAssonance'] as bool? ?? true,
      autoSave: json['autoSave'] as bool? ?? true,
      autoSaveIntervalMinutes: json['autoSaveIntervalMinutes'] as int? ?? 1,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
    );
  }
}
