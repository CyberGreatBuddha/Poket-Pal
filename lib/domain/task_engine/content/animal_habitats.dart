import 'categorized_items.dart';

// Biologie-Einstieg (Vorschulalter): Tiere nach Lebensraum sortieren --
// rein visuell erkennbar, kein Vorwissen ueber Klassifikation noetig.
// Platzhalter-Auswahl, im Playtesting/Content-Review anzupassen.
const List<CategoryDefinition> animalHabitatCategories = [
  CategoryDefinition(key: 'water', questionPrompt: 'Welches Tier lebt im Wasser?'),
  CategoryDefinition(key: 'land', questionPrompt: 'Welches Tier lebt an Land?'),
  CategoryDefinition(key: 'air', questionPrompt: 'Welches Tier lebt in der Luft?'),
];

const List<CategorizedItem> animalHabitatItems = [
  // Wasser
  CategorizedItem(key: 'fish', germanName: 'Fisch', categoryKey: 'water'),
  CategorizedItem(key: 'whale', germanName: 'Wal', categoryKey: 'water'),
  CategorizedItem(key: 'octopus', germanName: 'Oktopus', categoryKey: 'water'),
  CategorizedItem(key: 'crab', germanName: 'Krebs', categoryKey: 'water'),
  // Land
  CategorizedItem(key: 'lion', germanName: 'Löwe', categoryKey: 'land'),
  CategorizedItem(key: 'elephant', germanName: 'Elefant', categoryKey: 'land'),
  CategorizedItem(key: 'rabbit', germanName: 'Hase', categoryKey: 'land'),
  CategorizedItem(key: 'horse', germanName: 'Pferd', categoryKey: 'land'),
  // Luft
  CategorizedItem(key: 'eagle', germanName: 'Adler', categoryKey: 'air'),
  CategorizedItem(key: 'butterfly', germanName: 'Schmetterling', categoryKey: 'air'),
  CategorizedItem(key: 'bee', germanName: 'Biene', categoryKey: 'air'),
  CategorizedItem(key: 'owl', germanName: 'Eule', categoryKey: 'air'),
];
