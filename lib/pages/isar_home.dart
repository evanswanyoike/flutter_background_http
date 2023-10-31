import 'package:example/bg_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IsarHome extends StatefulWidget {
  const IsarHome({super.key});

  @override
  State<IsarHome> createState() => _IsarHomeState();
}

class _IsarHomeState extends State<IsarHome> {
  initSP() async {}
  @override
  void initState() {
    context.read<BackGroundService>().readAllArts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline DB"),
      ),
      body: Consumer<BackGroundService>(
        builder: (key, provider, child) {
          return ListView.builder(
            itemCount: provider.posts?.length ?? 0,
            itemBuilder: (context, index) {
              var post = provider.posts?[index];
              return ListTile(
                leading: Text("${post?.userId}"),
                title: Text("${post?.title}"),
                subtitle: Text("${post?.body}"),
              );
            },
          );
        },
      ),
    );
  }
}
