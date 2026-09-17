import 'package:image/image.dart' as img;

import '../sprite_palette_config.dart';

// "Freistellen + Zuschnitt" (Kernsystem 3): schneidet das segmentierte Bild auf
// die engste Bounding-Box der nicht-transparenten (Vordergrund-)Pixel zu.
class ForegroundCropper {
  const ForegroundCropper();

  img.Image crop(img.Image segmented) {
    var minX = segmented.width;
    var minY = segmented.height;
    var maxX = -1;
    var maxY = -1;

    for (final pixel in segmented) {
      if (pixel.a < SpritePaletteConfig.foregroundAlphaThreshold) continue;
      if (pixel.x < minX) minX = pixel.x;
      if (pixel.x > maxX) maxX = pixel.x;
      if (pixel.y < minY) minY = pixel.y;
      if (pixel.y > maxY) maxY = pixel.y;
    }

    if (maxX < minX || maxY < minY) {
      throw StateError('Kein Vordergrund im segmentierten Bild gefunden.');
    }

    return img.copyCrop(
      segmented,
      x: minX,
      y: minY,
      width: maxX - minX + 1,
      height: maxY - minY + 1,
    );
  }
}
