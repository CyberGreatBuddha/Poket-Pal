import 'package:image/image.dart' as img;

import '../sprite_palette_config.dart';

// Farbquantisierung auf die 16-Bit-Palette (Kernsystem 3, visueller Stil).
// Delegiert an den etablierten Octree-Quantizer aus dem `image`-Package,
// statt einen eigenen Quantisierungs-Algorithmus neu zu implementieren.
class ColorQuantizer {
  const ColorQuantizer();

  img.Image quantize(img.Image source, {int colorCount = SpritePaletteConfig.paletteColorCount}) {
    return img.quantize(source, numberOfColors: colorCount, method: img.QuantizeMethod.octree);
  }
}
