import 'package:isar_community/isar.dart';

part 'lesson.g.dart';

@Collection()
class Lesson {
  Id id = Isar.autoIncrement; // Auto-incrementing ID

  @Index(type: IndexType.value)
  late String title;
  late int count;
  late String level;
  late double progress;
  late String imagePath;
}
