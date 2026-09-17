import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/settings/parent_settings.dart';
import 'package:poketpal/objectbox.g.dart';
import 'package:poketpal/persistence/entities/parent_settings_entry.dart';
import 'package:poketpal/persistence/repositories/object_box_parent_settings_repository.dart';

void main() {
  late Directory tempDir;
  late Store store;
  late ObjectBoxParentSettingsRepository repository;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('poketpal_parent_settings_test_');
    store = await openStore(directory: tempDir.path);
    repository = ObjectBoxParentSettingsRepository(store);
  });

  tearDown(() {
    store.close();
    tempDir.deleteSync(recursive: true);
  });

  test('get returns defaults (25 min, enabled) when nothing was saved yet', () async {
    final settings = await repository.get();

    expect(settings.tirednessThresholdMinutes, 25);
    expect(settings.isTirednessLimitEnabled, isTrue);
  });

  test('save persists changes retrievable via get', () async {
    await repository.save(
      const ParentSettings(tirednessThresholdMinutes: 45, isTirednessLimitEnabled: false),
    );

    final settings = await repository.get();

    expect(settings.tirednessThresholdMinutes, 45);
    expect(settings.isTirednessLimitEnabled, isFalse);
  });

  test('save updates the same singleton row instead of creating a new one', () async {
    await repository.save(
      const ParentSettings(tirednessThresholdMinutes: 30, isTirednessLimitEnabled: true),
    );
    await repository.save(
      const ParentSettings(tirednessThresholdMinutes: 60, isTirednessLimitEnabled: false),
    );

    expect(store.box<ParentSettingsEntry>().count(), 1);
    final settings = await repository.get();
    expect(settings.tirednessThresholdMinutes, 60);
  });
}
