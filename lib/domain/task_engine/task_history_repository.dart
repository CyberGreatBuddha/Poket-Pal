import 'task_response.dart';

abstract class TaskHistoryRepository {
  // Chronologisch aufsteigend sortierte Historie einer Kategorie fuer ein Pal --
  // exaktes Eingabeformat fuer ResponseTracker.evaluate.
  Future<List<TaskResponse>> getCategoryHistory({
    required int palId,
    required String categoryKey,
  });

  // activityId bleibt unset, wenn die Aufgabe "normal" zuhause ohne
  // Biome-Kontext geloest wurde (siehe Kernsystem 5).
  Future<void> record({
    required int palId,
    required TaskResponse response,
    int? activityId,
  });
}
