import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/time_delta/pal_stats.dart';
import 'package:poketpal/domain/time_delta/time_delta_balancing.dart';
import 'package:poketpal/domain/time_delta/time_delta_engine.dart';

void main() {
  const engine = TimeDeltaEngine();
  final now = DateTime(2026, 1, 10, 12);

  test('decays stats proportional to elapsed time', () {
    final result = engine.resume(
      stats: PalStats.full(),
      lastInteractionAt: now.subtract(const Duration(hours: 5)),
      now: now,
      wasFrozen: false,
    );

    expect(result.isFrozen, isFalse);
    expect(result.reEntryPlan, isNull);
    expect(result.stats.hunger, lessThan(1.0));
    expect(result.stats.hunger,
        closeTo(1.0 - TimeDeltaBalancing.hungerDecayPerHour * 5, 1e-9));
  });

  test('never decays stats below the 20% floor', () {
    final result = engine.resume(
      stats: PalStats.full(),
      lastInteractionAt: now.subtract(const Duration(days: 1)),
      now: now,
      wasFrozen: false,
    );

    expect(result.stats.hunger, greaterThanOrEqualTo(TimeDeltaBalancing.statFloor));
    expect(result.stats.mood, greaterThanOrEqualTo(TimeDeltaBalancing.statFloor));
    expect(result.stats.energy, greaterThanOrEqualTo(TimeDeltaBalancing.statFloor));
  });

  test('enters freeze/maintenance mode after 3 days of absence and offers soft re-entry', () {
    final result = engine.resume(
      stats: PalStats.full(),
      lastInteractionAt: now.subtract(const Duration(days: 3)),
      now: now,
      wasFrozen: false,
    );

    expect(result.isFrozen, isFalse); // Freeze wird beim Resume sofort aufgeloest.
    expect(result.reEntryPlan, isNotNull);
    expect(result.reEntryPlan!.easyTaskCount, greaterThanOrEqualTo(1));
    expect(result.stats.hunger, TimeDeltaBalancing.statFloor);
  });

  test('does not decay further while already frozen, regardless of elapsed time', () {
    final result = engine.resume(
      stats: PalStats.atFloor(),
      lastInteractionAt: now.subtract(const Duration(days: 30)),
      now: now,
      wasFrozen: true,
    );

    expect(result.reEntryPlan, isNotNull);
    expect(result.stats.hunger, TimeDeltaBalancing.statFloor);
  });

  test('does not trigger freeze/soft re-entry just under the threshold', () {
    final result = engine.resume(
      stats: PalStats.full(),
      lastInteractionAt: now.subtract(const Duration(days: 3) - const Duration(minutes: 1)),
      now: now,
      wasFrozen: false,
    );

    expect(result.reEntryPlan, isNull);
  });
}
