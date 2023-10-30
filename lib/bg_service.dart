import 'package:dio/dio.dart';
import 'package:example/models/isar/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class BackGroundService extends ChangeNotifier {
  ///
  Isar? isar;
  Future<void> openIsarDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    var isarDb = Isar.openSync(
      [
        PostDBSchema,
      ],
      directory: dir.path,
    );
    isar = isarDb;
  }

  getUser() async {
    final dio = Dio();
    Response response =
        await dio.get("https://jsonplaceholder.typicode.com/users");
    return response.data;
  }

  getPostFromUserID(String userID) async {
    final dio = Dio();
    print("Start POSTS API");
    await Future.delayed(const Duration(seconds: 15));
    Response response = await dio
        .get("https://jsonplaceholder.typicode.com/posts/?userId=$userID");
    List list = response.data;
    for (var element in list) {
      final postIsar = PostDB()
        ..id = element['id']
        ..userId = element['userId']
        ..title = element['title']
        ..body = element['body'];
      await isar?.writeTxn(() async {
        await isar!.postDBs.put(element);
      });
    }
    print("Saved to Isar and closed");
    return list;
  }
}
