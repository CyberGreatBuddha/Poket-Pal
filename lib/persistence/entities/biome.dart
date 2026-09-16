import 'package:objectbox/objectbox.dart';

// Biom/Gebiet: Erkundungsziel ausserhalb des Zuhauses.
@Entity()
class Biome {
  @Id()
  int id = 0;

  String name = ''; // z. B. "Zauberwald", "Kristallhoehle"
  int difficultyTier = 1; // grobe Gesamt-Schwierigkeit des Biomes
  String themeAssetPath = ''; // Hintergrund/Deko-Sprites
  int unlockMinPalLevel = 1; // ab welchem Skill-Level freigeschaltet
}
