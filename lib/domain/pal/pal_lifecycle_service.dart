import '../task_engine/task_response.dart';
import '../time_delta/pal_stats.dart';
import '../time_delta/soft_reentry.dart';
import '../time_delta/time_delta_engine.dart';
import 'feeding_balancing.dart';
import 'pal_state.dart';

class PalResumeResult {
  final PalState pal;
  final SoftReEntryPlan? reEntryPlan;

  const PalResumeResult({required this.pal, this.reEntryPlan});
}

// Orchestriert Time-Delta Engine und Task-Ergebnisse gegen den Pal-Zustand.
// Kennt weder Persistenz noch UI -- Aufrufer sind fuer das Laden/Speichern
// des zurueckgegebenen PalState verantwortlich.
class PalLifecycleService {
  final TimeDeltaEngine _timeDeltaEngine;

  // this._timeDeltaEngine waere ein privater benannter Parameter und liesse
  // sich dann nur innerhalb dieser Datei ueberschreiben (Dart-Privacy gilt
  // auch fuer Parameternamen) -- Aufrufer sitzen aber in anderen Dateien.
  const PalLifecycleService({
    TimeDeltaEngine timeDeltaEngine = const TimeDeltaEngine(),
    // ignore: prefer_initializing_formals
  }) : _timeDeltaEngine = timeDeltaEngine;

  // Beim App-Oeffnen aufzurufen, bevor der Pal-Zustand angezeigt wird.
  PalResumeResult resume(PalState pal, DateTime now) {
    final result = _timeDeltaEngine.resume(
      stats: pal.stats,
      lastInteractionAt: pal.lastInteractionAt,
      now: now,
      wasFrozen: pal.isFrozen,
    );

    final updated = PalState(
      id: pal.id,
      name: pal.name,
      createdAt: pal.createdAt,
      lastInteractionAt: now,
      stats: result.stats,
      isActive: pal.isActive,
      archivedAt: pal.archivedAt,
      isFrozen: result.isFrozen,
      frozenSince: result.isFrozen ? (pal.frozenSince ?? now) : null,
      locationState: pal.locationState,
      currentBiomeId: pal.currentBiomeId,
    );

    return PalResumeResult(pal: updated, reEntryPlan: result.reEntryPlan);
  }

  // Werte werden NICHT durch Antippen aufgefuellt (resolved), sondern durch
  // eine richtig geloeste Aufgabe.
  PalState applyTaskResult(PalState pal, TaskResponse response, DateTime now) {
    if (!response.wasCorrect) {
      return pal.copyWith(lastInteractionAt: now);
    }
    return pal.copyWith(
      stats: pal.stats.boosted(FeedingBalancing.statBoostPerCorrectAnswer),
      lastInteractionAt: now,
    );
  }

  // Sammlungsmodell (resolved): archivieren statt loeschen/ersetzen.
  PalState archive(PalState pal, DateTime now) {
    return pal.copyWith(isActive: false, archivedAt: now);
  }

  // Bei anhaltendem negativem Skill Gap: neuer Pal auf Startniveau, statt
  // Downgrade des aktuellen Pals.
  PalState createNew({required int id, required String name, required DateTime now}) {
    return PalState(
      id: id,
      name: name,
      createdAt: now,
      lastInteractionAt: now,
      stats: PalStats.full(),
      isActive: true,
      isFrozen: false,
      locationState: PalLocationState.home,
    );
  }
}
