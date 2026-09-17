import 'dart:math';

import 'content/animal_vocabulary.dart';
import 'task.dart';
import 'task_generator.dart';

// Fachbereich Sprache, Vokabular-Einstieg (Vorschulalter): Audio nennt ein
// Tier, das Kind tippt auf das passende Bild unter mehreren Optionen.
// categoryKey: language.vocabulary_animals.
class AnimalVocabularyTaskGenerator implements TaskGenerator {
  static const int _minOptions = 2;
  static const int _maxOptions = 4;

  final Random _random;

  AnimalVocabularyTaskGenerator({Random? random}) : _random = random ?? Random();

  @override
  Task generate({required String categoryKey, required int level}) {
    final optionCount = min(_maxOptions, _minOptions + level - 1);

    final shuffled = List.of(animalVocabulary)..shuffle(_random);
    final chosen = shuffled.take(optionCount).toList();
    final target = chosen[_random.nextInt(chosen.length)];

    return Task(
      categoryKey: categoryKey,
      difficulty: level,
      prompt: TaskPrompt(
        imageAssetPath: 'assets/images/vocabulary/prompt_ear.png',
        audioAssetPath: 'assets/audio/vocabulary/animals/${target.key}.mp3',
        text: target.germanName,
      ),
      options: chosen
          .map((animal) => TaskOption(
                value: animal.key,
                imageAssetPath: 'assets/images/vocabulary/animals/${animal.key}.png',
              ))
          .toList(),
      correctValue: target.key,
    );
  }
}
