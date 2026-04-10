import 'package:isar_community/isar.dart';

part 'sign.g.dart';

@Collection()
class Sign {
  Id id = Isar.autoIncrement; // Auto-incrementing ID

  @Index(type: IndexType.value)
  late String title;
  late String category;
  late String imagePath;

  bool isBookmarked = false;

  String? videoUrl;
  String? videoId;
  String? instructions;
}
