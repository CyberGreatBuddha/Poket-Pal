import 'dart:math';

import 'content/musical_instruments.dart';
import 'task.dart';
import 'task_generator.dart';

// Fachbereich Musik (Vorschulalter): das Kind hoert einen Instrumentenklang
// und tippt auf das passende Instrument-Bild. categoryKey: music.instrument_recognition.
//
// Beantwortet die im Konzept offene Frage "passt Musik ins bestehende
// Bild+Audio-Format?" (Kernsystem 2): ja, ohne Format-Erweiterung -- das
// Audiofeld traegt hier den zu erkennenden Klang selbst statt einer
// Sprachanweisung. Kein struktureller Unterschied zu den anderen Kategorien.
class InstrumentRecognitionTaskGenerator implements TaskGenerator {
  static const int _minOptions = 2;
  static const int _maxOptions = 4;

  final Random _random;

  InstrumentRecognitionTaskGenerator({Random? random}) : _random = random ?? Random();

  @override
  Task generate({required String categoryKey, required int level}) {
    final optionCount = min(_maxOptions, _minOptions + level - 1);

    final shuffled = List.of(musicalInstruments)..shuffle(_random);
    final chosen = shuffled.take(optionCount).toList();
    final target = chosen[_random.nextInt(chosen.length)];

    return Task(
      categoryKey: categoryKey,
      difficulty: level,
      prompt: TaskPrompt(
        imageAssetPath: 'assets/images/music/prompt_ear.png',
        audioAssetPath: 'assets/audio/music/instruments/${target.key}_sound.mp3',
      ),
      options: chosen
          .map((instrument) => TaskOption(
                value: instrument.key,
                imageAssetPath: 'assets/images/music/instruments/${instrument.key}.png',
              ))
          .toList(),
      correctValue: target.key,
    );
  }
}
