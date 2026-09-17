import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/pal/pal_state.dart';
import 'package:poketpal/domain/task_engine/task_response.dart';
import 'package:poketpal/domain/time_delta/pal_stats.dart';
import 'package:poketpal/objectbox.g.dart';
import 'package:poketpal/persistence/repositories/object_box_pal_repository.dart';
import 'package:poketpal/persistence/repositories/object_box_task_history_repository.dart';

void main() {
  late Directory tempDir;
  late Store store;
  late ObjectBoxTaskHistoryRepository repository;
  late int palId;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('poketpal_task_history_test_');
    store = await openStore(directory: tempDir.path);
    repository = ObjectBoxTaskHistoryRepository(store);

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

  TaskResponse response({required String categoryKey, required DateTime completedAt, bool wasCorrect = true}) {
    return TaskResponse(
      categoryKey: categoryKey,
      difficultyAtTime: 1,
      wasCorrect: wasCorrect,
      responseTimeMs: 1500,
      completedAt: completedAt,
    );
  }

  test('getCategoryHistory returns an empty list when nothing was recorded yet', () async {
    final history = await repository.getCategoryHistory(palId: palId, categoryKey: 'math.pictogram');
    expect(history, isEmpty);
  });

  test('record persists a response retrievable via getCategoryHistory', () async {
    await repository.record(
      palId: palId,
      response: response(categoryKey: 'math.pictogram', completedAt: DateTime(2026, 1, 2)),
    );

    final history = await repository.getCategoryHistory(palId: palId, categoryKey: 'math.pictogram');

    expect(history, hasLength(1));
    expect(history.single.categoryKey, 'math.pictogram');
    expect(history.single.wasCorrect, isTrue);
  });

  test('getCategoryHistory returns results ordered chronologically ascending', () async {
    await repository.record(
      palId: palId,
      response: response(categoryKey: 'math.pictogram', completedAt: DateTime(2026, 1, 3)),
    );
    await repository.record(
      palId: palId,
      response: response(categoryKey: 'math.pictogram', completedAt: DateTime(2026, 1, 1)),
    );
    await repository.record(
      palId: palId,
      response: response(categoryKey: 'math.pictogram', completedAt: DateTime(2026, 1, 2)),
    );

    final history = await repository.getCategoryHistory(palId: palId, categoryKey: 'math.pictogram');

    expect(history.map((r) => r.completedAt.day).toList(), [1, 2, 3]);
  });

  test('getCategoryHistory only returns responses for the requested categoryKey', () async {
    await repository.record(
      palId: palId,
      response: response(categoryKey: 'math.pictogram', completedAt: DateTime(2026, 1, 1)),
    );
    await repository.record(
      palId: palId,
      response: response(categoryKey: 'math.comparison', completedAt: DateTime(2026, 1, 1)),
    );

    final history = await repository.getCategoryHistory(palId: palId, categoryKey: 'math.comparison');

    expect(history, hasLength(1));
    expect(history.single.categoryKey, 'math.comparison');
  });

  test('record throws for an unknown palId', () async {
    expect(
      () => repository.record(
        palId: 999999,
        response: response(categoryKey: 'math.pictogram', completedAt: DateTime(2026, 1, 1)),
      ),
      throwsStateError,
    );
  });
}
