import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/task_engine/task_response.dart';
import '../controllers/pal_controller.dart';
import '../controllers/task_controller.dart';

// Bewusst ungestylter Platzhalter-Screen (Standard-Material-Widgets, kein
// Theming) -- das visuelle Design wird separat entwickelt. Zeigt Optionswerte
// als Text-Buttons an, da noch keine Bild-/Audio-Assets existieren.
class TaskScreen extends StatefulWidget {
  final int palId;
  final String categoryKey;

  const TaskScreen({super.key, required this.palId, required this.categoryKey});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String? _feedback;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTask());
  }

  Future<void> _loadTask() async {
    await context.read<TaskController>().loadNextTask(
          palId: widget.palId,
          categoryKey: widget.categoryKey,
        );
  }

  Future<void> _submit(String value) async {
    final taskController = context.read<TaskController>();
    final palController = context.read<PalController>();

    final TaskResponse response = await taskController.submitAnswer(
      palId: widget.palId,
      categoryKey: widget.categoryKey,
      selectedValue: value,
    );

    await palController.applyTaskResult(response);

    if (!mounted) return;
    setState(() {
      _feedback = response.wasCorrect
          ? 'Richtig!${taskController.didLevelUp ? ' Level Up!' : ''}'
          : 'Leider falsch.';
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _feedback = null);
    await _loadTask();
  }

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final task = taskController.currentTask;

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryKey)),
      body: Center(
        child: taskController.isLoading || task == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(task.prompt.text ?? 'Aufgabe', style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text('Level ${task.difficulty}'),
                  const SizedBox(height: 24),
                  if (_feedback != null)
                    Text(_feedback!, style: const TextStyle(fontSize: 20))
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: task.options
                          .map(
                            (option) => ElevatedButton(
                              onPressed: () => _submit(option.value),
                              child: Text(option.value),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
      ),
    );
  }
}
