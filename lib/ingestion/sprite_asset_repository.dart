import 'dart:typed_data';

import 'sprite_asset_draft.dart';

// Persistenz-Schnittstelle fuer das Ergebnis der Ingestion-Pipeline (letzter
// Schritt im Pipeline-Diagramm, Kernsystem 3). Von der Ingestion-Schicht
// definiert, nicht vom Domain Core -- die Character Ingestion Pipeline ist
// laut Architektur-Diagramm eine eigenstaendige Schicht neben dem Domain Core.
abstract class SpriteAssetRepository {
  // Speichert den Draft als SpriteAsset und verknuepft es 1:1 mit dem Pal
  // (Kernsystem 4: Pal.spriteAsset). Gibt die vergebene SpriteAsset-Id zurueck.
  Future<int> saveForPal({
    required int palId,
    required SpriteAssetDraft draft,
    required String sourceType,
  });

  // Fuer die Anzeige im Homescreen (PalWidget): die fertigen Sprite-Bytes des
  // Pals, oder null, wenn noch kein eigenes Pal erstellt wurde.
  Future<Uint8List?> getSpriteBytesForPal(int palId);
}
