import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/task_engine/animal_vocabulary_task_generator.dart';
import 'package:poketpal/domain/task_engine/content/animal_vocabulary.dart';

void main() {
  final generator = AnimalVocabularyTaskGenerator(random: Random(21));

  test('option count grows with level, capped at 4, and includes the correct answer', () {
    final expectedCounts = {1: 2, 2: 3, 3: 4, 5: 4};

    for (final entry in expectedCounts.entries) {
      final task = generator.generate(categoryKey: 'language.vocabulary_animals', level: entry.key);

      expect(task.options.length, entry.value);
      expect(task.options.map((o) => o.value), contains(task.correctValue));
    }
  });

  test('all option values are valid, distinct animal keys', () {
    final task = generator.generate(categoryKey: 'language.vocabulary_animals', level: 3);

    final validKeys = animalVocabulary.map((a) => a.key).toSet();
    final optionValues = task.options.map((o) => o.value).toList();

    expect(optionValues.toSet().length, optionValues.length);
    for (final value in optionValues) {
      expect(validKeys, contains(value));
    }
  });

  test('text prompt carries the spoken word for adults reading along (optional, non-mandatory)', () {
    final task = generator.generate(categoryKey: 'language.vocabulary_animals', level: 1);
    expect(task.prompt.text, isNotNull);
    expect(task.prompt.audioAssetPath, isNotEmpty);
  });
}
