import 'package:objectbox/objectbox.dart';

import 'activity.dart';
import 'biome.dart';
import 'difficulty_model.dart';
import 'sprite_asset.dart';
import 'task_record.dart';

// Pal (ehemals "Pet").
@Entity()
class Pal {
  @Id()
  int id = 0;

  String name = '';
  DateTime createdAt = DateTime.now();
  DateTime lastInteractionAt = DateTime.now();

  // Stats (0.0 - 1.0, floor bei 0.2 durch Time-Delta Engine erzwungen)
  double hunger = 1.0;
  double mood = 1.0;
  double energy = 1.0;

  // Sammlungsmodell: aktives vs. archiviertes Pal
  bool isActive = true;
  DateTime? archivedAt;

  // Freeze-Status (Leniency-Policy)
  bool isFrozen = false;
  DateTime? frozenSince;

  final spriteAsset = ToOne<SpriteAsset>(); // 1:1 -- reicht fuers Erste
  final difficultyModel = ToOne<DifficultyModel>();

  // Zuhause-/Erkundungs-Status
  String locationState = 'home'; // 'home' | 'exploring'
  final currentBiome = ToOne<Biome>(); // gesetzt, waehrend exploring

  @Backlink('pal')
  final taskHistory = ToMany<TaskRecord>();

  @Backlink('pal')
  final activityHistory = ToMany<Activity>();
}
