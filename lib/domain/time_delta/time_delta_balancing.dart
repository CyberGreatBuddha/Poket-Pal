// Balancing-Config fuer die Time-Delta Engine (Kernsystem 1), bewusst als
// eigenstaendige, leicht anpassbare Konstanten statt hart in der Engine-Logik
// verdrahtet -- analog zur DifficultyBalancing-Philosophie im Task Engine.
// Decay-Raten sind Platzhalter-Annahmen und sollten im Playtesting validiert werden.
class TimeDeltaBalancing {
  // Leniency-Policy (resolved): Werte fallen nie unter diesen Boden.
  static const double statFloor = 0.2;

  // Leniency-Policy (resolved): nach dieser Abwesenheit -> Freeze-/Maintenance-Modus.
  static const Duration freezeThreshold = Duration(days: 3);

  // Placeholder-Decay-Raten: volle Fuellung (1.0) faellt in dieser Stundenzahl auf den Floor.
  static const double hungerDecayPerHour = (1.0 - statFloor) / 20;
  static const double moodDecayPerHour = (1.0 - statFloor) / 30;
  static const double energyDecayPerHour = (1.0 - statFloor) / 24;
}
