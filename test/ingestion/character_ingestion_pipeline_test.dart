import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:poketpal/ingestion/character_ingestion_pipeline.dart';
import 'package:poketpal/ingestion/sprite_palette_config.dart';

import '../support/fake_image_segmenter.dart';

void main() {
  test('processes a photo end-to-end into a sprite-ready draft', () async {
    final pipeline = CharacterIngestionPipeline(
      segmenter: FakeImageSegmenter(encodedTestForegroundImage),
    );

    final draft = await pipeline.process('irrelevant/path.jpg');

    expect(draft.width, SpritePaletteConfig.spriteRasterSize);
    expect(draft.height, SpritePaletteConfig.spriteRasterSize);
    expect(draft.spriteImageBytes, isNotEmpty);
    expect(draft.segmentationModel, 'fake-model');
    expect(draft.segmentationConfidence, 0.87);
  });

  test('throws when the segmenter returns an image with no foreground', () async {
    final pipeline = CharacterIngestionPipeline(
      segmenter: FakeImageSegmenter(
        () => img.encodePng(img.Image(width: 10, height: 10, numChannels: 4)),
      ),
    );

    expect(() => pipeline.process('irrelevant/path.jpg'), throwsStateError);
  });
}
