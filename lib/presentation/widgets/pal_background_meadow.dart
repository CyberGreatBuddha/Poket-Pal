import 'package:flutter/material.dart';

import '../theme/meadow_palette.dart';
import 'homescreen_background.dart';

// Aktuelle Homescreen-Szene "Warme Wiese" (Zwischenloesung): schlichte
// Himmel-/Bodenflaechen. Drop-in-Replacement-Kandidaten wie
// PalBackgroundFarm implementieren denselben HomescreenBackground-Vertrag.
class PalBackgroundMeadow extends HomescreenBackground {
  const PalBackgroundMeadow({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: MeadowPalette.sky),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 0.35,
            child: Container(color: MeadowPalette.ground),
          ),
        ),
      ],
    );
  }
}
