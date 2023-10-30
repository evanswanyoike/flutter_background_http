import 'package:example/bg_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future? future;
  @override
  void initState() {
    future = context.read<BackGroundService>().getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            List<dynamic> list = snapshot.data;
            return ListView.builder(
                itemCount: list.length,
                itemBuilder: (ctx, index) {
                  dynamic data = list[index];
                  return ListTile(
                    onTap: () async {
                      /// Start BackGround Service
                      context.read<BackGroundService>().userId =
                          "${data['id']}";
                      final service = FlutterBackgroundService();
                      var isRunning = await service.isRunning();
                      if (isRunning) {
                        service.invoke("stopService");
                      } else {
                        service.startService();
                      }
                    },
                    title: Text("${data['name']}"),
                    subtitle: Text("${data['email']}"),
                    leading: Text("${data['id']}"),
                    // trailing: Text(data['userId']),
                  );
                });
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
