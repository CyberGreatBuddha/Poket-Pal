import 'package:flutter/material.dart';

import '../theme/meadow_palette.dart';

// 3 Stat-Badges auf teiltransparenter Karte (Feature-Spec Abschnitt 1),
// damit sie auch ueber einem spaeter komplexeren Hintergrund lesbar bleiben.
// energy zeigt bewusst den Muedigkeits-Fortschritt der aktuellen Session
// (siehe TirednessState.displayEnergyRatio), nicht PalStats.energy --
// Muedigkeits-Mechanik ist unabhaengig von der Time-Delta Engine.
class StatBar extends StatelessWidget {
  final double hunger;
  final double mood;
  final double energy;

  const StatBar({
    super.key,
    required this.hunger,
    required this.mood,
    required this.energy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatBadge(icon: Icons.apple, ratio: hunger),
          _StatBadge(icon: Icons.favorite, ratio: mood),
          _StatBadge(icon: Icons.bolt, ratio: energy),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final double ratio;

  const _StatBadge({required this.icon, required this.ratio});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: MeadowPalette.textOnLightPrimary),
        const SizedBox(height: 2),
        Text(
          '${(ratio.clamp(0.0, 1.0) * 100).round()}%',
          style: const TextStyle(
            color: MeadowPalette.textOnLightPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
