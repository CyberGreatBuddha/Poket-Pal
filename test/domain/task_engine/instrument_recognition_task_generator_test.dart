import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/task_engine/content/musical_instruments.dart';
import 'package:poketpal/domain/task_engine/instrument_recognition_task_generator.dart';

void main() {
  final generator = InstrumentRecognitionTaskGenerator(random: Random(17));

  test('option count grows with level, capped at 4, and includes the correct answer', () {
    final expectedCounts = {1: 2, 2: 3, 3: 4, 6: 4};

    for (final entry in expectedCounts.entries) {
      final task = generator.generate(categoryKey: 'music.instrument_recognition', level: entry.key);

      expect(task.options.length, entry.value);
      expect(task.options.map((o) => o.value), contains(task.correctValue));
    }
  });

  test('all option values are valid, distinct instrument keys', () {
    final task = generator.generate(categoryKey: 'music.instrument_recognition', level: 3);

    final validKeys = musicalInstruments.map((i) => i.key).toSet();
    final optionValues = task.options.map((o) => o.value).toList();

    expect(optionValues.toSet().length, optionValues.length);
    for (final value in optionValues) {
      expect(validKeys, contains(value));
    }
  });

  test('the audio field carries the sound to identify, not just narration (no format extension needed)', () {
    final task = generator.generate(categoryKey: 'music.instrument_recognition', level: 1);
    expect(task.prompt.audioAssetPath, contains(task.correctValue));
  });
}
