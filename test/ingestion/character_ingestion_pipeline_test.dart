import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:poketpal/ingestion/character_ingestion_pipeline.dart';
import 'package:poketpal/ingestion/segmentation/image_segmenter.dart';
import 'package:poketpal/ingestion/sprite_palette_config.dart';

// Simuliert die ML-Kit-Segmentierung mit einem fest kodierten Ergebnis --
// so laesst sich die Pipeline ohne echtes Geraet/Emulator end-to-end pruefen.
class FakeImageSegmenter implements ImageSegmenter {
  final Uint8List Function() imageBytes;

  FakeImageSegmenter(this.imageBytes);

  @override
  Future<SegmentationResult> segment(String imagePath) async {
    return SegmentationResult(
      foregroundImageBytes: imageBytes(),
      modelName: 'fake-model',
      confidence: 0.87,
    );
  }
}

Uint8List _encodedForegroundImage() {
  final image = img.Image(width: 20, height: 20, numChannels: 4);
  for (var y = 5; y < 15; y++) {
    for (var x = 5; x < 15; x++) {
      image.setPixelRgba(x, y, 200, 100, 50, 255);
    }
  }
  return img.encodePng(image);
}

void main() {
  test('processes a photo end-to-end into a sprite-ready draft', () async {
    final pipeline = CharacterIngestionPipeline(
      segmenter: FakeImageSegmenter(_encodedForegroundImage),
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
