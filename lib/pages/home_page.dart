import 'package:example/bg_service.dart';
import 'package:flutter/material.dart';
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
            return ListView.builder(itemBuilder: (ctx, index) {
              dynamic data = list[index];
              return ListTile(
                onTap: () async {
                  /// Start BackGround Service
                },
                title: Text(data['title']),
                subtitle: Text(data['body']),
                leading: Text(data['id']),
                trailing: Text(data['userId']),
              );
            });
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
