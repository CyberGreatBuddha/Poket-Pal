import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../objectbox.g.dart';

// Oeffnet und haelt den ObjectBox-Store fuer die Laufzeit der App.
// Domain Core und Presentation greifen ausschliesslich ueber diese Klasse
// (bzw. spaeter Repository-Abstraktionen darueber) auf Persistenz zu.
class ObjectBox {
  late final Store store;

  ObjectBox._create(this.store);

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(docsDir.path, 'poketpal-db'),
    );
    return ObjectBox._create(store);
  }
}
