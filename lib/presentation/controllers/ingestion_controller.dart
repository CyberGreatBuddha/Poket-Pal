import 'package:flutter/foundation.dart';

import '../../ingestion/character_ingestion_pipeline.dart';
import '../../ingestion/sprite_asset_draft.dart';
import '../../ingestion/sprite_asset_repository.dart';

// Verbindet CharacterIngestionPipeline + SpriteAssetRepository mit der UI.
// Kennt bewusst kein image_picker -- der aufrufende Screen besorgt den
// Foto-Pfad (Kamera/Galerie) und uebergibt ihn hier, damit dieser Controller
// unabhaengig vom Picker-Plugin mit Fakes testbar bleibt.
class IngestionController extends ChangeNotifier {
  final CharacterIngestionPipeline _pipeline;
  final SpriteAssetRepository _spriteAssetRepository;

  // Oeffentliche Parameternamen + manuelle Zuweisung statt privater
  // initializing formals (siehe PalController fuer die Begruendung --
  // Aufrufer sitzt in app.dart).
  IngestionController({
    required CharacterIngestionPipeline pipeline,
    required SpriteAssetRepository spriteAssetRepository,
  })  :
        // ignore: prefer_initializing_formals
        _pipeline = pipeline,
        // ignore: prefer_initializing_formals
        _spriteAssetRepository = spriteAssetRepository;

  bool _isProcessing = false;
  SpriteAssetDraft? _lastDraft;
  String? _error;

  bool get isProcessing => _isProcessing;
  SpriteAssetDraft? get lastDraft => _lastDraft;
  String? get error => _error;

  Future<void> ingestFromPath({required int palId, required String imagePath}) async {
    _isProcessing = true;
    _error = null;
    _lastDraft = null;
    notifyListeners();

    try {
      final draft = await _pipeline.process(imagePath);
      await _spriteAssetRepository.saveForPal(palId: palId, draft: draft, sourceType: 'photo');
      _lastDraft = draft;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void reset() {
    _lastDraft = null;
    _error = null;
    notifyListeners();
  }
}
