import 'dart:typed_data';

// Ergebnis der vollstaendigen Ingestion-Pipeline: das fertige, PNG-kodierte
// Pixel-Art-Sprite plus die Metadaten, die SpriteAsset (Kernsystem 4) braucht.
// Enthaelt bewusst nicht das Rohfoto.
class SpriteAssetDraft {
  final Uint8List spriteImageBytes;
  final int width;
  final int height;
  final String segmentationModel;
  final double segmentationConfidence;

  const SpriteAssetDraft({
    required this.spriteImageBytes,
    required this.width,
    required this.height,
    required this.segmentationModel,
    required this.segmentationConfidence,
  });
}
