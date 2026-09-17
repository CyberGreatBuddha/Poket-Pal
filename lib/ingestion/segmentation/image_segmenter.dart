import 'dart:typed_data';

// Ergebnis der On-Device-ML-Segmentierung: das Vordergrund-Bild (Hintergrund
// entfernt, transparent) als Bildbytes, plus Metadaten fuer die spaetere
// SpriteAsset-Persistenz (Kernsystem 4: segmentationModel, segmentationConfidence).
class SegmentationResult {
  final Uint8List foregroundImageBytes;
  final String modelName;
  final double confidence;

  const SegmentationResult({
    required this.foregroundImageBytes,
    required this.modelName,
    required this.confidence,
  });
}

// Austauschbares Segmentierungs-Interface (Kernsystem 3, resolved): ML Kit
// Subject Segmentation ist die primaere Implementierung; MODNet via
// tflite_flutter waere ein moeglicher Fallback -- beide implementieren dieses
// Interface, ohne dass die Pipeline etwas von der konkreten Technologie wissen muss.
abstract class ImageSegmenter {
  Future<SegmentationResult> segment(String imagePath);
}
