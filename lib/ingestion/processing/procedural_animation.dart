import 'dart:math';

// Da nur ein einzelnes Quellbild existiert, ist echte Frame-fuer-Frame-
// Animation nicht moeglich (Kernsystem 3) -- Animation erfolgt stattdessen
// prozedural (Transform-basiert: Wackeln, Huepfen, Blinzeln-Overlay).
// Platzhalter-Balancing-Werte, im Playtesting anzupassen.
class ProceduralAnimationConfig {
  static const double wobbleAmplitudeDegrees = 4.0;
  static const Duration wobblePeriod = Duration(milliseconds: 2000);

  static const double bounceAmplitudePixels = 3.0;
  static const Duration bouncePeriod = Duration(milliseconds: 1500);

  static const Duration blinkInterval = Duration(seconds: 4);
  static const Duration blinkDuration = Duration(milliseconds: 150);
}

// Reine Zeitfunktionen fuer die drei prozeduralen Transforms -- die
// tatsaechliche Anwendung auf das Sprite (Rotation/Translation/Overlay-Wechsel)
// ist Sache der Presentation-Schicht.
class ProceduralAnimation {
  const ProceduralAnimation();

  double wobbleAngleDegrees(Duration elapsed) {
    final phase = _phase(elapsed, ProceduralAnimationConfig.wobblePeriod);
    return ProceduralAnimationConfig.wobbleAmplitudeDegrees * sin(2 * pi * phase);
  }

  double bounceOffsetPixels(Duration elapsed) {
    final phase = _phase(elapsed, ProceduralAnimationConfig.bouncePeriod);
    // (1 - cos)/2 statt sin: huepft nur nach oben, statt auch unter die Basislinie zu schwingen.
    return ProceduralAnimationConfig.bounceAmplitudePixels * ((1 - cos(2 * pi * phase)) / 2);
  }

  bool isBlinking(Duration elapsed) {
    final cyclePosition = elapsed.inMicroseconds %
        ProceduralAnimationConfig.blinkInterval.inMicroseconds;
    return cyclePosition < ProceduralAnimationConfig.blinkDuration.inMicroseconds;
  }

  double _phase(Duration elapsed, Duration period) {
    final cyclePosition = elapsed.inMicroseconds % period.inMicroseconds;
    return cyclePosition / period.inMicroseconds;
  }
}
