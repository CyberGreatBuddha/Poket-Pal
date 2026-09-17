import '../../domain/settings/parent_settings.dart';
import '../../domain/settings/parent_settings_repository.dart';

class InMemoryParentSettingsRepository implements ParentSettingsRepository {
  ParentSettings? _settings;

  @override
  Future<ParentSettings> get() async {
    return _settings ??= ParentSettings.defaults();
  }

  @override
  Future<void> save(ParentSettings settings) async {
    _settings = settings;
  }
}
