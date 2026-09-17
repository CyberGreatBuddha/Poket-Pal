import 'screen_time_state.dart';

// Reine Funktion wie TimeDeltaEngine: verwaltet ausschliesslich den
// Bildschirmzeit-Zaehler und den taeglichen Reset. Kennt weder PalStats noch
// die Time-Delta Engine -- komplett unabhaengige Zaehlung.
class TirednessTracker {
  const TirednessTracker();

  // Wird aufgerufen, wenn ein aktives Zeitintervall (Resume -> Pause) endet.
  // additionalActiveSeconds ist die per Zeitstempel-Differenz gemessene Dauer
  // dieses Intervalls (siehe ScreenTimeController).
  ScreenTimeState recordActiveInterval({
    required ScreenTimeState current,
    required int additionalActiveSeconds,
    required DateTime now,
  }) {
    final resetState = _applyDailyResetIfNeeded(current, now);
    return ScreenTimeState(
      activeScreenTimeSeconds: resetState.activeScreenTimeSeconds + additionalActiveSeconds,
      lastResetDate: resetState.lastResetDate,
    );
  }

  // Beim App-Start/Resume aufzurufen, um einen faelligen Tagesreset auch dann
  // zu erkennen, wenn gerade kein aktives Intervall endet (z. B. App wird an
  // einem neuen Kalendertag zum ersten Mal geoeffnet).
  ScreenTimeState applyDailyResetIfNeeded(ScreenTimeState current, DateTime now) {
    return _applyDailyResetIfNeeded(current, now);
  }

  ScreenTimeState _applyDailyResetIfNeeded(ScreenTimeState current, DateTime now) {
    final isNewCalendarDay = current.lastResetDate.year != now.year ||
        current.lastResetDate.month != now.month ||
        current.lastResetDate.day != now.day;

    if (!isNewCalendarDay) return current;

    return ScreenTimeState.initial(now);
  }
}
