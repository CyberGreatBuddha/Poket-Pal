import 'animal_vocabulary_task_generator.dart';
import 'categorization_task_generator.dart';
import 'color_recognition_task_generator.dart';
import 'content/animal_habitats.dart';
import 'content/floating_objects.dart';
import 'content/knowledge_categories.dart';
import 'instrument_recognition_task_generator.dart';
import 'math_task_generator.dart';
import 'task_generator.dart';

// Muss mit den in buildDefaultTaskGeneratorRegistry() registrierten Keys
// uebereinstimmen -- fuer UI-Code, der alle verfuegbaren Kategorien auflisten
// will, ohne eine Registry-Instanz nur dafuer aufzubauen.
const List<String> defaultCategoryKeys = [
  'math.pictogram',
  'math.comparison',
  'math.visual_addition',
  'math.abstract_numbers',
  'math.extended_range',
  'colors.recognition',
  'language.vocabulary_animals',
  'general_knowledge.categorization',
  'biology.animal_habitats',
  'physics.floats_or_sinks',
  'music.instrument_recognition',
];

// Zentrale Stelle, die alle aktuell implementierten Kategorien registriert --
// praktisch fuer die spaetere Presentation-/App-Wiring-Schicht, und
// dokumentiert nebenbei, was inhaltlich bereits existiert. Weitere
// Fachbereiche/Kategorien (siehe projektkonzept.md To-Do 1) ergaenzen sich
// hier, ohne bestehende Generatoren anzufassen.
TaskGeneratorRegistry buildDefaultTaskGeneratorRegistry() {
  return TaskGeneratorRegistry()
    // Mathematik (Kernsystem 2, alle 5 Stufen)
    ..register('math.pictogram', PictogramCountingTaskGenerator())
    ..register('math.comparison', QuantityComparisonTaskGenerator())
    ..register('math.visual_addition', VisualAdditionTaskGenerator())
    ..register('math.abstract_numbers', AbstractNumberTaskGenerator())
    ..register('math.extended_range', ExtendedRangeAdditionTaskGenerator())
    // Farben (Vorschulalter)
    ..register('colors.recognition', ColorRecognitionTaskGenerator())
    // Sprache
    ..register('language.vocabulary_animals', AnimalVocabularyTaskGenerator())
    // Allgemeinwissen
    ..register(
      'general_knowledge.categorization',
      CategorizationTaskGenerator(
        categories: knowledgeCategories,
        items: knowledgeItems,
        assetNamespace: 'general_knowledge',
      ),
    )
    // Biologie
    ..register(
      'biology.animal_habitats',
      CategorizationTaskGenerator(
        categories: animalHabitatCategories,
        items: animalHabitatItems,
        assetNamespace: 'biology',
      ),
    )
    // Physik
    ..register(
      'physics.floats_or_sinks',
      CategorizationTaskGenerator(
        categories: floatingCategories,
        items: floatingItems,
        assetNamespace: 'physics',
      ),
    )
    // Musik
    ..register('music.instrument_recognition', InstrumentRecognitionTaskGenerator());
}
