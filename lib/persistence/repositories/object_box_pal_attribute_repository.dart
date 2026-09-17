import 'package:objectbox/objectbox.dart';

import '../../domain/pal/pal_attribute_repository.dart';
import '../../domain/pal/pal_attributes.dart';
import '../entities/pal.dart';
import '../entities/pal_attribute.dart';

class ObjectBoxPalAttributeRepository implements PalAttributeRepository {
  final Store _store;

  ObjectBoxPalAttributeRepository(this._store);

  Box<Pal> get _palBox => _store.box<Pal>();
  Box<PalAttribute> get _attributeBox => _store.box<PalAttribute>();

  @override
  Future<PalAttributes> getAll(int palId) async {
    final pal = _palBox.get(palId);
    if (pal == null) return PalAttributes.empty();

    final values = {for (final attribute in pal.attributes) attribute.key: attribute.value};
    return PalAttributes.fromMap(values);
  }

  @override
  Future<void> setValue({
    required int palId,
    required String key,
    required String value,
  }) async {
    final pal = _palBox.get(palId);
    if (pal == null) {
      throw StateError('Pal mit Id $palId nicht gefunden.');
    }

    final existing = _find(pal, key);
    if (existing != null) {
      existing.value = value;
      _attributeBox.put(existing);
      return;
    }

    final entry = PalAttribute()
      ..key = key
      ..value = value;
    entry.pal.target = pal;
    _attributeBox.put(entry);
  }

  @override
  Future<void> removeValue({required int palId, required String key}) async {
    final pal = _palBox.get(palId);
    if (pal == null) return;

    final existing = _find(pal, key);
    if (existing != null) {
      _attributeBox.remove(existing.id);
    }
  }

  PalAttribute? _find(Pal pal, String key) {
    for (final attribute in pal.attributes) {
      if (attribute.key == key) return attribute;
    }
    return null;
  }
}
