import '../../domain/pal/pal_repository.dart';
import '../../domain/pal/pal_state.dart';

// In-Memory-Implementierung von PalRepository fuer Entwicklung/Tests ohne
// ObjectBox (z. B. Praesentation-Layer-Arbeit in Chrome, solange kein
// Android-Emulator laeuft). Verhaelt sich bewusst wie die echte
// ObjectBoxPalRepository (Id-Vergabe, Fehlerfaelle), damit sich beide 1:1
// austauschen lassen.
class InMemoryPalRepository implements PalRepository {
  final Map<int, PalState> _pals = {};
  int _nextId = 1;

  @override
  Future<PalState?> getActive() async {
    for (final pal in _pals.values) {
      if (pal.isActive) return pal;
    }
    return null;
  }

  @override
  Future<List<PalState>> getAll() async => _pals.values.toList();

  @override
  Future<PalState> save(PalState pal) async {
    if (pal.id == 0 || !_pals.containsKey(pal.id)) {
      final id = pal.id == 0 ? _nextId++ : pal.id;
      final assigned = PalState(
        id: id,
        name: pal.name,
        createdAt: pal.createdAt,
        lastInteractionAt: pal.lastInteractionAt,
        stats: pal.stats,
        isActive: pal.isActive,
        archivedAt: pal.archivedAt,
        isFrozen: pal.isFrozen,
        frozenSince: pal.frozenSince,
        locationState: pal.locationState,
        currentBiomeId: pal.currentBiomeId,
      );
      _pals[id] = assigned;
      return assigned;
    }

    _pals[pal.id] = pal;
    return pal;
  }
}
