import 'dart:typed_data';

import '../../ingestion/sprite_asset_draft.dart';
import '../../ingestion/sprite_asset_repository.dart';

class _StoredSpriteAsset {
  final int id;
  final int palId;
  final SpriteAssetDraft draft;
  final String sourceType;

  const _StoredSpriteAsset(this.id, this.palId, this.draft, this.sourceType);
}

// In-Memory-Implementierung von SpriteAssetRepository fuer Entwicklung/Tests
// ohne ObjectBox/Dateisystem -- haelt den Draft nur im Speicher statt eine
// Datei zu schreiben.
class InMemorySpriteAssetRepository implements SpriteAssetRepository {
  final Map<int, _StoredSpriteAsset> _byPalId = {};
  int _nextId = 1;

  @override
  Future<int> saveForPal({
    required int palId,
    required SpriteAssetDraft draft,
    required String sourceType,
  }) async {
    final id = _nextId++;
    _byPalId[palId] = _StoredSpriteAsset(id, palId, draft, sourceType);
    return id;
  }

  @override
  Future<Uint8List?> getSpriteBytesForPal(int palId) async {
    return _byPalId[palId]?.draft.spriteImageBytes;
  }
}
