import 'dart:io';
import 'dart:math';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart';


List<String> names = ['mohamed', 'ahmed' ,'mahmoud','waleed','aria', 'ali'];

int randomIndex= Random().nextInt(names.length-1);

class NotificationPlugin {
   InitializationSettings initializationSettings = const InitializationSettings();

  final BehaviorSubject<ReceivedNotification>
      didReceiveLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();

  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationPlugin._() {
    init();
  }

  init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecific();
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          sound: true,
          badge: true,
          alert: false,
        );
  }

  initializePlatformSpecific() async {
    _configureLocalTimezone();

    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/notification_icon');

    DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings(
            defaultPresentAlert: true,
            defaultPresentBadge: true,
            defaultPresentSound: false,
            onDidReceiveLocalNotification: (id, title, body, payload) {
              ReceivedNotification receivedNotification = ReceivedNotification(id: id, title: title, body: body, payload: payload);
              didReceiveLocalNotificationSubject.add(receivedNotification);
            });

    initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    WidgetsFlutterBinding.ensureInitialized();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) {
          print("===========${details.payload}");
        }
      },
    );
  }


  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceiveLocalNotificationSubject.stream.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  Future<void> showNotification() async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "com.example.local_notifications",
      "Local Notification",
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    DarwinNotificationDetails iOSNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
        randomIndex, 'name', names[randomIndex], notificationDetails,
        payload: 'Payload Test');
  }

  Future<void> showScheduleNotification() async {

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "com.example.local_notifications",
      "Local Notification",
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    DarwinNotificationDetails iOSNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        'Title Test',
        'Body Test',
        _nextInstanceOfTenAM(const Time(00,41)),
        notificationDetails,
        payload: 'Payload Test',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

   tz.TZDateTime _nextInstanceOfTenAM(Time time) {
     final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
     tz.TZDateTime scheduledDate =
     tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour,time.minute,time.second);
     if (scheduledDate.isBefore(now)) {
       scheduledDate = scheduledDate.add(const Duration(days: 1));
     }
     return scheduledDate;
   }

   Future<void> _configureLocalTimezone() async {
     final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
     tz.setLocalLocation(getLocation(timeZone));
   }

  Future<void> showNotificationWithAttachment() async {
    String attachmentPicturePath = await _downloadAndSaveFile(
        'https://via.placeholder.com/800x200', 'attachment_img.jpg');

    BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(FilePathAndroidBitmap(attachmentPicturePath),contentTitle: 'AttachedImage',summaryText: 'Test Image');

    AndroidNotificationDetails androidNotificationDetails =
     AndroidNotificationDetails(
      "com.example.local_notifications",
      "Local Notification",
      playSound: true,
      styleInformation: bigPictureStyleInformation,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    DarwinNotificationDetails iOSNotificationDetails =
     DarwinNotificationDetails(
       attachments: [DarwinNotificationAttachment(attachmentPicturePath)],
     );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
        2, 'Title Test', 'Body Test', notificationDetails,
        payload: 'Payload Test');
  }

  _downloadAndSaveFile(String url, String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/$fileName';
    Response response = await http.get(Uri.parse(url));
    File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> showRepeatedNotification() async {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails(
      "com.example.local_notifications",
      "Local Notification",
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    DarwinNotificationDetails iOSNotificationDetails =
    const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.periodicallyShow(
        3, 'Title Test', 'Body Test', RepeatInterval.everyMinute,notificationDetails,
        payload: 'Payload Test');
  }

  Future<void> showDailyNotificationAtTime() async {

    AndroidNotificationDetails androidNotificationDetails =
     const AndroidNotificationDetails(
      "com.example.local_notifications",
      "Local Notification",
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    DarwinNotificationDetails iOSNotificationDetails =
     const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
        4,
        'Title Test',
        'Body Test',
        _nextInstanceOfTenAM( const Time(12,18)),
        notificationDetails,
        payload: 'Payload Test',
      androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,

    );
  }


  Future<void> showWeeklyNotificationAtTime() async {

    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails(
      "com.example.local_notifications",
      "Local Notification",
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    DarwinNotificationDetails iOSNotificationDetails =
    const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      5,
      'Title Test',
      'Body Test',
      _nextInstanceOfTenAM(const Time(10,42)),
      notificationDetails,
      payload: 'Payload Test',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,

    );
  }


  Future<int> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p.length;
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(3);
  }

  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

NotificationPlugin notificationPlugin = NotificationPlugin._();

class ReceivedNotification {
  final int? id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification(
      {required this.id,
      required this.title,
      required this.body,
      required this.payload});
}
