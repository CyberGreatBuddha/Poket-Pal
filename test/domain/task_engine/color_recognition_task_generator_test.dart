import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/task_engine/color_recognition_task_generator.dart';
import 'package:poketpal/domain/task_engine/content/color_palette.dart';

void main() {
  final generator = ColorRecognitionTaskGenerator(random: Random(11));

  test('option count grows with level, capped at 4, and includes the correct answer', () {
    final expectedCounts = {1: 2, 2: 3, 3: 4, 4: 4, 10: 4};

    for (final entry in expectedCounts.entries) {
      final task = generator.generate(categoryKey: 'colors.recognition', level: entry.key);

      expect(task.options.length, entry.value);
      expect(task.options.map((o) => o.value), contains(task.correctValue));
    }
  });

  test('all option values are valid, distinct color keys', () {
    final task = generator.generate(categoryKey: 'colors.recognition', level: 3);

    final validKeys = basicColorPalette.map((c) => c.key).toSet();
    final optionValues = task.options.map((o) => o.value).toList();

    expect(optionValues.toSet().length, optionValues.length);
    for (final value in optionValues) {
      expect(validKeys, contains(value));
    }
  });

  test('audio prompt is always present (Bild+Audio-Format)', () {
    final task = generator.generate(categoryKey: 'colors.recognition', level: 1);
    expect(task.prompt.audioAssetPath, isNotEmpty);
  });
}
