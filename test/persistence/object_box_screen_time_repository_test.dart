import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/tiredness/screen_time_state.dart';
import 'package:poketpal/objectbox.g.dart';
import 'package:poketpal/persistence/entities/screen_time_entry.dart';
import 'package:poketpal/persistence/repositories/object_box_screen_time_repository.dart';

void main() {
  late Directory tempDir;
  late Store store;
  late ObjectBoxScreenTimeRepository repository;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('poketpal_screen_time_test_');
    store = await openStore(directory: tempDir.path);
    repository = ObjectBoxScreenTimeRepository(store);
  });

  tearDown(() {
    store.close();
    tempDir.deleteSync(recursive: true);
  });

  test('get returns a fresh zero counter when nothing was saved yet', () async {
    final state = await repository.get();
    expect(state.activeScreenTimeSeconds, 0);
  });

  test('save persists changes retrievable via get', () async {
    final now = DateTime(2026, 2, 1, 12);
    await repository.save(ScreenTimeState(activeScreenTimeSeconds: 750, lastResetDate: now));

    final state = await repository.get();

    expect(state.activeScreenTimeSeconds, 750);
    expect(state.lastResetDate, now);
  });

  test('save updates the same singleton row instead of creating a new one', () async {
    await repository.save(ScreenTimeState.initial(DateTime(2026, 2, 1)));
    await repository.save(
      ScreenTimeState(activeScreenTimeSeconds: 1200, lastResetDate: DateTime(2026, 2, 1)),
    );

    expect(store.box<ScreenTimeEntry>().count(), 1);
    final state = await repository.get();
    expect(state.activeScreenTimeSeconds, 1200);
  });
}
