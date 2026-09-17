import 'time_delta_balancing.dart';

// Werte-Objekt fuer die drei Pal-Stats. Persistenzunabhaengig (siehe Pal-Entity
// fuer das ObjectBox-Pendant) -- der Domain Core rechnet ausschliesslich hiermit.
class PalStats {
  final double hunger;
  final double mood;
  final double energy;

  const PalStats({
    required this.hunger,
    required this.mood,
    required this.energy,
  });

  factory PalStats.full() => const PalStats(hunger: 1.0, mood: 1.0, energy: 1.0);

  factory PalStats.atFloor() => const PalStats(
        hunger: TimeDeltaBalancing.statFloor,
        mood: TimeDeltaBalancing.statFloor,
        energy: TimeDeltaBalancing.statFloor,
      );

  PalStats boosted(double amount) => PalStats(
        hunger: _clamp(hunger + amount),
        mood: _clamp(mood + amount),
        energy: _clamp(energy + amount),
      );

  static double _clamp(double value) =>
      value.clamp(TimeDeltaBalancing.statFloor, 1.0);
}
