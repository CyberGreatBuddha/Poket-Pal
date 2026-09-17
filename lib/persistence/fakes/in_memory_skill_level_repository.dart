import '../../domain/task_engine/skill_level_repository.dart';

// In-Memory-Implementierung von SkillLevelRepository fuer Entwicklung/Tests
// ohne ObjectBox. Haelt wie die echte Implementierung die Monotonie-Regel ein
// (Level sinkt nie).
class InMemorySkillLevelRepository implements SkillLevelRepository {
  final Map<String, int> _levels = {};

  String _key(int palId, String categoryKey) => '$palId:$categoryKey';

  @override
  Future<int> getLevel({required int palId, required String categoryKey}) async {
    return _levels[_key(palId, categoryKey)] ?? 1;
  }

  @override
  Future<void> setLevel({
    required int palId,
    required String categoryKey,
    required int level,
  }) async {
    final key = _key(palId, categoryKey);
    final existing = _levels[key] ?? 1;
    if (level > existing) {
      _levels[key] = level;
    }
  }
}
