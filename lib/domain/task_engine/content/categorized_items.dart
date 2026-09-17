// Wiederverwendbare Datenform fuer die "Tippe das passende Item zur genannten
// Kategorie"-Mechanik (CategorizationTaskGenerator). Genutzt von mehreren
// Fachbereichen (Allgemeinwissen, Biologie, Physik), die inhaltlich nichts
// miteinander zu tun haben, aber strukturell identisch funktionieren.
class CategoryDefinition {
  final String key;

  // Vollstaendige, grammatikalisch korrekte Frage fuer diese Kategorie,
  // z. B. "Welches ist Obst?" oder "Welches Tier lebt im Wasser?" --
  // bewusst nicht aus einem generischen Template zusammengesetzt, da sich
  // die Satzstruktur je nach Fachbereich unterscheidet.
  final String questionPrompt;

  const CategoryDefinition({required this.key, required this.questionPrompt});
}

class CategorizedItem {
  final String key;
  final String germanName;
  final String categoryKey;

  const CategorizedItem({
    required this.key,
    required this.germanName,
    required this.categoryKey,
  });
}
