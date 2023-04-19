import 'package:flutter/material.dart';
import 'package:local_notifications/local_notifications_screen.dart';
import 'package:local_notifications/notification_plugin.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';


@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  notificationPlugin.initializePlatformSpecific();

  Workmanager().executeTask((task, inputData) {
    notificationPlugin.showNotification();
    return Future.value(true);
  });
}

Future<void> main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LocalNotificationScreen(),
    );
  }
}


