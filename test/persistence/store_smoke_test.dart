import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poketpal/objectbox.g.dart';

void main() {
  test('can open and close a real ObjectBox store', () async {
    final dir = Directory.systemTemp.createTempSync('poketpal_store_smoke_');
    try {
      final store = await openStore(directory: dir.path);
      store.close();
    } finally {
      dir.deleteSync(recursive: true);
    }
  });
}
