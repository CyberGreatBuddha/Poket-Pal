import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/settings/parent_settings.dart';
import '../../domain/settings/parent_settings_repository.dart';
import '../../domain/tiredness/screen_time_repository.dart';
import '../../domain/tiredness/screen_time_state.dart';
import '../../domain/tiredness/tiredness_balancing.dart';
import '../../domain/tiredness/tiredness_state.dart';
import '../../domain/tiredness/tiredness_tracker.dart';

// Zeitstempel-basierte Bildschirmzeit-Erfassung (Muedigkeits-Mechanik,
// Feature-Spec Abschnitt 2) -- komplett unabhaengig von PalStats/
// TimeDeltaEngine und von der Task Engine. Registriert sich selbst als
// WidgetsBindingObserver; nur AppLifecycleState.paused zaehlt als
// "im Hintergrund" (kurze Uebergaenge wie 'inactive', z. B. ein eingehender
// Anruf-Banner, werden bewusst ignoriert, um Flackern zu vermeiden).
class ScreenTimeController extends ChangeNotifier with WidgetsBindingObserver {
  final ScreenTimeRepository _screenTimeRepository;
  final ParentSettingsRepository _parentSettingsRepository;
  final TirednessTracker _tracker;

  // Oeffentliche Parameternamen + manuelle Zuweisung statt privater
  // initializing formals (siehe PalController/PalLifecycleService fuer die
  // Begruendung -- Aufrufer sitzt in app.dart).
  ScreenTimeController({
    required ScreenTimeRepository screenTimeRepository,
    required ParentSettingsRepository parentSettingsRepository,
    TirednessTracker tracker = const TirednessTracker(),
  })  :
        // ignore: prefer_initializing_formals
        _screenTimeRepository = screenTimeRepository,
        // ignore: prefer_initializing_formals
        _parentSettingsRepository = parentSettingsRepository,
        // ignore: prefer_initializing_formals
        _tracker = tracker {
    WidgetsBinding.instance.addObserver(this);
  }

  ScreenTimeState _screenTimeState = ScreenTimeState.initial(DateTime.now());
  ParentSettings _settings = ParentSettings.defaults();
  DateTime? _activeSince;
  Timer? _uiRefreshTimer;
  Timer? _safetySaveTimer;

  ParentSettings get settings => _settings;

  TirednessState get tirednessState => TirednessState(
        activeScreenTimeSeconds:
            _screenTimeState.activeScreenTimeSeconds + _currentIntervalSeconds,
        thresholdMinutes: _settings.tirednessThresholdMinutes,
        isLimitEnabled: _settings.isTirednessLimitEnabled,
      );

  int get _currentIntervalSeconds =>
      _activeSince == null ? 0 : DateTime.now().difference(_activeSince!).inSeconds;

  // Beim App-Start aufzurufen (siehe app.dart).
  Future<void> start() async {
    _settings = await _parentSettingsRepository.get();
    _screenTimeState = await _screenTimeRepository.get();
    await _onBecameActive();
  }

  Future<void> updateSettings(ParentSettings settings) async {
    _settings = settings;
    await _parentSettingsRepository.save(settings);
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _onBecameInactive();
    } else if (state == AppLifecycleState.resumed) {
      _onBecameActive();
    }
  }

  Future<void> _onBecameActive() async {
    final now = DateTime.now();
    _screenTimeState = _tracker.applyDailyResetIfNeeded(_screenTimeState, now);
    _activeSince = now;
    _uiRefreshTimer ??= Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
    _safetySaveTimer ??= Timer.periodic(TirednessBalancing.safetySaveInterval, (_) => _flush());
    notifyListeners();
  }

  Future<void> _onBecameInactive() async {
    await _flush();
    _activeSince = null;
    _uiRefreshTimer?.cancel();
    _uiRefreshTimer = null;
    _safetySaveTimer?.cancel();
    _safetySaveTimer = null;
  }

  // Schreibt das seit _activeSince verstrichene Intervall fest und setzt
  // _activeSince neu, damit nachfolgende Flushes nicht doppelt zaehlen.
  Future<void> _flush() async {
    final activeSince = _activeSince;
    if (activeSince == null) return;

    final now = DateTime.now();
    final elapsedSeconds = now.difference(activeSince).inSeconds;
    _activeSince = now;
    if (elapsedSeconds <= 0) return;

    _screenTimeState = _tracker.recordActiveInterval(
      current: _screenTimeState,
      additionalActiveSeconds: elapsedSeconds,
      now: now,
    );
    await _screenTimeRepository.save(_screenTimeState);
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _uiRefreshTimer?.cancel();
    _safetySaveTimer?.cancel();
    super.dispose();
  }
}
