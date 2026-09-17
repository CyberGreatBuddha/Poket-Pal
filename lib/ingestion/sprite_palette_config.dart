// Balancing-/Konfigurationswerte fuer die Character Ingestion Pipeline
// (Kernsystem 3), bewusst getrennt von der Verarbeitungslogik -- analog zu
// DifficultyBalancing/TimeDeltaBalancing im Domain Core.
class SpritePaletteConfig {
  // "16-Bit-Palette" (Kernsystem 3, visueller Stil).
  static const int paletteColorCount = 16;

  // Quadratisches Sprite-Raster in Pixeln, Ziel der Pixelation-Stufe.
  static const int spriteRasterSize = 32;

  // Ab diesem Alpha-Wert (0-255) gilt ein Pixel als Vordergrund beim Zuschnitt.
  static const int foregroundAlphaThreshold = 32;
}
