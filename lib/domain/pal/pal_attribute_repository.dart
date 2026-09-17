import 'pal_attributes.dart';

// Persistenz-Schnittstelle fuer den Pal-Eigenschaften-Layer (siehe
// PalAttributes). Bewusst getrennt von PalRepository, damit PalState nicht mit
// einer wachsenden Zahl noch unbestimmter Eigenschaften aufgeblaeht wird --
// gleiches Trennungsprinzip wie SkillLevelRepository vs. PalRepository.
abstract class PalAttributeRepository {
  Future<PalAttributes> getAll(int palId);

  Future<void> setValue({required int palId, required String key, required String value});

  Future<void> removeValue({required int palId, required String key});
}
