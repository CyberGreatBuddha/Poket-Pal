// Aufgaben-Format (resolved): Bild+Audio ist Standard, Text ist optional und
// nie verpflichtend -- passend zur Zielgruppe, die ueberwiegend noch nicht
// sicher lesen kann.
class TaskPrompt {
  final String imageAssetPath;
  final String audioAssetPath;
  final String? text;

  const TaskPrompt({
    required this.imageAssetPath,
    required this.audioAssetPath,
    this.text,
  });
}

// Eine antippbare Antwortoption.
class TaskOption {
  final String value;
  final String imageAssetPath;

  const TaskOption({required this.value, required this.imageAssetPath});
}

// Eine generierte Aufgabe. categoryKey/difficulty spiegeln SkillLevel.categoryKey
// bzw. TaskRecord.difficultyAtTime aus dem Persistenz-Schema (Kernsystem 4).
class Task {
  final String categoryKey;
  final int difficulty;
  final TaskPrompt prompt;
  final List<TaskOption> options;
  final String correctValue;

  const Task({
    required this.categoryKey,
    required this.difficulty,
    required this.prompt,
    required this.options,
    required this.correctValue,
  });
}
