// Balancing-Config fuer die Muedigkeits-Mechanik, bewusst getrennt von der
// Logik -- analog zu TimeDeltaBalancing/DifficultyBalancing. Platzhalter-
// Werte, im Playtesting anzupassen.
class TirednessBalancing {
  static const int defaultThresholdMinutes = 25;
  static const int minThresholdMinutes = 10;
  static const int maxThresholdMinutes = 60;
  static const int thresholdStepMinutes = 5;

  // Energie-Anzeige (Kernsystem-Erweiterung): startet frisch bei ~95%,
  // faellt linear auf ~20% bei Erreichen der Schwelle.
  static const double startEnergyRatio = 0.95;
  static const double tiredEnergyRatio = 0.2;

  // Sicherheits-Speicherintervall waehrend einer langen aktiven Session,
  // falls die App ohne sauberes Pause-Event beendet wird.
  static const Duration safetySaveInterval = Duration(seconds: 30);
}
