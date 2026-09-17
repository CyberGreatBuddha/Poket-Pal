import 'package:image/image.dart' as img;

import '../sprite_palette_config.dart';

// Pixelation (Kernsystem 3): Downsampling auf das Sprite-Raster. Nutzt
// Nearest-Neighbor-Interpolation ganz bewusst -- anders als lineare/kubische
// Interpolation mischt sie keine Farben, sodass die zuvor quantisierte
// 16-Bit-Palette (siehe ColorQuantizer) exakt erhalten bleibt.
class Pixelator {
  const Pixelator();

  img.Image pixelate(
    img.Image source, {
    int size = SpritePaletteConfig.spriteRasterSize,
  }) {
    return img.copyResize(
      source,
      width: size,
      height: size,
      interpolation: img.Interpolation.nearest,
    );
  }
}
