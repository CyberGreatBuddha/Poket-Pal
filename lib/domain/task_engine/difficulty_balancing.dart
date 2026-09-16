// Balancing-Config fuer den Skill-Evaluator, bewusst getrennt vom ObjectBox-Schema,
// damit Werte im Playtesting angepasst werden koennen, ohne eine Schema-Migration
// auszuloesen. windowSizeForLevel wird pro SkillLevel-Eintrag aufgerufen.
class DifficultyBalancing {
  static const int baseWindowSize = 10;
  static const double windowSizeStepPerLevel = 1.5;

  static int windowSizeForLevel(int level) {
    return (baseWindowSize + (level - 1) * windowSizeStepPerLevel).round();
  }
}
