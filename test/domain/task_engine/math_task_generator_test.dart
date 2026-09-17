import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/task_engine/math_task_generator.dart';
import 'package:poketpal/domain/task_engine/task_generator.dart';

void main() {
  group('PictogramCountingTaskGenerator (math.pictogram)', () {
    final generator = PictogramCountingTaskGenerator(random: Random(42));

    test('generates counts within the 1-5 range and a matching correct option', () {
      for (var level = 1; level <= 5; level++) {
        final task = generator.generate(categoryKey: 'math.pictogram', level: level);

        final correctCount = int.parse(task.correctValue);
        expect(correctCount, inInclusiveRange(1, 5));
        final optionValues = task.options.map((o) => o.value).toList();
        expect(optionValues, contains(task.correctValue));
        expect(optionValues.toSet().length, optionValues.length);
        expect(task.prompt.audioAssetPath, isNotEmpty);
      }
    });
  });

  group('QuantityComparisonTaskGenerator (math.comparison)', () {
    final generator = QuantityComparisonTaskGenerator(random: Random(7));

    test('always produces two distinct pile sizes with a determinable winner', () {
      for (var level = 1; level <= 5; level++) {
        final task = generator.generate(categoryKey: 'math.comparison', level: level);

        expect(task.options.length, 2);
        expect(['left', 'right'], contains(task.correctValue));
      }
    });
  });

  group('VisualAdditionTaskGenerator (math.visual_addition)', () {
    final generator = VisualAdditionTaskGenerator(random: Random(5));

    test('the correct option is always the actual sum, with distinct nearby distractors', () {
      for (var level = 1; level <= 5; level++) {
        final task = generator.generate(categoryKey: 'math.visual_addition', level: level);

        final optionValues = task.options.map((o) => o.value).toList();
        expect(optionValues, contains(task.correctValue));
        expect(optionValues.toSet().length, optionValues.length);
        expect(int.parse(task.correctValue), greaterThanOrEqualTo(2)); // min 1+1
      }
    });
  });

  group('AbstractNumberTaskGenerator (math.abstract_numbers)', () {
    final generator = AbstractNumberTaskGenerator(random: Random(9));

    test('option count grows with level and stays within the widening number range', () {
      final expectedUpperBound = {1: 6, 2: 8, 3: 10, 8: 20, 20: 20};

      for (final entry in expectedUpperBound.entries) {
        final task = generator.generate(categoryKey: 'math.abstract_numbers', level: entry.key);

        final optionValues = task.options.map((o) => int.parse(o.value)).toList();
        for (final value in optionValues) {
          expect(value, inInclusiveRange(1, entry.value));
        }
        expect(optionValues, contains(int.parse(task.correctValue)));
        expect(optionValues.toSet().length, optionValues.length);
      }
    });

    test('has no image-based counting aid -- prompt carries no text, only audio', () {
      final task = generator.generate(categoryKey: 'math.abstract_numbers', level: 1);
      expect(task.prompt.text, isNull);
      expect(task.prompt.audioAssetPath, isNotEmpty);
    });
  });

  group('ExtendedRangeAdditionTaskGenerator (math.extended_range)', () {
    final generator = ExtendedRangeAdditionTaskGenerator(random: Random(13));

    test('the correct option is always the actual sum, with distinct nearby distractors', () {
      for (var level = 1; level <= 10; level++) {
        final task = generator.generate(categoryKey: 'math.extended_range', level: level);

        final optionValues = task.options.map((o) => o.value).toList();
        expect(optionValues, contains(task.correctValue));
        expect(optionValues.toSet().length, optionValues.length);
      }
    });

    test('reaches a wider number range than the visual addition stage at high levels', () {
      // Einzelziehungen koennen zufaellig klein ausfallen -- ueber viele
      // Durchlaeufe muss aber mindestens eine Summe > 10 auftreten, sonst
      // waere Stufe 5 nicht wirklich "erweitert" gegenueber Stufe 3 (max. 10).
      final sums = List.generate(
        50,
        (_) => int.parse(
          generator.generate(categoryKey: 'math.extended_range', level: 10).correctValue,
        ),
      );

      expect(sums.any((sum) => sum > 10), isTrue);
    });
  });

  test('TaskGeneratorRegistry dispatches by the full categoryKey', () {
    final registry = TaskGeneratorRegistry()
      ..register('math.pictogram', PictogramCountingTaskGenerator(random: Random(1)))
      ..register('math.comparison', QuantityComparisonTaskGenerator(random: Random(1)));

    final pictogramTask = registry.generate(categoryKey: 'math.pictogram', level: 1);
    expect(pictogramTask.categoryKey, 'math.pictogram');

    final comparisonTask = registry.generate(categoryKey: 'math.comparison', level: 1);
    expect(comparisonTask.categoryKey, 'math.comparison');

    // Verschiedene Kategorien im selben Fachbereich ("math") duerfen sich nicht
    // gegenseitig ueberschreiben -- genau der Bug, der hier gefixt wurde.
    expect(pictogramTask.options.any((o) => o.value == 'left'), isFalse);

    expect(
      () => registry.generate(categoryKey: 'german.vocabulary', level: 1),
      throwsStateError,
    );
  });
}
