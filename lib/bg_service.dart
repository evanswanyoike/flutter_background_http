import 'package:dio/dio.dart';
import 'package:example/models/isar/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<PostDB>? posts = [];
  Future readAllArts() async {
    var list = isar?.postDBs.filter().bodyIsNotEmpty().findAll();
    posts = await list;
    print("SAVED TO ISAR: ${posts}");
    // notifyListeners();
    // return true;
  }

  getUser() async {
    final dio = Dio();
    Response response =
        await dio.get("https://jsonplaceholder.typicode.com/users");
    return response.data;
  }

  String? userId;
  getPostFromUserID() async {
    // FlutterBackgroundService().invoke("setAsBackground");
    final dio = Dio();
    print("Start POSTS API ${DateTime.now()}");
    await Future.delayed(const Duration(seconds: 6));
    Response response =
        await dio.get("https://jsonplaceholder.typicode.com/posts/?userId=1");
    List list = response.data;
    try {
      ///TODO: IDK WHY BUT DATA IS SAVED TO SHARED-PREFERENCES BUT NOT TO ISAR-DB
      Isar? isr = Isar.getInstance();
      var element = list[0];
      final postIsar = PostDB()
        // ..id = element['id']
        ..userId = element['userId']
        ..title = element['title']
        ..body = element['body'];
      await isr?.writeTxn(() async {
        await isr.postDBs.put(postIsar);
      });
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      /* var sp =*/ await sharedPreferences.setString(
          "t2v", element.toString());
      var spData = sharedPreferences.getString("t2v");
      // print(spData.toString());

      // await isar?.writeTxn(() async {
      //   await isar!.userGeneratedArts.put(res);
      //   readAllArts();
      // });
      var listPostDB = await isar?.postDBs.filter().bodyIsNotEmpty().findAll();
      print(
          "Saved to Isar and Closed Success: ${listPostDB?.first.toString()} SP: ${spData.toString()}");
    } catch (e) {
      print("ISAR SAVE ERROR: $e");
      rethrow;
    }
    // userId = null;
    // readAllArts();
    // return list;
  }
}
