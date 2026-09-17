import 'parent_settings.dart';

abstract class ParentSettingsRepository {
  Future<ParentSettings> get();
  Future<void> save(ParentSettings settings);
}
