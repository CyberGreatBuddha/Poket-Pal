import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/pal/pal_state.dart';
import 'package:poketpal/domain/time_delta/pal_stats.dart';
import 'package:poketpal/objectbox.g.dart';
import 'package:poketpal/persistence/entities/pal.dart' as entities;
import 'package:poketpal/persistence/repositories/object_box_pal_repository.dart';

void main() {
  late Directory tempDir;
  late Store store;
  late ObjectBoxPalRepository repository;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('poketpal_pal_repo_test_');
    store = await openStore(directory: tempDir.path);
    repository = ObjectBoxPalRepository(store);
  });

  tearDown(() {
    store.close();
    tempDir.deleteSync(recursive: true);
  });

  PalState newPal({int id = 0, bool isActive = true, String name = 'Test-Pal'}) {
    final now = DateTime(2026, 1, 1, 9);
    return PalState(
      id: id,
      name: name,
      createdAt: now,
      lastInteractionAt: now,
      stats: PalStats.full(),
      isActive: isActive,
      isFrozen: false,
      locationState: PalLocationState.home,
    );
  }

  test('save assigns a real ObjectBox id to a new pal', () async {
    final saved = await repository.save(newPal());

    expect(saved.id, isNot(0));
    expect(saved.name, 'Test-Pal');
  });

  test('save round-trips all domain fields correctly', () async {
    final pal = newPal().copyWith(
      stats: const PalStats(hunger: 0.4, mood: 0.6, energy: 0.9),
      locationState: PalLocationState.exploring,
    );

    final saved = await repository.save(pal);
    final reloaded = (await repository.getAll()).single;

    expect(reloaded.id, saved.id);
    expect(reloaded.stats.hunger, 0.4);
    expect(reloaded.stats.mood, 0.6);
    expect(reloaded.stats.energy, 0.9);
    expect(reloaded.locationState, PalLocationState.exploring);
  });

  test('updating an existing pal does not create a duplicate', () async {
    final saved = await repository.save(newPal());
    final updated = saved.copyWith(stats: PalStats.atFloor());

    await repository.save(updated);

    expect((await repository.getAll()).length, 1);
    expect((await repository.getAll()).single.stats.hunger, PalStats.atFloor().hunger);
  });

  test('getActive returns only the active pal, ignoring archived ones', () async {
    final archived = await repository.save(newPal(name: 'Alt', isActive: false));
    final active = await repository.save(newPal(name: 'Neu', isActive: true));

    final result = await repository.getActive();

    expect(result, isNotNull);
    expect(result!.id, active.id);
    expect(result.id, isNot(archived.id));
  });

  test('getAll returns the full collection, active and archived (Sammlungsmodell)', () async {
    await repository.save(newPal(name: 'Alt', isActive: false));
    await repository.save(newPal(name: 'Neu', isActive: true));

    expect((await repository.getAll()).length, 2);
  });

  test('save attaches a DifficultyModel to every new pal', () async {
    final saved = await repository.save(newPal());

    final entity = store.box<entities.Pal>().get(saved.id);
    expect(entity!.difficultyModel.target, isNotNull);
  });
}
