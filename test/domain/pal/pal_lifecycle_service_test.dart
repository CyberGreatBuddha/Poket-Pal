import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/pal/pal_lifecycle_service.dart';
import 'package:poketpal/domain/pal/pal_state.dart';
import 'package:poketpal/domain/task_engine/task_response.dart';
import 'package:poketpal/domain/time_delta/pal_stats.dart';
import 'package:poketpal/domain/time_delta/time_delta_balancing.dart';

PalState _pal({required DateTime lastInteractionAt, PalStats? stats}) {
  return PalState(
    id: 1,
    name: 'Test-Pal',
    createdAt: lastInteractionAt,
    lastInteractionAt: lastInteractionAt,
    stats: stats ?? PalStats.full(),
    isActive: true,
    isFrozen: false,
    locationState: PalLocationState.home,
  );
}

void main() {
  const service = PalLifecycleService();
  final now = DateTime(2026, 1, 10, 12);

  test('resume applies time-delta decay and advances lastInteractionAt', () {
    final pal = _pal(lastInteractionAt: now.subtract(const Duration(hours: 2)));

    final result = service.resume(pal, now);

    expect(result.pal.lastInteractionAt, now);
    expect(result.pal.stats.hunger, lessThan(1.0));
    expect(result.reEntryPlan, isNull);
  });

  test('resume offers soft re-entry after 3+ days and pal is no longer marked frozen', () {
    final pal = _pal(lastInteractionAt: now.subtract(const Duration(days: 5)));

    final result = service.resume(pal, now);

    expect(result.reEntryPlan, isNotNull);
    expect(result.pal.isFrozen, isFalse);
    expect(result.pal.stats.hunger, TimeDeltaBalancing.statFloor);
  });

  test('applyTaskResult only boosts stats for a correct answer, never punishes a wrong one', () {
    final pal = _pal(lastInteractionAt: now, stats: PalStats.atFloor());

    final wrongResponse = TaskResponse(
      categoryKey: 'math.pictogram',
      difficultyAtTime: 1,
      wasCorrect: false,
      responseTimeMs: 1500,
      completedAt: now,
    );
    final afterWrong = service.applyTaskResult(pal, wrongResponse, now);
    expect(afterWrong.stats.hunger, TimeDeltaBalancing.statFloor);

    final correctResponse = TaskResponse(
      categoryKey: 'math.pictogram',
      difficultyAtTime: 1,
      wasCorrect: true,
      responseTimeMs: 1500,
      completedAt: now,
    );
    final afterCorrect = service.applyTaskResult(pal, correctResponse, now);
    expect(afterCorrect.stats.hunger, greaterThan(TimeDeltaBalancing.statFloor));
  });

  test('archive keeps the pal as part of the collection instead of deleting it', () {
    final pal = _pal(lastInteractionAt: now);

    final archived = service.archive(pal, now);

    expect(archived.isActive, isFalse);
    expect(archived.archivedAt, now);
    expect(archived.id, pal.id); // gleiche Instanz bleibt in der Sammlung erhalten
  });

  test('createNew starts a fresh pal at full stats for the "raise a new pal" flow', () {
    final freshPal = service.createNew(id: 2, name: 'Zweiter Pal', now: now);

    expect(freshPal.stats.hunger, 1.0);
    expect(freshPal.isActive, isTrue);
    expect(freshPal.isFrozen, isFalse);
  });
}
