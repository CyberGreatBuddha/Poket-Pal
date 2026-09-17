import 'package:flutter/material.dart';

import '../../domain/task_engine/default_task_generator_registry.dart';
import 'task_screen.dart';

// Vom Homescreen ausgelagert (Feature-Spec "Warme Wiese" ersetzt die
// Kategorie-Liste dort durch den PlayButton). Bewusst weiterhin ungestylt --
// Design steht fuer diesen Screen noch aus.
class CategoryPickerScreen extends StatelessWidget {
  final int palId;

  const CategoryPickerScreen({super.key, required this.palId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aufgabe wählen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: defaultCategoryKeys
            .map(
              (categoryKey) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TaskScreen(palId: palId, categoryKey: categoryKey),
                    ),
                  ),
                  child: Text(categoryKey),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
