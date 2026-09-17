import 'dart:math';

import 'task.dart';
import 'task_generator.dart';

// Stufe 1 der Mathe-Progression (Kernsystem 2): "Wie viele Aepfel?" --
// rein visuelles Zaehlen, 1-5, kein Rechnen. categoryKey: math.pictogram.
class PictogramCountingTaskGenerator implements TaskGenerator {
  static const int _minCount = 1;
  static const int _maxCount = 5;

  final Random _random;

  PictogramCountingTaskGenerator({Random? random}) : _random = random ?? Random();

  @override
  Task generate({required String categoryKey, required int level}) {
    // Hoehere Level zaehlen bis zu einer groesseren Menge innerhalb des 1-5-Bereichs.
    final upperBound = min(_maxCount, _minCount + 1 + level);
    final correctCount = _minCount + _random.nextInt(upperBound - _minCount + 1);

    final distractorCounts = _distractorsAround(correctCount, upperBound);

    return Task(
      categoryKey: categoryKey,
      difficulty: level,
      prompt: TaskPrompt(
        imageAssetPath: 'assets/images/math/pictogram/apples_$correctCount.png',
        audioAssetPath: 'assets/audio/math/pictogram/how_many_apples.mp3',
        text: 'Wie viele Äpfel?',
      ),
      options: [correctCount, ...distractorCounts]
          .map((count) => TaskOption(
                value: count.toString(),
                imageAssetPath: 'assets/images/math/numerals/$count.png',
              ))
          .toList()
        ..shuffle(_random),
      correctValue: correctCount.toString(),
    );
  }

  List<int> _distractorsAround(int correctCount, int upperBound) {
    final candidates = {
      for (var count = _minCount; count <= upperBound; count++) count,
    }..remove(correctCount);
    final distractors = candidates.toList()..shuffle(_random);
    return distractors.take(2).toList();
  }
}

// Stufe 2 der Mathe-Progression (Kernsystem 2): "Welcher Haufen hat mehr?" --
// visueller Mengenvergleich, kein Rechnen. categoryKey: math.comparison.
class QuantityComparisonTaskGenerator implements TaskGenerator {
  static const int _minCount = 1;
  static const int _maxCount = 5;

  final Random _random;

  QuantityComparisonTaskGenerator({Random? random}) : _random = random ?? Random();

  @override
  Task generate({required String categoryKey, required int level}) {
    final upperBound = min(_maxCount, _minCount + 1 + level);
    final leftCount = _minCount + _random.nextInt(upperBound - _minCount + 1);
    var rightCount = _minCount + _random.nextInt(upperBound - _minCount + 1);
    while (rightCount == leftCount) {
      rightCount = _minCount + _random.nextInt(upperBound - _minCount + 1);
    }

    final correctSide = leftCount > rightCount ? 'left' : 'right';

    return Task(
      categoryKey: categoryKey,
      difficulty: level,
      prompt: TaskPrompt(
        imageAssetPath: 'assets/images/math/comparison/piles_${leftCount}_v_$rightCount.png',
        audioAssetPath: 'assets/audio/math/comparison/which_has_more.mp3',
        text: 'Welcher Haufen hat mehr?',
      ),
      options: [
        TaskOption(
          value: 'left',
          imageAssetPath: 'assets/images/math/comparison/pile_$leftCount.png',
        ),
        TaskOption(
          value: 'right',
          imageAssetPath: 'assets/images/math/comparison/pile_$rightCount.png',
        ),
      ],
      correctValue: correctSide,
    );
  }
}

// Stufe 3 der Mathe-Progression (Kernsystem 2): "Symbole kombinieren,
// Ergebnis antippen" -- visuelle Addition zweier Gruppen, noch mit Bildhilfe.
// categoryKey: math.visual_addition.
class VisualAdditionTaskGenerator implements TaskGenerator {
  static const int _minAddend = 1;
  static const int _maxAddend = 5;

  final Random _random;

  VisualAdditionTaskGenerator({Random? random}) : _random = random ?? Random();

  @override
  Task generate({required String categoryKey, required int level}) {
    final addendUpperBound = min(_maxAddend, _minAddend + 1 + level);
    final addendA = _minAddend + _random.nextInt(addendUpperBound - _minAddend + 1);
    final addendB = _minAddend + _random.nextInt(addendUpperBound - _minAddend + 1);
    final sum = addendA + addendB;

    final distractors = _distractorsNear(sum, [-2, -1, 1, 2]);

    return Task(
      categoryKey: categoryKey,
      difficulty: level,
      prompt: TaskPrompt(
        imageAssetPath: 'assets/images/math/visual_addition/apples_${addendA}_plus_$addendB.png',
        audioAssetPath: 'assets/audio/math/visual_addition/how_many_together.mp3',
        text: 'Wie viele sind es zusammen?',
      ),
      options: [sum, ...distractors]
          .map((count) => TaskOption(
                value: count.toString(),
                imageAssetPath: 'assets/images/math/numerals/$count.png',
              ))
          .toList()
        ..shuffle(_random),
      correctValue: sum.toString(),
    );
  }

