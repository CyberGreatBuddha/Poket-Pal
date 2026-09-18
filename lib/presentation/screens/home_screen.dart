import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/pal_controller.dart';
import '../controllers/screen_time_controller.dart';
import '../widgets/homescreen_background.dart';
import '../widgets/inventory_button.dart';
import '../widgets/pal_background_meadow.dart';
import '../widgets/pal_widget.dart';
import '../widgets/play_button.dart';
import '../widgets/stat_bar.dart';
import 'category_picker_screen.dart';
import 'character_ingestion_screen.dart';
import 'parent_menu_screen.dart';

// Homescreen "Warme Wiese" (Zwischenloesung, Feature-Spec Abschnitt 1). Die
// Hintergrund-Ebene ist bewusst nur ueber den HomescreenBackground-Typ
// referenziert -- ein Szenenwechsel (z. B. PalBackgroundFarm) betrifft nur
// die eine Zeile, in der die Instanz erzeugt wird.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const HomescreenBackground _background = PalBackgroundMeadow();

  @override
  Widget build(BuildContext context) {
    final palController = context.watch<PalController>();
    final screenTimeController = context.watch<ScreenTimeController>();
    final pal = palController.pal;
    final tiredness = screenTimeController.tirednessState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PoketPal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Elternmenü',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ParentMenuScreen()),
            ),
          ),
        ],
      ),
      body: palController.isLoading || pal == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                _background,
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        StatBar(
                          hunger: pal.stats.hunger,
                          mood: pal.stats.mood,
                          energy: tiredness.displayEnergyRatio,
                        ),
                        if (palController.reEntryPlan != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextButton(
                              onPressed: palController.acknowledgeReEntry,
                              child: Text(
                                'Willkommen zurück! Los geht\'s mit '
                                '${palController.reEntryPlan!.easyTaskCount} leichten Aufgaben.',
                              ),
                            ),
                          ),
                        const Spacer(),
                        Center(
                          child: PalWidget(
                            isTired: tiredness.isTired,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CharacterIngestionScreen(palId: pal.id),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: InventoryButton(),
                        ),
                        const SizedBox(height: 8),
                        PlayButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CategoryPickerScreen(palId: pal.id),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
