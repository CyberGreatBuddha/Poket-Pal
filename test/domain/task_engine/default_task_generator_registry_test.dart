import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/task_engine/default_task_generator_registry.dart';

void main() {
  test('every defaultCategoryKeys entry is actually registered and dispatches correctly', () {
    final registry = buildDefaultTaskGeneratorRegistry();

    // Verifiziert nebenbei, dass defaultCategoryKeys (fuer UI-Listings) nicht
    // aus der Registry heraus driftet.
    for (final categoryKey in defaultCategoryKeys) {
      final task = registry.generate(categoryKey: categoryKey, level: 1);
      expect(task.categoryKey, categoryKey);
    }
  });

  test('an unregistered categoryKey still throws (fail-fast for unbuilt subjects)', () {
    final registry = buildDefaultTaskGeneratorRegistry();

    expect(
      () => registry.generate(categoryKey: 'biology.animals', level: 1),
      throwsStateError,
    );
  });
}
