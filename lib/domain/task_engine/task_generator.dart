import 'task.dart';

// Fachbereiche jenseits von Mathematik sind inhaltlich noch offen (siehe
// projektkonzept.md, To-Do 1) -- dieses Interface haelt die Engine generisch
// ueber beliebig viele Fachbereiche, ohne deren Inhalte vorwegzunehmen.
abstract class TaskGenerator {
  Task generate({required String categoryKey, required int level});
}

// Ordnet jede vollstaendige categoryKey (z. B. "math.pictogram") ihrem eigenen
// Generator zu -- ein Fachbereich (Praefix vor dem Punkt) kann mehrere
// Kategorien mit jeweils eigener Erzeugungslogik haben (z. B. "math.pictogram"
// und "math.comparison"), daher wird nicht nach dem Praefix, sondern nach der
// vollen categoryKey dispatcht. Neue Kategorien/Fachbereiche lassen sich
// ergaenzen, ohne bestehende Generatoren oder die Task Engine anzufassen.
class TaskGeneratorRegistry {
  final Map<String, TaskGenerator> _generatorsByCategoryKey = {};

  void register(String categoryKey, TaskGenerator generator) {
    _generatorsByCategoryKey[categoryKey] = generator;
  }

  Task generate({required String categoryKey, required int level}) {
    final generator = _generatorsByCategoryKey[categoryKey];
    if (generator == null) {
      throw StateError('Kein TaskGenerator fuer categoryKey "$categoryKey" registriert.');
    }
    return generator.generate(categoryKey: categoryKey, level: level);
  }
}
