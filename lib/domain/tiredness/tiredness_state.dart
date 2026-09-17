import 'tiredness_balancing.dart';

// Abgeleiteter, rein visueller Zustand aus ScreenTimeState + ParentSettings.
// Bewusst unabhaengig von PalStats.energy/TimeDeltaEngine (Muedigkeits-
// Mechanik hat nichts mit Lernfortschritt oder der Leniency-/Verfall-Logik
// bei mehrtaegiger Abwesenheit zu tun).
class TirednessState {
  final int activeScreenTimeSeconds;
  final int thresholdMinutes;
  final bool isLimitEnabled;

  const TirednessState({
    required this.activeScreenTimeSeconds,
    required this.thresholdMinutes,
    required this.isLimitEnabled,
  });

  // 0.0 (frisch) .. 1.0 (Schwelle erreicht), linear ueber die aktive Zeit.
  double get progress {
    if (!isLimitEnabled) return 0.0;
    final thresholdSeconds = thresholdMinutes * 60;
    if (thresholdSeconds <= 0) return 1.0;
    return (activeScreenTimeSeconds / thresholdSeconds).clamp(0.0, 1.0);
  }

  bool get isTired => progress >= 1.0;

  // Fuer den Energie-Badge auf dem Homescreen (Kernsystem-Erweiterung):
  // faellt linear von startEnergyRatio auf tiredEnergyRatio.
  double get displayEnergyRatio {
    const start = TirednessBalancing.startEnergyRatio;
    const tired = TirednessBalancing.tiredEnergyRatio;
    return start - (start - tired) * progress;
  }
}
