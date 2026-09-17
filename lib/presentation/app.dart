import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/pal/pal_repository.dart';
import '../domain/settings/parent_settings_repository.dart';
import '../domain/task_engine/skill_level_repository.dart';
import '../domain/task_engine/task_history_repository.dart';
import '../domain/tiredness/screen_time_repository.dart';
import 'controllers/pal_controller.dart';
import 'controllers/screen_time_controller.dart';
import 'controllers/task_controller.dart';
import 'screens/home_screen.dart';

// Root-Widget: verdrahtet die uebergebenen Repository-Implementierungen mit
// den Controllern und stellt sie dem gesamten Widget-Baum per Provider zur
// Verfuegung. Kennt nur die Domain-Repository-Interfaces, nicht ob dahinter
// ObjectBox oder eine In-Memory-Fake steckt (siehe main.dart). Bewusst ohne
// ThemeData/Farbschema -- das wird separat entwickelt (Ausnahme: die
// Homescreen-Widgets nutzen lokal MeadowPalette, siehe Feature-Spec).
class PoketPalApp extends StatelessWidget {
  final PalRepository palRepository;
  final TaskHistoryRepository taskHistoryRepository;
  final SkillLevelRepository skillLevelRepository;
  final ParentSettingsRepository parentSettingsRepository;
  final ScreenTimeRepository screenTimeRepository;

  const PoketPalApp({
    super.key,
    required this.palRepository,
    required this.taskHistoryRepository,
    required this.skillLevelRepository,
    required this.parentSettingsRepository,
    required this.screenTimeRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PalController(palRepository: palRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskController(
            taskHistoryRepository: taskHistoryRepository,
            skillLevelRepository: skillLevelRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ScreenTimeController(
            screenTimeRepository: screenTimeRepository,
            parentSettingsRepository: parentSettingsRepository,
          )..start(),
        ),
      ],
      child: MaterialApp(
        title: 'PoketPal',
        home: const HomeScreen(),
      ),
    );
  }
}
