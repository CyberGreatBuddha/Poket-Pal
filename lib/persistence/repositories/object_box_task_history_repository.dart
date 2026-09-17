import '../../domain/task_engine/task_history_repository.dart';
import '../../domain/task_engine/task_response.dart';
import '../entities/activity.dart';
import '../entities/pal.dart';
import '../entities/task_record.dart';
import '../mappers/task_record_mapper.dart';
import '../../objectbox.g.dart';

class ObjectBoxTaskHistoryRepository implements TaskHistoryRepository {
  final Store _store;

  ObjectBoxTaskHistoryRepository(this._store);

  Box<TaskRecord> get _box => _store.box<TaskRecord>();
  Box<Pal> get _palBox => _store.box<Pal>();
  Box<Activity> get _activityBox => _store.box<Activity>();

  @override
  Future<List<TaskResponse>> getCategoryHistory({
    required int palId,
    required String categoryKey,
  }) async {
    final query = (_box.query(
      TaskRecord_.pal.equals(palId) & TaskRecord_.categoryKey.equals(categoryKey),
    )..order(TaskRecord_.completedAt))
        .build();
    try {
      return query.find().map(taskRecordEntityToResponse).toList();
    } finally {
      query.close();
    }
  }

  @override
  Future<void> record({
    required int palId,
    required TaskResponse response,
    int? activityId,
  }) async {
    final pal = _palBox.get(palId);
    if (pal == null) {
      throw StateError('Pal mit Id $palId nicht gefunden.');
    }

    final entity = TaskRecord()
      ..categoryKey = response.categoryKey
      ..difficultyAtTime = response.difficultyAtTime
      ..wasCorrect = response.wasCorrect
      ..responseTimeMs = response.responseTimeMs
      ..completedAt = response.completedAt;
    entity.pal.target = pal;

    if (activityId != null) {
      final activity = _activityBox.get(activityId);
      if (activity != null) {
        entity.activity.target = activity;
      }
    }

    _box.put(entity);
  }
}
