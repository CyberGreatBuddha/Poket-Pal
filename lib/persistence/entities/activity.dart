import 'package:objectbox/objectbox.dart';

import 'biome.dart';
import 'pal.dart';
import 'task_record.dart';

// Activity buendelt eine Folge von Aufgaben unter einem Thema
// (Fuettern / Erkunden / Geheimnis / Kampf) und trackt Start/Abschluss.
@Entity()
class Activity {
  @Id()
  int id = 0;

  final pal = ToOne<Pal>();
  final biome = ToOne<Biome>(); // unset bei 'feeding' zuhause

  String activityType = ''; // 'feeding' | 'exploration' | 'mystery' | 'battle'
  int requiredTaskCount = 1;
  DateTime startedAt = DateTime.now();
  DateTime? completedAt;

  @Backlink('activity')
  final taskRecords = ToMany<TaskRecord>();
}
