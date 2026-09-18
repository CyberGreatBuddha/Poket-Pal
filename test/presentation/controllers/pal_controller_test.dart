import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/ingestion/sprite_asset_draft.dart';
import 'package:poketpal/persistence/fakes/in_memory_pal_repository.dart';
import 'package:poketpal/persistence/fakes/in_memory_sprite_asset_repository.dart';
import 'package:poketpal/presentation/controllers/pal_controller.dart';

void main() {
  test('load() leaves spriteBytes null when no sprite exists yet', () async {
    final controller = PalController(
      palRepository: InMemoryPalRepository(),
      spriteAssetRepository: InMemorySpriteAssetRepository(),
    );

    await controller.load();

    expect(controller.spriteBytes, isNull);
  });

  test('load() exposes an already-saved sprite for the active pal', () async {
    final palRepository = InMemoryPalRepository();
    final spriteAssetRepository = InMemorySpriteAssetRepository();
    final controller = PalController(
      palRepository: palRepository,
      spriteAssetRepository: spriteAssetRepository,
    );

    // Pal zuerst anlegen (vergibt die Id), dann Sprite dafuer speichern --
    // spiegelt die tatsaechliche Reihenfolge (Pal existiert vor der Ingestion).
    await controller.load();
    final palId = controller.pal!.id;
    final bytes = Uint8List.fromList([1, 2, 3]);
    await spriteAssetRepository.saveForPal(
      palId: palId,
      draft: SpriteAssetDraft(
        spriteImageBytes: bytes,
        width: 16,
        height: 16,
        segmentationModel: 'fake-model',
        segmentationConfidence: 0.9,
      ),
      sourceType: 'photo',
    );

    await controller.load();

    expect(controller.spriteBytes, bytes);
  });

  test('reloadSprite() picks up a sprite saved after the initial load', () async {
    final palRepository = InMemoryPalRepository();
    final spriteAssetRepository = InMemorySpriteAssetRepository();
    final controller = PalController(
      palRepository: palRepository,
      spriteAssetRepository: spriteAssetRepository,
    );

    await controller.load();
    expect(controller.spriteBytes, isNull);

    final bytes = Uint8List.fromList([4, 5, 6]);
    await spriteAssetRepository.saveForPal(
      palId: controller.pal!.id,
      draft: SpriteAssetDraft(
        spriteImageBytes: bytes,
        width: 16,
        height: 16,
        segmentationModel: 'fake-model',
        segmentationConfidence: 0.9,
      ),
      sourceType: 'photo',
    );

    await controller.reloadSprite();

    expect(controller.spriteBytes, bytes);
  });
}
