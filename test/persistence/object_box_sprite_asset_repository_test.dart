import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:poketpal/domain/pal/pal_state.dart';
import 'package:poketpal/domain/time_delta/pal_stats.dart';
import 'package:poketpal/ingestion/sprite_asset_draft.dart';
import 'package:poketpal/objectbox.g.dart';
import 'package:poketpal/persistence/entities/pal.dart' as entities;
import 'package:poketpal/persistence/repositories/object_box_pal_repository.dart';
import 'package:poketpal/persistence/repositories/object_box_sprite_asset_repository.dart';

// Ersetzt den echten Plattform-Kanal von path_provider durch eine einfache
// Dart-Implementierung, die auf ein temporaeres Verzeichnis zeigt -- so
// braucht der Test keine echte Flutter-Engine/Plugin-Registrierung.
class FakePathProviderPlatform extends PathProviderPlatform {
  final String documentsPath;

  FakePathProviderPlatform(this.documentsPath);

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;
}

void main() {
  late Directory tempDir;
  late Directory documentsDir;
  late Store store;
  late ObjectBoxSpriteAssetRepository repository;
  late int palId;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('poketpal_sprite_asset_test_');
    documentsDir = Directory.systemTemp.createTempSync('poketpal_sprite_asset_docs_');
    PathProviderPlatform.instance = FakePathProviderPlatform(documentsDir.path);

    store = await openStore(directory: tempDir.path);
    repository = ObjectBoxSpriteAssetRepository(store);

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
    documentsDir.deleteSync(recursive: true);
  });

  SpriteAssetDraft draft() {
    return SpriteAssetDraft(
      spriteImageBytes: Uint8List.fromList([1, 2, 3, 4, 5]),
      width: 32,
      height: 32,
      segmentationModel: 'mlkit',
      segmentationConfidence: 0.9,
    );
  }

  test('saveForPal writes the sprite file to disk with the correct bytes', () async {
    await repository.saveForPal(palId: palId, draft: draft(), sourceType: 'photo');

    final entity = store.box<entities.Pal>().get(palId)!;
    final spriteAsset = entity.spriteAsset.target!;
    final file = File(spriteAsset.spriteFilePath);

    expect(await file.exists(), isTrue);
    expect(await file.readAsBytes(), [1, 2, 3, 4, 5]);
  });

  test('saveForPal links the SpriteAsset 1:1 to the pal with correct metadata', () async {
    await repository.saveForPal(palId: palId, draft: draft(), sourceType: 'photo');

    final entity = store.box<entities.Pal>().get(palId)!;
    final spriteAsset = entity.spriteAsset.target;

    expect(spriteAsset, isNotNull);
    expect(spriteAsset!.spriteWidth, 32);
    expect(spriteAsset.spriteHeight, 32);
    expect(spriteAsset.segmentationModel, 'mlkit');
    expect(spriteAsset.segmentationConfidence, 0.9);
    expect(spriteAsset.sourceType, 'photo');
  });

  test('saveForPal throws for an unknown palId', () async {
    expect(
      () => repository.saveForPal(palId: 999999, draft: draft(), sourceType: 'photo'),
      throwsStateError,
    );
  });
}
