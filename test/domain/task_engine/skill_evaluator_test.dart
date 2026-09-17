import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/task_engine/response_tracker.dart';
import 'package:poketpal/domain/task_engine/skill_evaluator.dart';

void main() {
  const evaluator = SkillEvaluator();

  test('holds level when there is not yet enough data (null signal)', () {
    expect(evaluator.evaluate(null), SkillDecisionKind.holdLevel);
  });

  test('signals level up when correctness is high', () {
    const signal = SkillSignal(
      averageCorrectness: 0.9,
      averageResponseTimeMs: 2000,
      sampleSize: 10,
    );

    expect(evaluator.evaluate(signal), SkillDecisionKind.levelUp);
  });

  test('signals offering a new pal instead of downgrading on persistent low performance', () {
    const signal = SkillSignal(
      averageCorrectness: 0.2,
      averageResponseTimeMs: 5000,
      sampleSize: 10,
    );

    // Wichtig: es gibt keinen "levelDown"-Fall -- DifficultyModel ist monoton.
    expect(evaluator.evaluate(signal), SkillDecisionKind.offerNewPal);
  });

  test('holds level for middling performance', () {
    const signal = SkillSignal(
      averageCorrectness: 0.6,
      averageResponseTimeMs: 3000,
      sampleSize: 10,
    );

    expect(evaluator.evaluate(signal), SkillDecisionKind.holdLevel);
  });
}