  List<int> _distractorsNear(int target, List<int> offsets) {
    final candidates = <int>{};
    for (final offset in offsets) {
      final candidate = target + offset;
      if (candidate >= 0) candidates.add(candidate);
    }
    candidates.remove(target);
    final distractors = candidates.toList()..shuffle(_random);
    return distractors.take(2).toList();
  }
}

// Stufe 4 der Mathe-Progression (Kernsystem 2): "erste Ziffern-basierte
// Aufgaben ohne Bildhilfe" -- Audio nennt eine Zahl, das Kind tippt auf die
// passende Ziffer unter Distraktor-Ziffern. Keine Objektbilder mehr, nur noch
// Ziffern-Glyphen als visuelle Antwortoptionen. categoryKey: math.abstract_numbers.
class AbstractNumberTaskGenerator implements TaskGenerator {
  static const int _minNumber = 1;
  static const int _maxNumber = 20;

  final Random _random;

  AbstractNumberTaskGenerator({Random? random}) : _random = random ?? Random();

  @override
  Task generate({required String categoryKey, required int level}) {
    // Waechst schneller als die rein visuellen Stufen, um Richtung
    // Grundschul-Zahlenraum zu skalieren (siehe projektkonzept.md To-Do 1).
    final upperBound = min(_maxNumber, 4 + level * 2);
    final target = _minNumber + _random.nextInt(upperBound - _minNumber + 1);

    final candidates = {
      for (var n = _minNumber; n <= upperBound; n++) n,
    }..remove(target);
    final distractors = candidates.toList()..shuffle(_random);

    return Task(
      categoryKey: categoryKey,
      difficulty: level,
      prompt: TaskPrompt(
        imageAssetPath: 'assets/images/math/abstract_numbers/prompt_ear.png',
        audioAssetPath: 'assets/audio/math/numbers/$target.mp3',
      ),
      options: [target, ...distractors.take(2)]
          .map((n) => TaskOption(
                value: n.toString(),
                imageAssetPath: 'assets/images/math/numerals/$n.png',
              ))
          .toList()
        ..shuffle(_random),
      correctValue: target.toString(),
    );
  }
}

// Stufe 5 der Mathe-Progression (Kernsystem 2): "erweiterter Zahlenraum, je
// nach Fortschritt" -- abstrakte Addition ohne Bildhilfe, mit deutlich
// groesserem Zahlenraum als Stufe 3 (visuelle Addition). Baut auf Stufe 4
// (Ziffern-Erkennung) auf. categoryKey: math.extended_range.
class ExtendedRangeAdditionTaskGenerator implements TaskGenerator {
  static const int _minAddend = 1;
  static const int _maxAddend = 20;

  final Random _random;

  ExtendedRangeAdditionTaskGenerator({Random? random}) : _random = random ?? Random();

  @override
  Task generate({required String categoryKey, required int level}) {
    final addendUpperBound = min(_maxAddend, 4 + level * 3);
    final addendA = _minAddend + _random.nextInt(addendUpperBound - _minAddend + 1);
    final addendB = _minAddend + _random.nextInt(addendUpperBound - _minAddend + 1);
    final sum = addendA + addendB;

    final distractors = _distractorsNear(sum, [-3, -2, -1, 1, 2, 3]);

    return Task(
      categoryKey: categoryKey,
      difficulty: level,
      prompt: TaskPrompt(
        imageAssetPath: 'assets/images/math/extended_range/equation_${addendA}_plus_$addendB.png',
        audioAssetPath: 'assets/audio/math/extended_range/what_is_the_sum.mp3',
        text: '$addendA + $addendB = ?',
      ),
      options: [sum, ...distractors]
          .map((count) => TaskOption(
                value: count.toString(),
                imageAssetPath: 'assets/images/math/numerals/$count.png',
              ))
          .toList()
        ..shuffle(_random),
      correctValue: sum.toString(),
    );
  }

  List<int> _distractorsNear(int target, List<int> offsets) {
    final candidates = <int>{};
    for (final offset in offsets) {
      final candidate = target + offset;
      if (candidate >= 0) candidates.add(candidate);
    }
    candidates.remove(target);
    final distractors = candidates.toList()..shuffle(_random);
    return distractors.take(2).toList();
  }
}
