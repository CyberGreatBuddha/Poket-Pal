import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/task_engine/categorization_task_generator.dart';
import 'package:poketpal/domain/task_engine/content/animal_habitats.dart';
import 'package:poketpal/domain/task_engine/content/knowledge_categories.dart';

void main() {
  final generator = CategorizationTaskGenerator(
    categories: knowledgeCategories,
    items: knowledgeItems,
    assetNamespace: 'general_knowledge',
    random: Random(31),
  );

  test('option count grows with level, capped at 4, and includes exactly one correct member', () {
    final expectedCounts = {1: 2, 2: 3, 3: 4, 5: 4};

    for (final entry in expectedCounts.entries) {
      final task =
          generator.generate(categoryKey: 'general_knowledge.categorization', level: entry.key);

      expect(task.options.length, entry.value);
      expect(task.options.map((o) => o.value), contains(task.correctValue));
    }
  });

  test('the correct answer always belongs to the asked-about category', () {
    for (var i = 0; i < 20; i++) {
      final task =
          generator.generate(categoryKey: 'general_knowledge.categorization', level: 3);

      final correctItem = knowledgeItems.singleWhere((item) => item.key == task.correctValue);
      final askedCategory =
          knowledgeCategories.singleWhere((c) => c.questionPrompt == task.prompt.text);

      expect(correctItem.categoryKey, askedCategory.key);
    }
  });

  test('distractor options never belong to the asked-about category', () {
    final task = generator.generate(categoryKey: 'general_knowledge.categorization', level: 3);

    final correctItem = knowledgeItems.singleWhere((item) => item.key == task.correctValue);
    final distractorValues = task.options.map((o) => o.value).where((v) => v != task.correctValue);

    for (final value in distractorValues) {
      final item = knowledgeItems.singleWhere((i) => i.key == value);
      expect(item.categoryKey, isNot(correctItem.categoryKey));
    }
  });

  test('works with a completely different dataset (Biologie), proving the generator is generic', () {
    final biologyGenerator = CategorizationTaskGenerator(
      categories: animalHabitatCategories,
      items: animalHabitatItems,
      assetNamespace: 'biology',
      random: Random(7),
    );

    final task = biologyGenerator.generate(categoryKey: 'biology.animal_habitats', level: 2);

    final correctItem = animalHabitatItems.singleWhere((item) => item.key == task.correctValue);
    final askedCategory =
        animalHabitatCategories.singleWhere((c) => c.questionPrompt == task.prompt.text);

    expect(correctItem.categoryKey, askedCategory.key);
    expect(task.prompt.audioAssetPath, contains('biology'));
  });
}
