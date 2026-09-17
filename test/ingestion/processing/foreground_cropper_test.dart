import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:poketpal/ingestion/processing/foreground_cropper.dart';

// Eine frisch angelegte Image-Instanz mit Alphakanal ist bereits komplett
// transparent (Nullbytes) -- kein manuelles Initialisieren noetig.
img.Image _transparentCanvas(int size) {
  return img.Image(width: size, height: size, numChannels: 4);
}

void main() {
  const cropper = ForegroundCropper();

  test('crops to the tight bounding box of opaque pixels', () {
    final image = _transparentCanvas(6);
    for (var y = 2; y <= 3; y++) {
      for (var x = 2; x <= 3; x++) {
        image.setPixelRgba(x, y, 255, 0, 0, 255);
      }
    }

    final cropped = cropper.crop(image);

    expect(cropped.width, 2);
    expect(cropped.height, 2);
    for (final pixel in cropped) {
      expect(pixel.a, 255);
    }
  });

  test('ignores pixels below the foreground alpha threshold', () {
    final image = _transparentCanvas(6);
    image.setPixelRgba(1, 1, 0, 0, 0, 10); // unter dem Schwellenwert -> kein Vordergrund
    image.setPixelRgba(4, 4, 255, 255, 255, 255);

    final cropped = cropper.crop(image);

    expect(cropped.width, 1);
    expect(cropped.height, 1);
  });

  test('throws when the image has no foreground pixels at all', () {
    final image = _transparentCanvas(4);

    expect(() => cropper.crop(image), throwsStateError);
  });
}
