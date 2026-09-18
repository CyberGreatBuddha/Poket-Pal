import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:poketpal/ingestion/segmentation/image_segmenter.dart';

// Simuliert die ML-Kit-Segmentierung mit einem fest kodierten Ergebnis --
// so lassen sich Pipeline/Controller/Widgets ohne echtes Geraet/Emulator
// end-to-end pruefen. Geteilt zwischen mehreren Testdateien.
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

// Ein 20x20-Bild mit einem 10x10-Vordergrundblock in der Mitte -- genug
// Vordergrund fuer Zuschnitt/Quantisierung/Pixelation.
Uint8List encodedTestForegroundImage() {
  final image = img.Image(width: 20, height: 20, numChannels: 4);
  for (var y = 5; y < 15; y++) {
    for (var x = 5; x < 15; x++) {
      image.setPixelRgba(x, y, 200, 100, 50, 255);
    }
  }
  return img.encodePng(image);
}
