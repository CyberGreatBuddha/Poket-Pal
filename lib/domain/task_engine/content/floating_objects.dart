import 'categorized_items.dart';

// Physik-Einstieg (Vorschulalter): "Schwimmt es oder sinkt es?" -- ein
// klassisches, intuitiv nachvollziehbares Konzept ohne Vorwissen ueber Dichte
// o.ae. Platzhalter-Auswahl, im Playtesting/Content-Review anzupassen.
const List<CategoryDefinition> floatingCategories = [
  CategoryDefinition(key: 'floats', questionPrompt: 'Welches schwimmt?'),
  CategoryDefinition(key: 'sinks', questionPrompt: 'Welches sinkt?'),
];

const List<CategorizedItem> floatingItems = [
  // Schwimmt
  CategorizedItem(key: 'boat', germanName: 'Boot', categoryKey: 'floats'),
  CategorizedItem(key: 'wood', germanName: 'Holzklotz', categoryKey: 'floats'),
  CategorizedItem(key: 'apple', germanName: 'Apfel', categoryKey: 'floats'),
  CategorizedItem(key: 'ball', germanName: 'Ball', categoryKey: 'floats'),
  // Sinkt
  CategorizedItem(key: 'stone', germanName: 'Stein', categoryKey: 'sinks'),
  CategorizedItem(key: 'spoon', germanName: 'Löffel', categoryKey: 'sinks'),
  CategorizedItem(key: 'coin', germanName: 'Münze', categoryKey: 'sinks'),
  CategorizedItem(key: 'nail', germanName: 'Nagel', categoryKey: 'sinks'),
];
