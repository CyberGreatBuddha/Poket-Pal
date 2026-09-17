import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/domain/pal/pal_attributes.dart';

void main() {
  test('empty attributes return null for any key', () {
    final attributes = PalAttributes.empty();

    expect(attributes.getString('personality'), isNull);
    expect(attributes.getInt('favoriteColorIndex'), isNull);
    expect(attributes.getDouble('someFactor'), isNull);
    expect(attributes.getBool('isShiny'), isNull);
  });

  test('withValue stores a typed value retrievable via the matching getter', () {
    final attributes = PalAttributes.empty()
        .withValue('personality', 'verspielt')
        .withValue('favoriteColorIndex', 3)
        .withValue('speedFactor', 1.5)
        .withValue('isShiny', true);

    expect(attributes.getString('personality'), 'verspielt');
    expect(attributes.getInt('favoriteColorIndex'), 3);
    expect(attributes.getDouble('speedFactor'), 1.5);
    expect(attributes.getBool('isShiny'), isTrue);
  });

  test('withValue is immutable -- returns a new instance, original unchanged', () {
    final original = PalAttributes.empty();
    final updated = original.withValue('personality', 'schuechtern');

    expect(original.getString('personality'), isNull);
    expect(updated.getString('personality'), 'schuechtern');
  });

  test('withoutValue removes a key', () {
    final attributes = PalAttributes.empty().withValue('personality', 'mutig');
    final removed = attributes.withoutValue('personality');

    expect(removed.getString('personality'), isNull);
  });
}
