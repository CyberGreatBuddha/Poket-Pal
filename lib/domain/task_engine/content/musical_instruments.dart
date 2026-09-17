class InstrumentEntry {
  final String key;
  final String germanName;

  const InstrumentEntry({required this.key, required this.germanName});
}

// Musik-Einstieg (Vorschulalter): Instrumente am Klang erkennen.
// Platzhalter-Auswahl, im Playtesting/Content-Review anzupassen.
const List<InstrumentEntry> musicalInstruments = [
  InstrumentEntry(key: 'drum', germanName: 'Trommel'),
  InstrumentEntry(key: 'piano', germanName: 'Klavier'),
  InstrumentEntry(key: 'guitar', germanName: 'Gitarre'),
  InstrumentEntry(key: 'trumpet', germanName: 'Trompete'),
  InstrumentEntry(key: 'violin', germanName: 'Geige'),
  InstrumentEntry(key: 'flute', germanName: 'Flöte'),
];
