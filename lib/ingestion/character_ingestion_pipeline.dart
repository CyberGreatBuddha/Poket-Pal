import 'package:image/image.dart' as img;

import 'processing/color_quantizer.dart';
import 'processing/foreground_cropper.dart';
import 'processing/pixelator.dart';
import 'segmentation/image_segmenter.dart';
import 'sprite_asset_draft.dart';

// Orchestriert die vollstaendige Foto-zu-Sprite-Pipeline (Kernsystem 3):
// Segmentierung -> Freistellen/Zuschnitt -> Farbquantisierung -> Pixelation.
// Die Speicherung als SpriteAsset (letzter Schritt im Pipeline-Diagramm) ist
// Sache des Aufrufers (siehe SpriteAssetRepository) -- diese Klasse liefert
// nur das fertige Ergebnis als Draft und kennt keine Persistenz.
class CharacterIngestionPipeline {
  final ImageSegmenter _segmenter;
  final ForegroundCropper _cropper;
  final ColorQuantizer _quantizer;
  final Pixelator _pixelator;

  // required this._segmenter waere ein privater benannter Parameter und liesse
  // sich dann nur innerhalb dieser Datei aufrufen (Dart-Privacy gilt fuer
  // Parameternamen), Aufrufer sitzen aber in anderen Dateien (App-Wiring, Tests).
  const CharacterIngestionPipeline({
    required ImageSegmenter segmenter,
    this._cropper = const ForegroundCropper(),
    this._quantizer = const ColorQuantizer(),
    this._pixelator = const Pixelator(),
    // ignore: prefer_initializing_formals
  }) : _segmenter = segmenter;

  Future<SpriteAssetDraft> process(String photoPath) async {
    final segmentation = await _segmenter.segment(photoPath);

    final decoded = img.decodeImage(segmentation.foregroundImageBytes);
    if (decoded == null) {
      throw StateError('Segmentiertes Bild konnte nicht dekodiert werden.');
    }

    final cropped = _cropper.crop(decoded);
    final quantized = _quantizer.quantize(cropped);
    final pixelated = _pixelator.pixelate(quantized);

    return SpriteAssetDraft(
      spriteImageBytes: img.encodePng(pixelated),
      width: pixelated.width,
      height: pixelated.height,
      segmentationModel: segmentation.modelName,
      segmentationConfidence: segmentation.confidence,
    );
  }
}
