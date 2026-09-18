import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../ingestion/processing/procedural_animation.dart';
import '../theme/meadow_palette.dart';

// Zeigt das eigene Pal-Sprite aus der Character Ingestion Pipeline
// (Kernsystem 3), sobald eins existiert -- bis dahin ein Platzhalter-Kreis.
// Nutzt die dort bereits vorhandenen prozeduralen Animations-Zeitfunktionen
// (Idle-Wobble) fuer die Animation. isTired verlangsamt die Animation
// ("langsamere Idle-Animation") und blendet ein "zzz"-Overlay ein
// (Muedigkeits-Mechanik, Feature-Spec Abschnitt 2) -- unabhaengig von
// PalStats/TimeDeltaEngine.
class PalWidget extends StatefulWidget {
  final bool isTired;
  final Uint8List? spriteBytes;
  final VoidCallback? onTap;

  const PalWidget({super.key, this.isTired = false, this.spriteBytes, this.onTap});

  @override
  State<PalWidget> createState() => _PalWidgetState();
}

class _PalWidgetState extends State<PalWidget> {
  static const _animation = ProceduralAnimation();
  final DateTime _startedAt = DateTime.now();
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted) {
        setState(() => _elapsed = DateTime.now().difference(_startedAt));
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Muedes Pal animiert sichtbar langsamer (Feature-Spec Abschnitt 2).
    final effectiveElapsed = widget.isTired
        ? Duration(microseconds: (_elapsed.inMicroseconds * 0.5).round())
        : _elapsed;
    final wobbleRadians = _animation.wobbleAngleDegrees(effectiveElapsed) * math.pi / 180;

    return GestureDetector(
      onTap: widget.onTap,
      child: Transform.rotate(
        angle: wobbleRadians,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (widget.spriteBytes == null)
              const _PlaceholderPal()
            else
              // BoxFit.contain skaliert das kleine Pixel-Raster (32x32, siehe
              // SpritePaletteConfig) auf die Widget-Groesse hoch;
              // FilterQuality.none haelt dabei die Pixel-Kanten scharf statt
              // sie weichzuzeichnen.
              Image.memory(
                widget.spriteBytes!,
                width: 140,
                height: 140,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
              ),
            if (widget.isTired)
              const Positioned(
                top: -8,
                right: -4,
                child: Text('💤', style: TextStyle(fontSize: 28)),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPal extends StatelessWidget {
  const _PlaceholderPal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: const BoxDecoration(color: MeadowPalette.palBody, shape: BoxShape.circle),
    );
  }
}
