import 'difficulty_balancing.dart';
import 'task_response.dart';

// Skill-Signal: rollierender Durchschnitt aus Korrektheit + Loesungsgeschwindigkeit,
// um Streuung durch Aufmerksamkeitsspanne/Motorik bei Kleinkindern zu glaetten.
class SkillSignal {
  final double averageCorrectness;
  final double averageResponseTimeMs;
  final int sampleSize;

  const SkillSignal({
    required this.averageCorrectness,
    required this.averageResponseTimeMs,
    required this.sampleSize,
  });
}

// ResponseTracker: die Fenstergroesse fuer den rollierenden Durchschnitt waechst
// pro categoryKey separat mit dem aktuellen SkillLevel.level dieser Kategorie
// (siehe DifficultyBalancing.windowSizeForLevel).
class ResponseTracker {
  const ResponseTracker();

  // categoryHistory muss chronologisch sortiert sein (aelteste zuerst) und nur
  // Antworten der betrachteten categoryKey enthalten. Gibt null zurueck, solange
  // noch nicht genug Datenpunkte fuer eine stabile Entscheidung vorliegen.
  SkillSignal? evaluate({
    required List<TaskResponse> categoryHistory,
    required int currentLevel,
  }) {
    final windowSize = DifficultyBalancing.windowSizeForLevel(currentLevel);
    if (categoryHistory.length < windowSize) {
      return null;
    }

    final window = categoryHistory.sublist(categoryHistory.length - windowSize);
    final correctCount = window.where((response) => response.wasCorrect).length;
    final totalResponseTimeMs =
        window.fold<int>(0, (sum, response) => sum + response.responseTimeMs);

    return SkillSignal(
      averageCorrectness: correctCount / window.length,
      averageResponseTimeMs: totalResponseTimeMs / window.length,
      sampleSize: window.length,
    );
  }
}
