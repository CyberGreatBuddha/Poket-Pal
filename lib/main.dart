import 'package:flutter/material.dart';

import 'persistence/config/object_box.dart';
import 'presentation/app.dart';

// Oeffnet den echten ObjectBox-Store und verdrahtet dessen Repositories in
// die App. Fuer Entwicklung ohne Geraet (Chrome/Windows-Desktop) siehe die
// In-Memory-Fakes unter persistence/fakes/ -- die wurden hier bewusst durch
// die echte Persistenz ersetzt, jetzt wo ein Android-Emulator verfuegbar ist.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final objectBox = await ObjectBox.create();

  runApp(
    PoketPalApp(
      palRepository: objectBox.palRepository,
      taskHistoryRepository: objectBox.taskHistoryRepository,
      skillLevelRepository: objectBox.skillLevelRepository,
      parentSettingsRepository: objectBox.parentSettingsRepository,
      screenTimeRepository: objectBox.screenTimeRepository,
    ),
  );
}
