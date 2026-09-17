import 'package:flutter/material.dart';

import '../theme/meadow_palette.dart';

// Prominenter, volle-Breite CTA (Feature-Spec Abschnitt 1). Oeffnet aktuell
// den CategoryPickerScreen (bisherige Kategorie-Liste vom Homescreen
// hierher umgezogen).
class PlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: MeadowPalette.palBody,
          foregroundColor: MeadowPalette.textOnDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Spielen'),
      ),
    );
  }
}
