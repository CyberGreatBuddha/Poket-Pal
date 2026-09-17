import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/ingestion/processing/procedural_animation.dart';

void main() {
  const animation = ProceduralAnimation();

  test('wobble starts at zero degrees and returns to zero after a full period', () {
    expect(animation.wobbleAngleDegrees(Duration.zero), closeTo(0, 1e-9));
    expect(
      animation.wobbleAngleDegrees(ProceduralAnimationConfig.wobblePeriod),
      closeTo(0, 1e-6),
    );
  });

  test('wobble stays within its configured amplitude', () {
    for (var ms = 0; ms < ProceduralAnimationConfig.wobblePeriod.inMilliseconds; ms += 50) {
      final angle = animation.wobbleAngleDegrees(Duration(milliseconds: ms));
      expect(angle.abs(), lessThanOrEqualTo(ProceduralAnimationConfig.wobbleAmplitudeDegrees + 1e-9));
    }
  });

  test('bounce is zero at the start/end of its period and never negative', () {
    expect(animation.bounceOffsetPixels(Duration.zero), closeTo(0, 1e-9));
    expect(
      animation.bounceOffsetPixels(ProceduralAnimationConfig.bouncePeriod),
      closeTo(0, 1e-6),
    );

    for (var ms = 0; ms < ProceduralAnimationConfig.bouncePeriod.inMilliseconds; ms += 50) {
      expect(animation.bounceOffsetPixels(Duration(milliseconds: ms)), greaterThanOrEqualTo(-1e-9));
    }
  });

  test('bounce reaches its full amplitude at the midpoint of the period', () {
    final midpoint = Duration(
      microseconds: ProceduralAnimationConfig.bouncePeriod.inMicroseconds ~/ 2,
    );
    expect(
      animation.bounceOffsetPixels(midpoint),
      closeTo(ProceduralAnimationConfig.bounceAmplitudePixels, 1e-6),
    );
  });

  test('blinks only briefly at the start of each blink interval', () {
    expect(animation.isBlinking(Duration.zero), isTrue);
    expect(
      animation.isBlinking(ProceduralAnimationConfig.blinkDuration + const Duration(milliseconds: 1)),
      isFalse,
    );
    expect(
      animation.isBlinking(ProceduralAnimationConfig.blinkInterval),
      isTrue,
    );
    expect(
      animation.isBlinking(
        ProceduralAnimationConfig.blinkInterval + ProceduralAnimationConfig.blinkDuration + const Duration(milliseconds: 1),
      ),
      isFalse,
    );
  });
}
