import 'package:objectbox/objectbox.dart';

import 'skill_level.dart';

// Difficulty Model pro Pal, generisch ueber beliebig viele Fachbereiche/Kategorien.
@Entity()
class DifficultyModel {
  @Id()
  int id = 0;

  @Backlink('difficultyModel')
  final skillLevels = ToMany<SkillLevel>();
}
