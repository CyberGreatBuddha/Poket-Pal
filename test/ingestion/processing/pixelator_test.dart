import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:poketpal/ingestion/processing/pixelator.dart';

void main() {
  const pixelator = Pixelator();

  test('resizes to the requested square raster size', () {
    final image = img.Image(width: 64, height: 64, numChannels: 4);
    final result = pixelator.pixelate(image, size: 16);

    expect(result.width, 16);
    expect(result.height, 16);
  });

  test('uses the configured default sprite raster size when none is given', () {
    final image = img.Image(width: 100, height: 100, numChannels: 4);
    final result = pixelator.pixelate(image);

    expect(result.width, 32);
    expect(result.height, 32);
  });

  test('nearest-neighbor downsampling never blends colors from different quadrants', () {
    // Vier Quadranten mit klar unterschiedlichen, satten Farben.
    final image = img.Image(width: 8, height: 8, numChannels: 4);
    for (final pixel in image) {
      final isLeft = pixel.x < 4;
      final isTop = pixel.y < 4;
      if (isLeft && isTop) {
        pixel
          ..r = 255
          ..g = 0
          ..b = 0
          ..a = 255;
      } else if (!isLeft && isTop) {
        pixel
          ..r = 0
          ..g = 255
          ..b = 0
          ..a = 255;
      } else if (isLeft && !isTop) {
        pixel
          ..r = 0
          ..g = 0
          ..b = 255
          ..a = 255;
      } else {
        pixel
          ..r = 255
          ..g = 255
          ..b = 0
          ..a = 255;
      }
    }

    final result = pixelator.pixelate(image, size: 2);

    final expectedColors = {
      (255, 0, 0),
      (0, 255, 0),
      (0, 0, 255),
      (255, 255, 0),
    };
    for (final pixel in result) {
      final color = (pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
      expect(expectedColors, contains(color));
    }
  });
}
