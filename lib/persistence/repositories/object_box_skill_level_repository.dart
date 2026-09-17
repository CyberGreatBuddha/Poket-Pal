import 'package:objectbox/objectbox.dart';

import '../../domain/task_engine/skill_level_repository.dart';
import '../entities/difficulty_model.dart';
import '../entities/pal.dart';
import '../entities/skill_level.dart';

class ObjectBoxSkillLevelRepository implements SkillLevelRepository {
  final Store _store;

  ObjectBoxSkillLevelRepository(this._store);

  Box<Pal> get _palBox => _store.box<Pal>();
  Box<DifficultyModel> get _difficultyModelBox => _store.box<DifficultyModel>();
  Box<SkillLevel> get _skillLevelBox => _store.box<SkillLevel>();

  @override
  Future<int> getLevel({required int palId, required String categoryKey}) async {
    final entry = _findSkillLevel(palId, categoryKey);
    return entry?.level ?? 1;
  }

  @override
  Future<void> setLevel({
    required int palId,
    required String categoryKey,
    required int level,
  }) async {
    final pal = _palBox.get(palId);
    if (pal == null) {
      throw StateError('Pal mit Id $palId nicht gefunden.');
    }

    var difficultyModel = pal.difficultyModel.target;
    if (difficultyModel == null) {
      difficultyModel = DifficultyModel();
      _difficultyModelBox.put(difficultyModel);
      pal.difficultyModel.target = difficultyModel;
      _palBox.put(pal);
    }

    final existing = _findSkillLevelInModel(difficultyModel, categoryKey);
    if (existing != null) {
      if (level <= existing.level) {
        return; // DifficultyModel ist monoton (resolved) -- nie senken.
      }
      existing
        ..level = level
        ..lastLevelUpAt = DateTime.now();
      _skillLevelBox.put(existing);
      return;
    }

    final newEntry = SkillLevel()
      ..categoryKey = categoryKey
      ..level = level
      ..lastLevelUpAt = DateTime.now();
    newEntry.difficultyModel.target = difficultyModel;
    _skillLevelBox.put(newEntry);
  }

  SkillLevel? _findSkillLevel(int palId, String categoryKey) {
    final difficultyModel = _palBox.get(palId)?.difficultyModel.target;
    if (difficultyModel == null) return null;
    return _findSkillLevelInModel(difficultyModel, categoryKey);
  }

  SkillLevel? _findSkillLevelInModel(DifficultyModel model, String categoryKey) {
    for (final skillLevel in model.skillLevels) {
      if (skillLevel.categoryKey == categoryKey) return skillLevel;
    }
    return null;
  }
}
