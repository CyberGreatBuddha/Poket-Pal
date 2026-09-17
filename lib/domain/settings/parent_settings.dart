// Vom Elternmenue konfigurierte Einstellungen. Getrennt von ScreenTimeState
// (siehe domain/tiredness), da sich diese Werte selten aendern, waehrend der
// Bildschirmzeit-Zaehler staendig aktualisiert wird.
class ParentSettings {
  final int tirednessThresholdMinutes;
  final bool isTirednessLimitEnabled;

  const ParentSettings({
    required this.tirednessThresholdMinutes,
    required this.isTirednessLimitEnabled,
  });

  factory ParentSettings.defaults() => const ParentSettings(
        tirednessThresholdMinutes: 25,
        isTirednessLimitEnabled: true,
      );

  ParentSettings copyWith({
    int? tirednessThresholdMinutes,
    bool? isTirednessLimitEnabled,
  }) {
    return ParentSettings(
      tirednessThresholdMinutes: tirednessThresholdMinutes ?? this.tirednessThresholdMinutes,
      isTirednessLimitEnabled: isTirednessLimitEnabled ?? this.isTirednessLimitEnabled,
    );
  }
}
