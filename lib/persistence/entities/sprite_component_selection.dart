import 'package:objectbox/objectbox.dart';

import 'character_component_option.dart';
import 'sprite_asset.dart';

// Konkrete Auswahl, verknuepft mit einem SpriteAsset.
@Entity()
class SpriteComponentSelection {
  @Id()
  int id = 0;

  final spriteAsset = ToOne<SpriteAsset>();
  final componentOption = ToOne<CharacterComponentOption>();
}
