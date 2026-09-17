// Persistierter Zaehler fuer aktive Bildschirmzeit -- komplett unabhaengig
// von PalStats/TimeDeltaEngine (siehe Muedigkeits-Mechanik-Erweiterung).
class ScreenTimeState {
  final int activeScreenTimeSeconds;
  final DateTime lastResetDate;

  const ScreenTimeState({
    required this.activeScreenTimeSeconds,
    required this.lastResetDate,
  });

  factory ScreenTimeState.initial(DateTime now) => ScreenTimeState(
        activeScreenTimeSeconds: 0,
        lastResetDate: now,
      );
}
