import 'package:objectbox/objectbox.dart';

import 'pal.dart';

// Generischer Erweiterungspunkt fuer zukuenftige Pal-Eigenschaften, die noch
// nicht abschliessend definiert sind (z. B. Persoenlichkeit, Vorlieben,
// kosmetische Merkmale). Analog zum SkillLevel-Muster (Kernsystem 4): neue
// Eigenschaften werden als key/value-Eintrag ergaenzt, ohne dass das Pal-Schema
// selbst migriert werden muss. Typisierte Interpretation der Werte uebernimmt
// PalAttributes im Domain Core.
@Entity()
class PalAttribute {
  @Id()
  int id = 0;

  final pal = ToOne<Pal>();
  String key = '';
  String value = '';
}
