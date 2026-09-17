import 'categorized_items.dart';

// Allgemeinwissen: einfache Kategorisierung rein visuell erkennbarer
// Alltagsgegenstaende, kein Lesen noetig. Platzhalter-Auswahl, im
// Playtesting/Content-Review anzupassen.
const List<CategoryDefinition> knowledgeCategories = [
  CategoryDefinition(key: 'fruit', questionPrompt: 'Welches ist Obst?'),
  CategoryDefinition(key: 'vehicle', questionPrompt: 'Welches ist ein Fahrzeug?'),
  CategoryDefinition(key: 'clothing', questionPrompt: 'Welches ist ein Kleidungsstück?'),
];

const List<CategorizedItem> knowledgeItems = [
  // Obst
  CategorizedItem(key: 'apple', germanName: 'Apfel', categoryKey: 'fruit'),
  CategorizedItem(key: 'banana', germanName: 'Banane', categoryKey: 'fruit'),
  CategorizedItem(key: 'strawberry', germanName: 'Erdbeere', categoryKey: 'fruit'),
  CategorizedItem(key: 'pear', germanName: 'Birne', categoryKey: 'fruit'),
  // Fahrzeuge
  CategorizedItem(key: 'car', germanName: 'Auto', categoryKey: 'vehicle'),
  CategorizedItem(key: 'bicycle', germanName: 'Fahrrad', categoryKey: 'vehicle'),
  CategorizedItem(key: 'boat', germanName: 'Boot', categoryKey: 'vehicle'),
  CategorizedItem(key: 'airplane', germanName: 'Flugzeug', categoryKey: 'vehicle'),
  // Kleidung
  CategorizedItem(key: 'pants', germanName: 'Hose', categoryKey: 'clothing'),
  CategorizedItem(key: 'shoe', germanName: 'Schuh', categoryKey: 'clothing'),
  CategorizedItem(key: 'hat', germanName: 'Mütze', categoryKey: 'clothing'),
  CategorizedItem(key: 'jacket', germanName: 'Jacke', categoryKey: 'clothing'),
];
