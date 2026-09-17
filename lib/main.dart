import 'package:flutter/material.dart';

import 'persistence/fakes/in_memory_pal_repository.dart';
import 'persistence/fakes/in_memory_parent_settings_repository.dart';
import 'persistence/fakes/in_memory_screen_time_repository.dart';
import 'persistence/fakes/in_memory_skill_level_repository.dart';
import 'persistence/fakes/in_memory_task_history_repository.dart';
import 'presentation/app.dart';

// Verwendet aktuell die In-Memory-Fakes statt ObjectBox, damit die App auch
// ohne Android-Emulator/Windows-Entwicklermodus (in Chrome/Windows-Desktop)
// entwickelt und angesehen werden kann. Sobald ein Emulator verfuegbar ist,
// werden hier stattdessen die ObjectBox-Repositories aus einer geoeffneten
// ObjectBox-Instanz eingesetzt (siehe persistence/config/object_box.dart).
void main() {
  runApp(
    PoketPalApp(
      palRepository: InMemoryPalRepository(),
      taskHistoryRepository: InMemoryTaskHistoryRepository(),
      skillLevelRepository: InMemorySkillLevelRepository(),
      parentSettingsRepository: InMemoryParentSettingsRepository(),
      screenTimeRepository: InMemoryScreenTimeRepository(),
    ),
  );
}
