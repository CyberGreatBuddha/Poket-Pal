import 'package:objectbox/objectbox.dart';

import 'difficulty_model.dart';

// Einzelnes Skill-Level: ein Eintrag pro Kategorie,
// z.B. 'math.pictogram', 'german.vocabulary', 'music.rhythm'.
@Entity()
class SkillLevel {
  @Id()
  int id = 0;

  final difficultyModel = ToOne<DifficultyModel>();
  String categoryKey = ''; // z. B. 'math.pictogram', 'math.comparison', 'german.vocabulary', 'biology.animals', 'music.rhythm'
  int level = 1; // monoton, sinkt nie
  DateTime lastLevelUpAt = DateTime.now();
}
