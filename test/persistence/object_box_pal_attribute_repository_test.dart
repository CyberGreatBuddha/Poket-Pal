import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/pal/pal_state.dart';
import 'package:poketpal/domain/time_delta/pal_stats.dart';
import 'package:poketpal/objectbox.g.dart';
import 'package:poketpal/persistence/repositories/object_box_pal_attribute_repository.dart';
import 'package:poketpal/persistence/repositories/object_box_pal_repository.dart';

void main() {
  late Directory tempDir;
  late Store store;
  late ObjectBoxPalAttributeRepository repository;
  late int palId;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('poketpal_pal_attribute_test_');
    store = await openStore(directory: tempDir.path);
    repository = ObjectBoxPalAttributeRepository(store);

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

  test('getAll returns an empty PalAttributes when nothing was set yet', () async {
    final attributes = await repository.getAll(palId);
    expect(attributes.asMap(), isEmpty);
  });

  test('setValue persists a key retrievable via getAll', () async {
    await repository.setValue(palId: palId, key: 'personality', value: 'verspielt');

    final attributes = await repository.getAll(palId);
    expect(attributes.getString('personality'), 'verspielt');
  });

  test('setValue overwrites an existing key instead of duplicating it', () async {
    await repository.setValue(palId: palId, key: 'personality', value: 'verspielt');
    await repository.setValue(palId: palId, key: 'personality', value: 'mutig');

    final attributes = await repository.getAll(palId);
    expect(attributes.getString('personality'), 'mutig');
    expect(attributes.asMap().length, 1);
  });

  test('removeValue deletes a key', () async {
    await repository.setValue(palId: palId, key: 'personality', value: 'verspielt');
    await repository.removeValue(palId: palId, key: 'personality');

    final attributes = await repository.getAll(palId);
    expect(attributes.getString('personality'), isNull);
  });

  test('keeps multiple independent keys apart', () async {
    await repository.setValue(palId: palId, key: 'personality', value: 'verspielt');
    await repository.setValue(palId: palId, key: 'favoriteColorIndex', value: '2');

    final attributes = await repository.getAll(palId);
    expect(attributes.getString('personality'), 'verspielt');
    expect(attributes.getInt('favoriteColorIndex'), 2);
  });

  test('setValue throws for an unknown palId', () async {
    expect(
      () => repository.setValue(palId: 999999, key: 'personality', value: 'x'),
      throwsStateError,
    );
  });
}
