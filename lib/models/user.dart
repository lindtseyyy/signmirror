import 'package:isar_community/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  late String email;
  late String name;
  late String password;
  
  String profilePictureUrl = 'assets/images/profile_picture.jpeg';
}
