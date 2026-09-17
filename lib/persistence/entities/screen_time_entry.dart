import 'package:objectbox/objectbox.dart';

// Laufender Bildschirmzeit-Zaehler (Muedigkeits-Mechanik). Singleton-artig:
// es existiert immer genau ein Datensatz. Getrennt von ParentSettingsEntry,
// da sich dieser Zaehler staendig aendert, waehrend die Eltern-Einstellungen
// selten angepasst werden.
@Entity()
class ScreenTimeEntry {
  @Id()
  int id = 0;

  int activeScreenTimeSeconds = 0;
  DateTime lastResetDate = DateTime.now();
}
