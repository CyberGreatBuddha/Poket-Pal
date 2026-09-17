import '../../domain/task_engine/task_history_repository.dart';
import '../../domain/task_engine/task_response.dart';

class _StoredResponse {
  final int palId;
  final TaskResponse response;

  const _StoredResponse(this.palId, this.response);
}

// In-Memory-Implementierung von TaskHistoryRepository fuer Entwicklung/Tests
// ohne ObjectBox. Anders als die ObjectBox-Variante wird die Existenz des Pals
// bewusst nicht geprueft -- das haette eine Kopplung an InMemoryPalRepository
// erfordert, die fuer eine reine Entwicklungs-Fake unnoetig ist.
class InMemoryTaskHistoryRepository implements TaskHistoryRepository {
  final List<_StoredResponse> _records = [];

  @override
  Future<List<TaskResponse>> getCategoryHistory({
    required int palId,
    required String categoryKey,
  }) async {
    final matches = _records
        .where((r) => r.palId == palId && r.response.categoryKey == categoryKey)
        .map((r) => r.response)
        .toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    return matches;
  }

  @override
  Future<void> record({
    required int palId,
    required TaskResponse response,
    int? activityId,
  }) async {
    _records.add(_StoredResponse(palId, response));
  }
}
