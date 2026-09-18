import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ingestion/processing/procedural_animation.dart';
import '../theme/meadow_palette.dart';

// Platzhalter-Darstellung des Pals (Zwischenloesung, echte Sprite-Assets
// kommen erst aus der Character Ingestion Pipeline). Nutzt die dort bereits
// vorhandenen prozeduralen Animations-Zeitfunktionen (Idle-Wobble) fuer die
// Animation. isTired verlangsamt die Animation ("langsamere Idle-Animation")
// und blendet ein "zzz"-Overlay ein (Muedigkeits-Mechanik, Feature-Spec
// Abschnitt 2) -- unabhaengig von PalStats/TimeDeltaEngine.
class PalWidget extends StatefulWidget {
  final bool isTired;
  final VoidCallback? onTap;

  const PalWidget({super.key, this.isTired = false, this.onTap});

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
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(color: MeadowPalette.palBody, shape: BoxShape.circle),
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
