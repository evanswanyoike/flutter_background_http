import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:example/pages/home_page.dart';
import 'package:example/pages/isar_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bg_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: false,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: false,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  // Timer.periodic(const Duration(minutes: 5), (timer) async {
  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      /// OPTIONAL for use custom notification
      /// the notification id must be equals with AndroidConfiguration when you call configure() method.
      flutterLocalNotificationsPlugin.show(
        888,
        'Text to Video',
        'Generating something awesome',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'my_foreground',
            'MY FOREGROUND SERVICE',
            icon: 'ic_bg_service_small',
            ongoing: true,
          ),
        ),
      );

      // if you don't using custom notification, uncomment this
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Updated at ${DateTime.now()}",
      );
    }
  }

  /// you can see this log in logcat
  print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

  // test using external plugin
  final deviceInfo = DeviceInfoPlugin();
  // String? device;
  // if (Platform.isAndroid) {
  //   final androidInfo = await deviceInfo.androidInfo;
  //   device = androidInfo.model;
  // }
  //
  // if (Platform.isIOS) {
  //   final iosInfo = await deviceInfo.iosInfo;
  //   device = iosInfo.model;
  // }
  // List? data = await fetchPosts();
  BackGroundService bg = BackGroundService();
  var data = await bg.getPostFromUserID();
  service.invoke(
    'update',
    {
      "current_date": DateTime.now().toIso8601String(),
      // "device": device,
      "list": data ?? [],
    },
  );
  // timer.cancel();
  service.stopSelf();
  // });
}

// Future<List?> fetchPosts() async {
//   var url =
//       "https://techcrunch.com/wp-json/wp/v2/posts?context=embed&per_page=10&page=1";
//   final uri = Uri.parse(url);
//   print("http request . ____________________>...>>>>>>>>>>");
//   final response = await http.get(uri);
//   print(response.body);
//   if (response.statusCode == 200) {
//     final json = jsonDecode(response.body) as List;
//     return json;
//   } else {
//     return [];
//     //
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  navigate(BuildContext ctx) async {
    // await Future.delayed(const Duration(seconds: 5));
    () => Navigator.pushAndRemoveUntil(
        ctx,
        MaterialPageRoute(
          builder: (context) => const HomeTest(),
        ),
        (route) => false);
  }

  @override
  void initState() {
    navigate(context);
    super.initState();
  }

  String text = "Stop Service";
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BackGroundService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const HomeTest(),
        /*    home: Scaffold(
          body: Center(
            child: SizedBox(
              height: 600,
              child: FlutterLogo(
                style: FlutterLogoStyle.stacked,
              ),
            ),
          ),
          // body: Column(
          //   children: [
          //     StreamBuilder<Map<String, dynamic>?>(
          //       stream: FlutterBackgroundService().on('update'),
          //       builder: (context, snapshot) {
          //         if (!snapshot.hasData) {
          //           return const Center(
          //             child: CircularProgressIndicator(),
          //           );
          //         }
          //
          //         final data = snapshot.data!;
          //         String? device = data["device"];
          //         List? list = data["list"];
          //         DateTime? date = DateTime.tryParse(data["current_date"]);
          //         return Column(
          //           children: [
          //             Text(device ?? 'Unknown'),
          //             Text(date.toString()),
          //             Text("${list?.length}"),
          //           ],
          //         );
          //       },
          //     ),
          //     ElevatedButton(
          //       child: const Text("Foreground Mode"),
          //       onPressed: () {
          //         FlutterBackgroundService().invoke("setAsForeground");
          //       },
          //     ),
          //     ElevatedButton(
          //       child: const Text("Background Mode"),
          //       onPressed: () {
          //         FlutterBackgroundService().invoke("setAsBackground");
          //       },
          //     ),
          //     ElevatedButton(
          //       child: Text(text),
          //       onPressed: () async {
          //         final service = FlutterBackgroundService();
          //         var isRunning = await service.isRunning();
          //         if (isRunning) {
          //           service.invoke("stopService");
          //         } else {
          //           service.startService();
          //         }
          //
          //         if (!isRunning) {
          //           text = 'Stop Service';
          //         } else {
          //           text = 'Start Service';
          //         }
          //         setState(() {});
          //       },
          //     ),
          //     // const Expanded(
          //     //   child: LogView(),
          //     // ),
          //   ],
          // ),
        ),*/
      ),
    );
  }
}

class HomeTest extends StatefulWidget {
  const HomeTest({super.key});

  @override
  State<HomeTest> createState() => _HomeTestState();
}

class _HomeTestState extends State<HomeTest> {
  openIsar() async => context.read<BackGroundService>().openIsarDatabase();
  @override
  void initState() {
    openIsar();
    super.initState();
  }

  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController();
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (page) {
          pageController.jumpToPage(page);
          currentIndex = page;
          setState(() {});
        },
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.data_object), label: "Isar"),
        ],
      ),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          Home(),
          IsarHome(),
        ],
      ),
    );
  }
}
