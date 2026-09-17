import 'dart:math';

import 'content/categorized_items.dart';
import 'task.dart';
import 'task_generator.dart';

// Generische "Tippe das passende Item zur genannten Kategorie"-Mechanik:
// Audio/Text fragt nach einer Kategorie (z. B. "Welches ist Obst?"), das Kind
// tippt auf das passende Bild unter Distraktoren aus anderen Kategorien.
// Rein visuell, kein Lesen noetig. Wird von mehreren inhaltlich unabhaengigen
// Fachbereichen wiederverwendet -- siehe DefaultTaskGeneratorRegistry
// (Allgemeinwissen, Biologie, Physik nutzen dieselbe Klasse mit je eigenen
// Kategorien/Items und Asset-Namensraum).
class CategorizationTaskGenerator implements TaskGenerator {
  static const int _minOptions = 2;
  static const int _maxOptions = 4;

  final List<CategoryDefinition> categories;
  final List<CategorizedItem> items;

  // Namensraum fuer Asset-Pfade, z. B. 'general_knowledge', 'biology',
  // 'physics' -- haelt die Assets der Fachbereiche getrennt.
  final String assetNamespace;

  final Random _random;

  CategorizationTaskGenerator({
    required this.categories,
    required this.items,
    required this.assetNamespace,
    Random? random,
  }) : _random = random ?? Random();

  @override
  Task generate({required String categoryKey, required int level}) {
    final optionCount = min(_maxOptions, _minOptions + level - 1);

    final category = categories[_random.nextInt(categories.length)];
    final members = items.where((item) => item.categoryKey == category.key).toList()
      ..shuffle(_random);
    final target = members.first;

    final distractors = items.where((item) => item.categoryKey != category.key).toList()
      ..shuffle(_random);

    final options = [target, ...distractors.take(optionCount - 1)]..shuffle(_random);

    return Task(
      categoryKey: categoryKey,
      difficulty: level,
      prompt: TaskPrompt(
        imageAssetPath: 'assets/images/$assetNamespace/prompt_question.png',
        audioAssetPath: 'assets/audio/$assetNamespace/question_${category.key}.mp3',
        text: category.questionPrompt,
      ),
      options: options
          .map((item) => TaskOption(
                value: item.key,
                imageAssetPath: 'assets/images/$assetNamespace/items/${item.key}.png',
              ))
          .toList(),
      correctValue: target.key,
    );
  }
}
