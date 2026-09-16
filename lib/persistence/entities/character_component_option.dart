import 'package:objectbox/objectbox.dart';

// Waehlbare Bauteile fuer den Charakter-Designer.
@Entity()
class CharacterComponentOption {
  @Id()
  int id = 0;

  String componentSlot = ''; // 'bodyShape' | 'primaryColor' | 'eyes' | 'accessory' | 'pattern'
  String assetPath = ''; // Sprite-Bauteil-Asset
  String displayLabel = ''; // z. B. fuer Screenreader/Audio-Hinweis

  bool guidedModeEligible = true; // im gefuehrten Prozess fuer juengere Kinder waehlbar
}
