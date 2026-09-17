import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/settings/parent_settings.dart';
import 'package:poketpal/persistence/fakes/in_memory_parent_settings_repository.dart';
import 'package:poketpal/persistence/fakes/in_memory_screen_time_repository.dart';
import 'package:poketpal/presentation/controllers/screen_time_controller.dart';

void main() {
  // WidgetsFlutterBinding wird gebraucht, da ScreenTimeController sich als
  // WidgetsBindingObserver registriert.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('start loads settings and an initially fresh (non-tired) state', () async {
    final controller = ScreenTimeController(
      screenTimeRepository: InMemoryScreenTimeRepository(),
      parentSettingsRepository: InMemoryParentSettingsRepository(),
    );

    await controller.start();

    expect(controller.settings.tirednessThresholdMinutes, 25);
    expect(controller.tirednessState.isTired, isFalse);
    expect(controller.tirednessState.activeScreenTimeSeconds, 0);

    controller.dispose();
  });

  test('accumulates active time while running (timestamp-based, not tick-based)', () async {
    final controller = ScreenTimeController(
      screenTimeRepository: InMemoryScreenTimeRepository(),
      parentSettingsRepository: InMemoryParentSettingsRepository(),
    );

    await controller.start();
    // Kurze echte Wartezeit, um eine tatsaechlich verstrichene Zeitspanne zu
    // erzeugen -- die Messung selbst ist zeitstempel-basiert, kein Timer-Tick
    // wird hier vorausgesetzt.
    await Future.delayed(const Duration(milliseconds: 1100));

    // didChangeAppLifecycleState(paused) simulieren, um einen Flush auszuloesen.
    controller.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future.delayed(Duration.zero); // async _onBecameInactive abschliessen lassen

    expect(controller.tirednessState.activeScreenTimeSeconds, greaterThanOrEqualTo(1));

    controller.dispose();
  });

  test('updateSettings persists changes and reflects them in tirednessState', () async {
    final controller = ScreenTimeController(
      screenTimeRepository: InMemoryScreenTimeRepository(),
      parentSettingsRepository: InMemoryParentSettingsRepository(),
    );

    await controller.start();
    await controller.updateSettings(
      const ParentSettings(tirednessThresholdMinutes: 10, isTirednessLimitEnabled: true),
    );

    expect(controller.settings.tirednessThresholdMinutes, 10);
    expect(controller.tirednessState.thresholdMinutes, 10);

    controller.dispose();
  });

  test('disabling the limit means tirednessState is never tired', () async {
    final controller = ScreenTimeController(
      screenTimeRepository: InMemoryScreenTimeRepository(),
      parentSettingsRepository: InMemoryParentSettingsRepository(),
    );

    await controller.start();
    await controller.updateSettings(
      const ParentSettings(tirednessThresholdMinutes: 10, isTirednessLimitEnabled: false),
    );

    expect(controller.tirednessState.isTired, isFalse);
    expect(controller.tirednessState.progress, 0.0);

    controller.dispose();
  });
}
