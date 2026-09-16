import 'package:objectbox/objectbox.dart';

// Ergebnis der Character Ingestion Pipeline (Foto -> Spielfigur) oder des Charakter-Designers.
@Entity()
class SpriteAsset {
  @Id()
  int id = 0;

  String spriteFilePath = ''; // finales Pixel-Art-Asset, nicht das Rohfoto
  String paletteId = ''; // referenziert 16-Bit-Palette
  int spriteWidth = 0;
  int spriteHeight = 0;
  DateTime createdAt = DateTime.now();

  // Segmentierungs-Metadaten (fuers Debugging/Re-Processing)
  String segmentationModel = ''; // 'mlkit' | 'modnet'
  double segmentationConfidence = 0.0;

  // Herkunft & Charakter-Designer
  String sourceType = 'photo'; // 'photo' | 'designer'
  String designMode = 'none'; // 'none' | 'guided' | 'free'
}
