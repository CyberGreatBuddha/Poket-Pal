import '../../domain/pal/pal_attribute_repository.dart';
import '../../domain/pal/pal_attributes.dart';

// In-Memory-Implementierung von PalAttributeRepository fuer Entwicklung/Tests
// ohne ObjectBox.
class InMemoryPalAttributeRepository implements PalAttributeRepository {
  final Map<int, Map<String, String>> _attributes = {};

  @override
  Future<PalAttributes> getAll(int palId) async {
    return PalAttributes.fromMap(_attributes[palId] ?? const {});
  }

  @override
  Future<void> setValue({
    required int palId,
    required String key,
    required String value,
  }) async {
    _attributes.putIfAbsent(palId, () => {})[key] = value;
  }

  @override
  Future<void> removeValue({required int palId, required String key}) async {
    _attributes[palId]?.remove(key);
  }
}
