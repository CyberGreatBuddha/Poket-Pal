import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/tiredness/tiredness_balancing.dart';
import 'package:poketpal/persistence/fakes/in_memory_pal_repository.dart';
import 'package:poketpal/persistence/fakes/in_memory_parent_settings_repository.dart';
import 'package:poketpal/persistence/fakes/in_memory_screen_time_repository.dart';
import 'package:poketpal/persistence/fakes/in_memory_skill_level_repository.dart';
import 'package:poketpal/persistence/fakes/in_memory_sprite_asset_repository.dart';
import 'package:poketpal/persistence/fakes/in_memory_task_history_repository.dart';
import 'package:poketpal/presentation/app.dart';

import 'support/fake_image_segmenter.dart';

// End-to-End-Verdrahtungstest: Controller + In-Memory-Fakes + Screens
// zusammen. Bewusst ohne Annahmen ueber konkrete Zufallswerte (Aufgaben
// werden zufaellig generiert) -- prueft nur, dass die Kette
// Repository -> Controller -> UI tatsaechlich funktioniert.
void main() {
  Widget buildApp() {
    return PoketPalApp(
      palRepository: InMemoryPalRepository(),
      taskHistoryRepository: InMemoryTaskHistoryRepository(),
      skillLevelRepository: InMemorySkillLevelRepository(),
      parentSettingsRepository: InMemoryParentSettingsRepository(),
      screenTimeRepository: InMemoryScreenTimeRepository(),
      spriteAssetRepository: InMemorySpriteAssetRepository(),
      imageSegmenter: FakeImageSegmenter(encodedTestForegroundImage),
    );
  }

  testWidgets('shows full hunger/mood and fresh tiredness-energy on first launch', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // Hunger + Laune bei 100%, Energie zeigt den frischen Muedigkeits-Wert
    // (TirednessBalancing.startEnergyRatio), nicht PalStats.energy.
    expect(find.text('100%'), findsNWidgets(2));
    final freshEnergyPercent = (TirednessBalancing.startEnergyRatio * 100).round();
    expect(find.text('$freshEnergyPercent%'), findsOneWidget);
  });

  testWidgets('Spielen-Button oeffnet die Kategorie-Auswahl und laedt eine Aufgabe', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Spielen'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('math.pictogram').first);
    await tester.pumpAndSettle();

    final optionButtons = find.byType(ElevatedButton);
    expect(optionButtons, findsWidgets);

    await tester.tap(optionButtons.first);
    await tester.pump();

    final foundCorrect = find.textContaining('Richtig').evaluate().isNotEmpty;
    final foundWrong = find.textContaining('Leider falsch').evaluate().isNotEmpty;
    expect(foundCorrect || foundWrong, isTrue);

    // TaskScreen zeigt das Feedback 1s an und laedt danach die naechste
    // Aufgabe -- den Timer hier auslaufen lassen, sonst bleibt er beim
    // Testende haengen.
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });

  testWidgets('Elternmenue zeigt die Bildschirmzeit-Einstellungen', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Bildschirmzeit'), findsOneWidget);
    expect(find.text('Müdigkeits-Limit aktiv'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('Minuten bis Pal müde wird: 25'), findsOneWidget);
  });
}
