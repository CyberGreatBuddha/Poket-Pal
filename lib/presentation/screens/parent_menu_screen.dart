import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/tiredness/tiredness_balancing.dart';
import '../controllers/screen_time_controller.dart';

// Elternmenue, Abschnitt "Bildschirmzeit" (Feature-Spec Abschnitt 3).
// Bewusst ohne PIN-/Lock-Schutz -- der existiert im Projekt noch nicht und
// kommt bei Bedarf als eigene Aufgabe.
class ParentMenuScreen extends StatelessWidget {
  const ParentMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ScreenTimeController>();
    final settings = controller.settings;
    final divisions = (TirednessBalancing.maxThresholdMinutes -
            TirednessBalancing.minThresholdMinutes) ~/
        TirednessBalancing.thresholdStepMinutes;

    return Scaffold(
      appBar: AppBar(title: const Text('Elternmenü')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Bildschirmzeit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Müdigkeits-Limit aktiv'),
            value: settings.isTirednessLimitEnabled,
            onChanged: (value) => controller.updateSettings(
              settings.copyWith(isTirednessLimitEnabled: value),
            ),
          ),
          const SizedBox(height: 8),
          Text('Minuten bis Pal müde wird: ${settings.tirednessThresholdMinutes}'),
          Slider(
            value: settings.tirednessThresholdMinutes.toDouble(),
            min: TirednessBalancing.minThresholdMinutes.toDouble(),
            max: TirednessBalancing.maxThresholdMinutes.toDouble(),
            divisions: divisions,
            label: '${settings.tirednessThresholdMinutes} min',
            onChanged: settings.isTirednessLimitEnabled
                ? (value) => controller.updateSettings(
                      settings.copyWith(tirednessThresholdMinutes: value.round()),
                    )
                : null,
          ),
          const SizedBox(height: 8),
          const Text(
            'Zähler setzt sich jeden Kalendertag zurück',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
