class ColorEntry {
  final String key; // stabiler Bezeichner fuer Asset-Pfade und correctValue
  final String germanName;

  const ColorEntry({required this.key, required this.germanName});
}

// Grundfarben-Set, wie es im Vorschulalter (4-6 Jahre) ueblicherweise zuerst
// vermittelt wird. Platzhalter-Auswahl, im Playtesting/Content-Review anzupassen.
const List<ColorEntry> basicColorPalette = [
  ColorEntry(key: 'red', germanName: 'Rot'),
  ColorEntry(key: 'blue', germanName: 'Blau'),
  ColorEntry(key: 'yellow', germanName: 'Gelb'),
  ColorEntry(key: 'green', germanName: 'Grün'),
  ColorEntry(key: 'orange', germanName: 'Orange'),
  ColorEntry(key: 'purple', germanName: 'Lila'),
  ColorEntry(key: 'pink', germanName: 'Rosa'),
  ColorEntry(key: 'brown', germanName: 'Braun'),
];
