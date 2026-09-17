import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/tiredness/screen_time_state.dart';
import 'package:poketpal/domain/tiredness/tiredness_tracker.dart';

void main() {
  const tracker = TirednessTracker();
  final today = DateTime(2026, 1, 10, 9);

  test('recordActiveInterval accumulates seconds within the same calendar day', () {
    final start = ScreenTimeState(activeScreenTimeSeconds: 100, lastResetDate: today);

    final result = tracker.recordActiveInterval(
      current: start,
      additionalActiveSeconds: 50,
      now: today.add(const Duration(minutes: 5)),
    );

    expect(result.activeScreenTimeSeconds, 150);
    expect(result.lastResetDate.day, today.day);
  });

  test('resets the counter to zero when a new calendar day begins', () {
    final start = ScreenTimeState(activeScreenTimeSeconds: 900, lastResetDate: today);
    final nextDay = DateTime(2026, 1, 11, 8);

    final result = tracker.recordActiveInterval(
      current: start,
      additionalActiveSeconds: 30,
      now: nextDay,
    );

    // Reset zuerst, dann wird das aktuelle Intervall neu aufaddiert.
    expect(result.activeScreenTimeSeconds, 30);
    expect(result.lastResetDate.day, 11);
  });

  test('applyDailyResetIfNeeded resets even without a completed active interval', () {
    final start = ScreenTimeState(activeScreenTimeSeconds: 500, lastResetDate: today);
    final nextDay = DateTime(2026, 1, 11, 7);

    final result = tracker.applyDailyResetIfNeeded(start, nextDay);

    expect(result.activeScreenTimeSeconds, 0);
  });

  test('applyDailyResetIfNeeded does nothing on the same calendar day', () {
    final start = ScreenTimeState(activeScreenTimeSeconds: 500, lastResetDate: today);
    final laterSameDay = today.add(const Duration(hours: 3));

    final result = tracker.applyDailyResetIfNeeded(start, laterSameDay);

    expect(result.activeScreenTimeSeconds, 500);
    expect(result.lastResetDate, today);
  });
}
