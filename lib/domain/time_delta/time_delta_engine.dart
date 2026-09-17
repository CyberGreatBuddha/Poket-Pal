import 'pal_stats.dart';
import 'soft_reentry.dart';
import 'time_delta_balancing.dart';

// Ergebnis eines Time-Delta-Durchlaufs beim App-Oeffnen.
class TimeDeltaResumeResult {
  final PalStats stats;
  final bool isFrozen;
  final SoftReEntryPlan? reEntryPlan;

  const TimeDeltaResumeResult({
    required this.stats,
    required this.isFrozen,
    this.reEntryPlan,
  });
}

// Kernsystem 1: berechnet den Stat-Verfall rein ueber die verstrichene Zeit
// seit der letzten Interaktion (kein Server-seitiges Ticken). Reine Funktion,
// unabhaengig von Persistenz und UI.
class TimeDeltaEngine {
  const TimeDeltaEngine();

  TimeDeltaResumeResult resume({
    required PalStats stats,
    required DateTime lastInteractionAt,
    required DateTime now,
    required bool wasFrozen,
  }) {
    final elapsed = now.difference(lastInteractionAt);
    final crossedFreezeThreshold = elapsed >= TimeDeltaBalancing.freezeThreshold;

    if (wasFrozen || crossedFreezeThreshold) {
      // Freeze/Maintenance-Modus: kein weiterer Verfall, kein Fortschritt,
      // stattdessen sanfter Wiedereinstieg beim naechsten Oeffnen.
      return TimeDeltaResumeResult(
        stats: PalStats.atFloor(),
        isFrozen: false,
        reEntryPlan: SoftReEntryPlan.standard(),
      );
    }

    return TimeDeltaResumeResult(
      stats: _applyDecay(stats, elapsed),
      isFrozen: false,
    );
  }

  PalStats _applyDecay(PalStats stats, Duration elapsed) {
    final hours = elapsed.inMilliseconds / (1000 * 60 * 60);
    double decay(double value, double ratePerHour) =>
        (value - ratePerHour * hours).clamp(TimeDeltaBalancing.statFloor, 1.0);

    return PalStats(
      hunger: decay(stats.hunger, TimeDeltaBalancing.hungerDecayPerHour),
      mood: decay(stats.mood, TimeDeltaBalancing.moodDecayPerHour),
      energy: decay(stats.energy, TimeDeltaBalancing.energyDecayPerHour),
    );
  }
}
