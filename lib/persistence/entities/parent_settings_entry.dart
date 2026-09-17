import 'package:objectbox/objectbox.dart';

// Elternmenue-Einstellungen (Muedigkeits-Mechanik). Singleton-artig: es
// existiert immer genau ein Datensatz. Getrennt von ScreenTimeEntry, da sich
// diese Werte selten aendern, waehrend der Bildschirmzeit-Zaehler staendig
// aktualisiert wird.
@Entity()
class ParentSettingsEntry {
  @Id()
  int id = 0;

  int tirednessThresholdMinutes = 25;
  bool isTirednessLimitEnabled = true;
}
