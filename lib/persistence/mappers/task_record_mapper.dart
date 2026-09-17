import '../../domain/task_engine/task_response.dart';
import '../entities/task_record.dart';

TaskResponse taskRecordEntityToResponse(TaskRecord entity) {
  return TaskResponse(
    categoryKey: entity.categoryKey,
    difficultyAtTime: entity.difficultyAtTime,
    wasCorrect: entity.wasCorrect,
    responseTimeMs: entity.responseTimeMs,
    completedAt: entity.completedAt,
  );
}
