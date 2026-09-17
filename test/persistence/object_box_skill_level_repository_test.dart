import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/pal/pal_state.dart';
import 'package:poketpal/domain/time_delta/pal_stats.dart';
import 'package:poketpal/objectbox.g.dart';
import 'package:poketpal/persistence/repositories/object_box_pal_repository.dart';
import 'package:poketpal/persistence/repositories/object_box_skill_level_repository.dart';

void main() {
  late Directory tempDir;
  late Store store;
  late ObjectBoxSkillLevelRepository repository;
  late int palId;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('poketpal_skill_level_test_');
    store = await openStore(directory: tempDir.path);
    repository = ObjectBoxSkillLevelRepository(store);

    final palRepo = ObjectBoxPalRepository(store);
    final now = DateTime(2026, 1, 1);
    final saved = await palRepo.save(PalState(
      id: 0,
      name: 'Test-Pal',
      createdAt: now,
      lastInteractionAt: now,
      stats: PalStats.full(),
      isActive: true,
      isFrozen: false,
      locationState: PalLocationState.home,
    ));
    palId = saved.id;
  });

  tearDown(() {
    store.close();
    tempDir.deleteSync(recursive: true);
  });

  test('getLevel defaults to 1 for a category with no entry yet', () async {
    final level = await repository.getLevel(palId: palId, categoryKey: 'math.pictogram');
    expect(level, 1);
  });

  test('setLevel persists a level that getLevel then returns', () async {
    await repository.setLevel(palId: palId, categoryKey: 'math.pictogram', level: 3);
    final level = await repository.getLevel(palId: palId, categoryKey: 'math.pictogram');
    expect(level, 3);
  });

  test('setLevel never lowers an existing level (DifficultyModel is monoton)', () async {
    await repository.setLevel(palId: palId, categoryKey: 'math.pictogram', level: 4);
    await repository.setLevel(palId: palId, categoryKey: 'math.pictogram', level: 2);

    final level = await repository.getLevel(palId: palId, categoryKey: 'math.pictogram');
    expect(level, 4);
  });

  test('setLevel keeps categories independent from each other', () async {
    await repository.setLevel(palId: palId, categoryKey: 'math.pictogram', level: 3);
    await repository.setLevel(palId: palId, categoryKey: 'math.comparison', level: 1);

    expect(await repository.getLevel(palId: palId, categoryKey: 'math.pictogram'), 3);
    expect(await repository.getLevel(palId: palId, categoryKey: 'math.comparison'), 1);
  });

  test('setLevel throws for an unknown palId', () async {
    expect(
      () => repository.setLevel(palId: 999999, categoryKey: 'math.pictogram', level: 2),
      throwsStateError,
    );
  });
}
