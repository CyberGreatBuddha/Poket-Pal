import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/tiredness/tiredness_balancing.dart';
import 'package:poketpal/domain/tiredness/tiredness_state.dart';

void main() {
  test('progress is 0 when fresh and 1.0 once the threshold is reached', () {
    const fresh = TirednessState(
      activeScreenTimeSeconds: 0,
      thresholdMinutes: 25,
      isLimitEnabled: true,
    );
    const atThreshold = TirednessState(
      activeScreenTimeSeconds: 25 * 60,
      thresholdMinutes: 25,
      isLimitEnabled: true,
    );

    expect(fresh.progress, 0.0);
    expect(atThreshold.progress, 1.0);
    expect(atThreshold.isTired, isTrue);
    expect(fresh.isTired, isFalse);
  });

  test('progress never exceeds 1.0 even far beyond the threshold', () {
    const overTime = TirednessState(
      activeScreenTimeSeconds: 999999,
      thresholdMinutes: 25,
      isLimitEnabled: true,
    );

    expect(overTime.progress, 1.0);
  });

  test('progress is always 0 and never tired when the limit is disabled', () {
    const disabled = TirednessState(
      activeScreenTimeSeconds: 999999,
      thresholdMinutes: 25,
      isLimitEnabled: false,
    );

    expect(disabled.progress, 0.0);
    expect(disabled.isTired, isFalse);
  });

  test('displayEnergyRatio falls linearly from start to tired ratio', () {
    const halfway = TirednessState(
      activeScreenTimeSeconds: (25 * 60) ~/ 2,
      thresholdMinutes: 25,
      isLimitEnabled: true,
    );

    final expectedHalfway =
        (TirednessBalancing.startEnergyRatio + TirednessBalancing.tiredEnergyRatio) / 2;
    expect(halfway.displayEnergyRatio, closeTo(expectedHalfway, 1e-9));
  });
}
