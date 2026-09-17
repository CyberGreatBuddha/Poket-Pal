import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/task_engine/difficulty_balancing.dart';
import 'package:poketpal/domain/task_engine/response_tracker.dart';
import 'package:poketpal/domain/task_engine/task_response.dart';

List<TaskResponse> _responses(List<bool> correctness, {int responseTimeMs = 2000}) {
  final start = DateTime(2026, 1, 1);
  return [
    for (var i = 0; i < correctness.length; i++)
      TaskResponse(
        categoryKey: 'math.pictogram',
        difficultyAtTime: 1,
        wasCorrect: correctness[i],
        responseTimeMs: responseTimeMs,
        completedAt: start.add(Duration(minutes: i)),
      ),
  ];
}

void main() {
  const tracker = ResponseTracker();

  test('windowSizeForLevel matches the documented example table', () {
    expect(DifficultyBalancing.windowSizeForLevel(1), 10);
    expect(DifficultyBalancing.windowSizeForLevel(2), 12);
    expect(DifficultyBalancing.windowSizeForLevel(3), 13);
    expect(DifficultyBalancing.windowSizeForLevel(4), 15);
    expect(DifficultyBalancing.windowSizeForLevel(5), 16);
  });

  test('returns null when fewer responses than the window size exist', () {
    final signal = tracker.evaluate(
      categoryHistory: _responses(List.filled(9, true)),
      currentLevel: 1, // windowSize = 10
    );

    expect(signal, isNull);
  });

  test('evaluates only the most recent window, matching level-scaled window size', () {
    // 5 falsche, danach 10 richtige -> bei windowSize 10 (Level 1) zaehlen nur die 10 richtigen.
    final history = [..._responses(List.filled(5, false)), ..._responses(List.filled(10, true))];

    final signal = tracker.evaluate(categoryHistory: history, currentLevel: 1);

    expect(signal, isNotNull);
    expect(signal!.sampleSize, 10);
    expect(signal.averageCorrectness, 1.0);
  });

  test('computes average correctness and response time within the window', () {
    final history = _responses([true, true, false, true, true, true, false, true, true, true],
        responseTimeMs: 3000);

    final signal = tracker.evaluate(categoryHistory: history, currentLevel: 1);

    expect(signal, isNotNull);
    expect(signal!.averageCorrectness, closeTo(0.8, 1e-9));
    expect(signal.averageResponseTimeMs, 3000);
  });
}
