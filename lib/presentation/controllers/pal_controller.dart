import 'package:flutter/foundation.dart';

import '../../domain/pal/pal_lifecycle_service.dart';
import '../../domain/pal/pal_repository.dart';
import '../../domain/pal/pal_state.dart';
import '../../domain/task_engine/task_response.dart';
import '../../domain/time_delta/soft_reentry.dart';

// Verbindet Time-Delta Engine und Task-Ergebnisse (ueber PalLifecycleService)
// mit der UI. Kennt kein ObjectBox -- nur die PalRepository-Schnittstelle,
// daher austauschbar zwischen In-Memory-Fake und echter Persistenz.
class PalController extends ChangeNotifier {
  final PalRepository _palRepository;
  final PalLifecycleService _lifecycleService;

  // Oeffentliche Parameternamen + manuelle Zuweisung statt privater
  // initializing formals: private benannte Parameter liessen sich nur
  // innerhalb dieser Datei aufrufen (Dart-Privacy gilt auch fuer
  // Parameternamen), Aufrufer sitzt aber in app.dart.
  PalController({
    required PalRepository palRepository,
    PalLifecycleService lifecycleService = const PalLifecycleService(),
  })  :
        // ignore: prefer_initializing_formals
        _palRepository = palRepository,
        // ignore: prefer_initializing_formals
        _lifecycleService = lifecycleService;

  PalState? _pal;
  SoftReEntryPlan? _reEntryPlan;
  bool _isLoading = false;

  PalState? get pal => _pal;
  SoftReEntryPlan? get reEntryPlan => _reEntryPlan;
  bool get isLoading => _isLoading;

  // Beim App-Start aufzurufen: laedt das aktive Pal (oder legt eins an, falls
  // noch keins existiert) und wendet die Time-Delta Engine an.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final existing = await _palRepository.getActive();

    if (existing == null) {
      // Platzhalter-Name, bis ein Namensgebungs-Screen existiert (Design steht noch aus).
      final created = _lifecycleService.createNew(id: 0, name: 'Pal', now: now);
      _pal = await _palRepository.save(created);
      _reEntryPlan = null;
    } else {
      final result = _lifecycleService.resume(existing, now);
      _pal = await _palRepository.save(result.pal);
      _reEntryPlan = result.reEntryPlan;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Werte werden nicht durch Antippen, sondern durch eine geloeste Aufgabe
  // aufgefuellt (Kernsystem 1) -- vom TaskController nach submitAnswer() aufzurufen.
  Future<void> applyTaskResult(TaskResponse response) async {
    final current = _pal;
    if (current == null) return;

    final updated = _lifecycleService.applyTaskResult(current, response, DateTime.now());
    _pal = await _palRepository.save(updated);
    notifyListeners();
  }

  void acknowledgeReEntry() {
    _reEntryPlan = null;
    notifyListeners();
  }
}
