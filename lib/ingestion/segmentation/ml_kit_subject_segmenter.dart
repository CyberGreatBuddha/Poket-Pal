import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';

import 'image_segmenter.dart';

// Primaere Segmentierungsloesung (Kernsystem 3, resolved): vorgefertigt,
// schnellster Einstieg, gute Qualitaet ohne eigenes Modelltraining.
//
// Kann derzeit nicht auf diesem Windows-Entwicklungsrechner ausgefuehrt/getestet
// werden (braucht Android/iOS-Geraet oder -Emulator) -- die Implementierung
// wurde gegen die tatsaechliche Plugin-API geschrieben und per `flutter analyze`
// typgeprueft, siehe projektkonzept.md Kernsystem 3.
class MlKitSubjectSegmenter implements ImageSegmenter {
  final SubjectSegmenter _segmenter;

  MlKitSubjectSegmenter()
      : _segmenter = SubjectSegmenter(
          options: SubjectSegmenterOptions(
            enableForegroundBitmap: true,
            enableForegroundConfidenceMask: true,
            enableMultipleSubjects: SubjectResultOptions(
              enableConfidenceMask: false,
              enableSubjectBitmap: false,
            ),
          ),
        );

  @override
  Future<SegmentationResult> segment(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _segmenter.processImage(inputImage);

    final bitmap = result.foregroundBitmap;
    if (bitmap == null) {
      throw StateError('ML Kit hat kein Vordergrund-Bitmap geliefert.');
    }

    return SegmentationResult(
      foregroundImageBytes: bitmap,
      modelName: 'mlkit',
      confidence: _averageConfidence(result.foregroundConfidenceMask),
    );
  }

  double _averageConfidence(List<double>? mask) {
    if (mask == null || mask.isEmpty) return 0.0;
    return mask.reduce((a, b) => a + b) / mask.length;
  }

  Future<void> dispose() => _segmenter.close();
}
