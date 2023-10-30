import 'package:isar/isar.dart';

part 'post.g.dart';

@collection
class PostDB {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  int? userId;
  String? title;
  String? body;
}
