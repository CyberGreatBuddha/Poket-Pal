import '../../domain/pal/pal_repository.dart';
import '../../domain/pal/pal_state.dart';
import '../entities/difficulty_model.dart';
import '../entities/pal.dart';
import '../mappers/pal_mapper.dart';
import '../../objectbox.g.dart';

class ObjectBoxPalRepository implements PalRepository {
  final Store _store;

  ObjectBoxPalRepository(this._store);

  Box<Pal> get _box => _store.box<Pal>();
  Box<DifficultyModel> get _difficultyModelBox => _store.box<DifficultyModel>();

  @override
  Future<PalState?> getActive() async {
    final query = _box.query(Pal_.isActive.equals(true)).build();
    try {
      final entity = query.findFirst();
      return entity == null ? null : palEntityToState(entity);
    } finally {
      query.close();
    }
  }

  @override
  Future<List<PalState>> getAll() async {
    return _box.getAll().map(palEntityToState).toList();
  }

  @override
  Future<PalState> save(PalState pal) async {
    final entity = (pal.id == 0 ? null : _box.get(pal.id)) ?? Pal();

    applyPalStateToEntity(pal, entity);

    // Jedes Pal braucht ein DifficultyModel fuer die Task Engine (Kernsystem 4) --
    // beim ersten Speichern eines neuen Pals wird eines angelegt.
    if (entity.difficultyModel.target == null) {
      final difficultyModel = DifficultyModel();
      _difficultyModelBox.put(difficultyModel);
      entity.difficultyModel.target = difficultyModel;
    }

    _box.put(entity);
    return palEntityToState(entity);
  }
}
