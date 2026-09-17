import 'dart:math';

import 'content/color_palette.dart';
import 'task.dart';
import 'task_generator.dart';

// Vorschulalter-Fachbereich "Farben": Audio nennt eine Farbe, das Kind tippt
// auf den passenden Farbklecks unter mehreren Optionen. Kein Lesen noetig.
// categoryKey: colors.recognition.
class ColorRecognitionTaskGenerator implements TaskGenerator {
  static const int _minOptions = 2;
  static const int _maxOptions = 4;

  final Random _random;

  ColorRecognitionTaskGenerator({Random? random}) : _random = random ?? Random();

  @override
  Task generate({required String categoryKey, required int level}) {
    final optionCount = min(_maxOptions, _minOptions + level - 1);

    final shuffled = List.of(basicColorPalette)..shuffle(_random);
    final chosen = shuffled.take(optionCount).toList();
    final target = chosen[_random.nextInt(chosen.length)];

    return Task(
      categoryKey: categoryKey,
      difficulty: level,
      prompt: TaskPrompt(
        imageAssetPath: 'assets/images/colors/prompt_swatch.png',
        audioAssetPath: 'assets/audio/colors/${target.key}.mp3',
        text: 'Tippe auf ${target.germanName}',
      ),
      options: chosen
          .map((color) => TaskOption(
                value: color.key,
                imageAssetPath: 'assets/images/colors/swatch_${color.key}.png',
              ))
          .toList(),
      correctValue: target.key,
    );
  }
}
