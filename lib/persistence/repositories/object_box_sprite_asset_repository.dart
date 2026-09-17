import 'dart:io';

import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../ingestion/sprite_asset_draft.dart';
import '../../ingestion/sprite_asset_repository.dart';
import '../entities/pal.dart';
import '../entities/sprite_asset.dart' as entities;

class ObjectBoxSpriteAssetRepository implements SpriteAssetRepository {
  final Store _store;

  ObjectBoxSpriteAssetRepository(this._store);

  Box<Pal> get _palBox => _store.box<Pal>();
  Box<entities.SpriteAsset> get _spriteAssetBox => _store.box<entities.SpriteAsset>();

  @override
  Future<int> saveForPal({
    required int palId,
    required SpriteAssetDraft draft,
    required String sourceType,
  }) async {
    final pal = _palBox.get(palId);
    if (pal == null) {
      throw StateError('Pal mit Id $palId nicht gefunden.');
    }

    final filePath = await _writeSpriteFile(palId, draft);

    final entity = entities.SpriteAsset()
      ..spriteFilePath = filePath
      ..paletteId = 'default-16'
      ..spriteWidth = draft.width
      ..spriteHeight = draft.height
      ..createdAt = DateTime.now()
      ..segmentationModel = draft.segmentationModel
      ..segmentationConfidence = draft.segmentationConfidence
      ..sourceType = sourceType
      ..designMode = 'none';

    final id = _spriteAssetBox.put(entity);

    pal.spriteAsset.target = entity;
    _palBox.put(pal);

    return id;
  }

  Future<String> _writeSpriteFile(int palId, SpriteAssetDraft draft) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final spritesDir = Directory(p.join(docsDir.path, 'poketpal-sprites'));
    if (!await spritesDir.exists()) {
      await spritesDir.create(recursive: true);
    }

    final fileName = 'pal_${palId}_${DateTime.now().microsecondsSinceEpoch}.png';
    final file = File(p.join(spritesDir.path, fileName));
    await file.writeAsBytes(draft.spriteImageBytes);
    return file.path;
  }
}
