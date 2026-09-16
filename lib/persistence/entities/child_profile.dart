import 'package:objectbox/objectbox.dart';

// Kind-Profil: steuert u.a. gefuehrten vs. freien Design-Modus.
@Entity()
class ChildProfile {
  @Id()
  int id = 0;

  String name = '';
  int ageYears = 4; // von den Eltern im Profil-Setup eingegeben
  DateTime createdAt = DateTime.now();
}
