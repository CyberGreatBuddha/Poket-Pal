abstract class SkillLevelRepository {
  // Startet bei Level 1, falls fuer diese Kategorie noch kein Eintrag existiert.
  Future<int> getLevel({required int palId, required String categoryKey});

  // DifficultyModel ist monoton (resolved) -- Implementierungen duerfen das
  // Level nie senken; ein Aufruf mit niedrigerem oder gleichem Level ist ein No-op.
  Future<void> setLevel({
    required int palId,
    required String categoryKey,
    required int level,
  });
}
