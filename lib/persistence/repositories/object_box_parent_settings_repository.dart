import 'package:objectbox/objectbox.dart';

import '../../domain/settings/parent_settings.dart';
import '../../domain/settings/parent_settings_repository.dart';
import '../entities/parent_settings_entry.dart';

// Singleton-artige Persistenz: es existiert immer genau ein Datensatz --
// get() legt beim ersten Aufruf die Default-Werte an, save() aktualisiert
// denselben Datensatz.
class ObjectBoxParentSettingsRepository implements ParentSettingsRepository {
  final Store _store;

  ObjectBoxParentSettingsRepository(this._store);

  Box<ParentSettingsEntry> get _box => _store.box<ParentSettingsEntry>();

  @override
  Future<ParentSettings> get() async {
    final existing = _box.getAll();
    if (existing.isEmpty) {
      final defaults = ParentSettings.defaults();
      await save(defaults);
      return defaults;
    }
    return _toDomain(existing.first);
  }

  @override
  Future<void> save(ParentSettings settings) async {
    final existing = _box.getAll();
    final entry = existing.isEmpty ? ParentSettingsEntry() : existing.first;
    entry
      ..tirednessThresholdMinutes = settings.tirednessThresholdMinutes
      ..isTirednessLimitEnabled = settings.isTirednessLimitEnabled;
    _box.put(entry);
  }

  ParentSettings _toDomain(ParentSettingsEntry entry) => ParentSettings(
        tirednessThresholdMinutes: entry.tirednessThresholdMinutes,
        isTirednessLimitEnabled: entry.isTirednessLimitEnabled,
      );
}
