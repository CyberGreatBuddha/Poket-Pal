import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:poketpal/ingestion/processing/color_quantizer.dart';

void main() {
  const quantizer = ColorQuantizer();

  test('reduces a many-colored image to at most the requested color count', () {
    final image = img.Image(width: 16, height: 16, numChannels: 4);
    // Jeder Pixel bekommt eine eigene Farbe -> 256 unterschiedliche Farben.
    for (final pixel in image) {
      final index = pixel.y * image.width + pixel.x;
      pixel
        ..r = index % 256
        ..g = (index * 3) % 256
        ..b = (index * 7) % 256
        ..a = 255;
    }

    final quantized = quantizer.quantize(image, colorCount: 4);

    final distinctColors = <int>{};
    for (final pixel in quantized) {
      distinctColors.add((pixel.r.toInt() << 16) | (pixel.g.toInt() << 8) | pixel.b.toInt());
    }

    expect(distinctColors.length, lessThanOrEqualTo(4));
    expect(quantized.width, image.width);
    expect(quantized.height, image.height);
  });

  test('uses the configured default palette size when none is given', () {
    final image = img.Image(width: 8, height: 8, numChannels: 4);
    for (final pixel in image) {
      pixel
        ..r = (pixel.x * 37) % 256
        ..g = (pixel.y * 53) % 256
        ..b = 128
        ..a = 255;
    }

    // Sollte nicht werfen und ein gueltiges Bild liefern.
    final quantized = quantizer.quantize(image);
    expect(quantized.width, 8);
    expect(quantized.height, 8);
  });
}
