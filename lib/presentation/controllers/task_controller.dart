import 'package:flutter/foundation.dart';

import '../../domain/task_engine/default_task_generator_registry.dart';
import '../../domain/task_engine/response_tracker.dart';
import '../../domain/task_engine/skill_evaluator.dart';
import '../../domain/task_engine/skill_level_repository.dart';
import '../../domain/task_engine/task.dart';
import '../../domain/task_engine/task_generator.dart';
import '../../domain/task_engine/task_history_repository.dart';
import '../../domain/task_engine/task_response.dart';

// Verbindet TaskGeneratorRegistry, ResponseTracker und SkillEvaluator mit der
// UI. Kennt bewusst kein PalState/PalController -- gibt die entstandene
// TaskResponse an den Aufrufer zurueck, der sie z. B. an PalController
// weiterreicht (Trennung: Task Engine kennt keine Pal-Stats).
class TaskController extends ChangeNotifier {
  final TaskHistoryRepository _taskHistoryRepository;
  final SkillLevelRepository _skillLevelRepository;
  final TaskGeneratorRegistry _registry;
  final ResponseTracker _responseTracker;
  final SkillEvaluator _skillEvaluator;

  // Oeffentliche Parameternamen + manuelle Zuweisung statt privater
  // initializing formals: private benannte Parameter liessen sich nur
  // innerhalb dieser Datei aufrufen (Dart-Privacy gilt auch fuer
  // Parameternamen), Aufrufer sitzt aber in app.dart.
  TaskController({
    required TaskHistoryRepository taskHistoryRepository,
    required SkillLevelRepository skillLevelRepository,
    TaskGeneratorRegistry? registry,
    ResponseTracker responseTracker = const ResponseTracker(),
    SkillEvaluator skillEvaluator = const SkillEvaluator(),
  })  :
        // ignore: prefer_initializing_formals
        _taskHistoryRepository = taskHistoryRepository,
        // ignore: prefer_initializing_formals
        _skillLevelRepository = skillLevelRepository,
        _registry = registry ?? buildDefaultTaskGeneratorRegistry(),
        // ignore: prefer_initializing_formals
        _responseTracker = responseTracker,
        // ignore: prefer_initializing_formals
        _skillEvaluator = skillEvaluator;

  Task? _currentTask;
  DateTime? _taskShownAt;
  int _currentLevel = 1;
  bool _isLoading = false;
  bool _didLevelUp = false;

  Task? get currentTask => _currentTask;
  bool get isLoading => _isLoading;
  bool get didLevelUp => _didLevelUp;

  Future<void> loadNextTask({required int palId, required String categoryKey}) async {
    _isLoading = true;
    _didLevelUp = false;
    notifyListeners();

    _currentLevel = await _skillLevelRepository.getLevel(palId: palId, categoryKey: categoryKey);
    _currentTask = _registry.generate(categoryKey: categoryKey, level: _currentLevel);
    _taskShownAt = DateTime.now();

    _isLoading = false;
    notifyListeners();
  }

  // Zeichnet die Antwort auf, wertet den Skill-Fortschritt aus und hebt bei
  // Bedarf das Level an (monoton, siehe SkillEvaluator). Gibt die TaskResponse
  // zurueck, damit der Aufrufer die Pal-Stats aktualisieren kann.
  Future<TaskResponse> submitAnswer({
    required int palId,
    required String categoryKey,
    required String selectedValue,
  }) async {
    final task = _currentTask;
    if (task == null) {
      throw StateError('Keine aktuelle Aufgabe -- zuerst loadNextTask aufrufen.');
    }

    final responseTimeMs = DateTime.now().difference(_taskShownAt!).inMilliseconds;
    final response = TaskResponse(
      categoryKey: categoryKey,
      difficultyAtTime: _currentLevel,
      wasCorrect: selectedValue == task.correctValue,
      responseTimeMs: responseTimeMs,
      completedAt: DateTime.now(),
    );

    await _taskHistoryRepository.record(palId: palId, response: response);

    final history = await _taskHistoryRepository.getCategoryHistory(
      palId: palId,
      categoryKey: categoryKey,
    );
    final signal = _responseTracker.evaluate(categoryHistory: history, currentLevel: _currentLevel);
    final decision = _skillEvaluator.evaluate(signal);

    if (decision == SkillDecisionKind.levelUp) {
      await _skillLevelRepository.setLevel(
        palId: palId,
        categoryKey: categoryKey,
        level: _currentLevel + 1,
      );
      _didLevelUp = true;
    }

    notifyListeners();
    return response;
  }
}
