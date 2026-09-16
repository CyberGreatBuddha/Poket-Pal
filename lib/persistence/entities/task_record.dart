import 'package:objectbox/objectbox.dart';

import 'activity.dart';
import 'pal.dart';

// Task/Response-Historie.
@Entity()
class TaskRecord {
  @Id()
  int id = 0;

  final pal = ToOne<Pal>();
  final activity = ToOne<Activity>(); // unset bei "normalem" Fuettern zuhause ohne Biome-Kontext

  String categoryKey = ''; // z. B. 'math.pictogram', 'german.vocabulary' -- matched SkillLevel.categoryKey
  int difficultyAtTime = 1;
  bool wasCorrect = false;
  int responseTimeMs = 0;
  DateTime completedAt = DateTime.now();

  // fuer Audio+Bild-Format: welche Variante wurde gezeigt
  String presentationMode = 'image_audio';
}
