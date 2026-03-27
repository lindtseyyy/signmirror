import 'package:isar_community/isar.dart';

part 'community_video.g.dart';

@collection
class CommunityVideo {
  Id id = Isar.autoIncrement;

  late String title;

  String? description;

  late String videoUrl;

  late List<Comment> comments; // ✅ supported

  late int approves;

  late int uploaderId;

  late bool
  isApprovedByCurrentUser; // This will help us track if the current user has approved this video or not
}

@embedded
class Comment {
  late int userId;
  late String text;
}
