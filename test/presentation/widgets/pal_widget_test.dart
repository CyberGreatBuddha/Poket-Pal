import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/presentation/widgets/pal_widget.dart';

import '../../support/fake_image_segmenter.dart';

void main() {
  testWidgets('shows the placeholder circle when no sprite exists yet', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PalWidget()));

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('renders the sprite image once spriteBytes is set', (tester) async {
    final bytes = encodedTestForegroundImage();

    await tester.pumpWidget(MaterialApp(home: PalWidget(spriteBytes: bytes)));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.filterQuality, FilterQuality.none);
  });
}
