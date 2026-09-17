// Domain-seitiges Pendant zu TaskRecord (Persistenz-Entity, Kernsystem 4) --
// der Domain Core kennt keine ObjectBox-Typen.
class TaskResponse {
  final String categoryKey;
  final int difficultyAtTime;
  final bool wasCorrect;
  final int responseTimeMs;
  final DateTime completedAt;

  const TaskResponse({
    required this.categoryKey,
    required this.difficultyAtTime,
    required this.wasCorrect,
    required this.responseTimeMs,
    required this.completedAt,
  });
}
