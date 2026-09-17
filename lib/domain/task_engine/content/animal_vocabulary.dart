class VocabularyEntry {
  final String key;
  final String germanName;

  const VocabularyEntry({required this.key, required this.germanName});
}

// Erstes Wortschatz-Set fuer den Fachbereich Sprache (Vokabular, Tiere).
// Platzhalter-Auswahl, im Playtesting/Content-Review anzupassen.
const List<VocabularyEntry> animalVocabulary = [
  VocabularyEntry(key: 'dog', germanName: 'Hund'),
  VocabularyEntry(key: 'cat', germanName: 'Katze'),
  VocabularyEntry(key: 'bird', germanName: 'Vogel'),
  VocabularyEntry(key: 'fish', germanName: 'Fisch'),
  VocabularyEntry(key: 'horse', germanName: 'Pferd'),
  VocabularyEntry(key: 'cow', germanName: 'Kuh'),
  VocabularyEntry(key: 'pig', germanName: 'Schwein'),
  VocabularyEntry(key: 'duck', germanName: 'Ente'),
  VocabularyEntry(key: 'rabbit', germanName: 'Hase'),
  VocabularyEntry(key: 'bear', germanName: 'Bär'),
];
