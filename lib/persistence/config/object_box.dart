import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/pal/pal_attribute_repository.dart';
import '../../domain/pal/pal_repository.dart';
import '../../domain/settings/parent_settings_repository.dart';
import '../../domain/task_engine/skill_level_repository.dart';
import '../../domain/task_engine/task_history_repository.dart';
import '../../domain/tiredness/screen_time_repository.dart';
import '../../ingestion/sprite_asset_repository.dart';
import '../repositories/object_box_pal_attribute_repository.dart';
import '../repositories/object_box_pal_repository.dart';
import '../repositories/object_box_parent_settings_repository.dart';
import '../repositories/object_box_screen_time_repository.dart';
import '../repositories/object_box_skill_level_repository.dart';
import '../repositories/object_box_sprite_asset_repository.dart';
import '../repositories/object_box_task_history_repository.dart';
import '../../objectbox.g.dart';

// Oeffnet und haelt den ObjectBox-Store fuer die Laufzeit der App und stellt
// die Repository-Implementierungen bereit, ueber die Domain Core und
// Presentation ausschliesslich auf Persistenz zugreifen (siehe die
// Repository-Interfaces in domain/).
class ObjectBox {
  final Store store;
  final PalRepository palRepository;
  final TaskHistoryRepository taskHistoryRepository;
  final SkillLevelRepository skillLevelRepository;
  final PalAttributeRepository palAttributeRepository;
  final SpriteAssetRepository spriteAssetRepository;
  final ParentSettingsRepository parentSettingsRepository;
  final ScreenTimeRepository screenTimeRepository;

  ObjectBox._create(this.store)
      : palRepository = ObjectBoxPalRepository(store),
        taskHistoryRepository = ObjectBoxTaskHistoryRepository(store),
        skillLevelRepository = ObjectBoxSkillLevelRepository(store),
        palAttributeRepository = ObjectBoxPalAttributeRepository(store),
        spriteAssetRepository = ObjectBoxSpriteAssetRepository(store),
        parentSettingsRepository = ObjectBoxParentSettingsRepository(store),
        screenTimeRepository = ObjectBoxScreenTimeRepository(store);

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(docsDir.path, 'poketpal-db'),
    );
    return ObjectBox._create(store);
  }
}
