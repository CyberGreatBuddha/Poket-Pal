import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:poketpal/ingestion/character_ingestion_pipeline.dart';
import 'package:poketpal/persistence/fakes/in_memory_sprite_asset_repository.dart';
import 'package:poketpal/presentation/controllers/ingestion_controller.dart';

import '../../support/fake_image_segmenter.dart';

void main() {
  test('ingestFromPath processes and saves a draft, exposing it via lastDraft', () async {
    final controller = IngestionController(
      pipeline: CharacterIngestionPipeline(
        segmenter: FakeImageSegmenter(encodedTestForegroundImage),
      ),
      spriteAssetRepository: InMemorySpriteAssetRepository(),
    );

    expect(controller.isProcessing, isFalse);
    expect(controller.lastDraft, isNull);

    await controller.ingestFromPath(palId: 1, imagePath: 'irrelevant.jpg');

    expect(controller.isProcessing, isFalse);
    expect(controller.lastDraft, isNotNull);
    expect(controller.error, isNull);
  });

  test('sets error instead of throwing when the pipeline fails', () async {
    final controller = IngestionController(
      pipeline: CharacterIngestionPipeline(
        segmenter: FakeImageSegmenter(
          () => img.encodePng(img.Image(width: 10, height: 10, numChannels: 4)),
        ),
      ),
      spriteAssetRepository: InMemorySpriteAssetRepository(),
    );

    await controller.ingestFromPath(palId: 1, imagePath: 'irrelevant.jpg');

    expect(controller.isProcessing, isFalse);
    expect(controller.lastDraft, isNull);
    expect(controller.error, isNotNull);
  });

  test('reset clears a previous result', () async {
    final controller = IngestionController(
      pipeline: CharacterIngestionPipeline(
        segmenter: FakeImageSegmenter(encodedTestForegroundImage),
      ),
      spriteAssetRepository: InMemorySpriteAssetRepository(),
    );

    await controller.ingestFromPath(palId: 1, imagePath: 'irrelevant.jpg');
    expect(controller.lastDraft, isNotNull);

    controller.reset();

    expect(controller.lastDraft, isNull);
    expect(controller.error, isNull);
  });
}
