import 'package:objectbox/objectbox.dart';

import '../../domain/tiredness/screen_time_repository.dart';
import '../../domain/tiredness/screen_time_state.dart';
import '../entities/screen_time_entry.dart';

// Singleton-artige Persistenz: es existiert immer genau ein Datensatz --
// get() legt beim ersten Aufruf einen frischen Zaehler an, save()
// aktualisiert denselben Datensatz.
class ObjectBoxScreenTimeRepository implements ScreenTimeRepository {
  final Store _store;

  ObjectBoxScreenTimeRepository(this._store);

  Box<ScreenTimeEntry> get _box => _store.box<ScreenTimeEntry>();

  @override
  Future<ScreenTimeState> get() async {
    final existing = _box.getAll();
    if (existing.isEmpty) {
      final initial = ScreenTimeState.initial(DateTime.now());
      await save(initial);
      return initial;
    }
    return _toDomain(existing.first);
  }

  @override
  Future<void> save(ScreenTimeState state) async {
    final existing = _box.getAll();
    final entry = existing.isEmpty ? ScreenTimeEntry() : existing.first;
    entry
      ..activeScreenTimeSeconds = state.activeScreenTimeSeconds
      ..lastResetDate = state.lastResetDate;
    _box.put(entry);
  }

  ScreenTimeState _toDomain(ScreenTimeEntry entry) => ScreenTimeState(
        activeScreenTimeSeconds: entry.activeScreenTimeSeconds,
        lastResetDate: entry.lastResetDate,
      );
}
