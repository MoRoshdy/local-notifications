import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_notifications/notification_button_widget.dart';
import 'package:local_notifications/notification_plugin.dart';
import 'package:workmanager/workmanager.dart';

class LocalNotificationScreen extends StatefulWidget {
  const LocalNotificationScreen({super.key});

  @override
  State<LocalNotificationScreen> createState() =>
      _LocalNotificationScreenState();
}

class _LocalNotificationScreenState extends State<LocalNotificationScreen> {
  int count = 0;

  @override
  void initState() {
    notificationPlugin
        .setListenerForLowerVersions(onNotificationInLowerVersions);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Notifications'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NotificationButtonWidget(
                  onPressed: () {
                    notificationPlugin.showNotification();
                  },
                  text: 'Simple Notify'),
              const SizedBox(height: 10,),
              NotificationButtonWidget(
                  onPressed: () {
                    notificationPlugin.showScheduleNotification();
                  },
                  text: 'Schedule Notify'),
              const SizedBox(height: 10,),
              NotificationButtonWidget(
                  onPressed: () {
                    notificationPlugin.showNotificationWithAttachment();
                  },
                  text: 'Notify With Attachment'),
              const SizedBox(height: 10,),
              NotificationButtonWidget(
                  onPressed: () {
                    notificationPlugin.showRepeatedNotification();
                  },
                  text: 'Repeated Notify'),
              const SizedBox(height: 10,),
              NotificationButtonWidget(
                  onPressed: () {
                    notificationPlugin.showDailyNotificationAtTime();
                  },
                  text: 'Daily Notify At Time'),
              const SizedBox(height: 10,),
              NotificationButtonWidget(
                  onPressed: () {
                    notificationPlugin.showWeeklyNotificationAtTime();
                  },
                  text: 'Weekly Notify At Time'),
              const SizedBox(height: 10,),
              NotificationButtonWidget(
                  onPressed: () async {
                    count =
                        await notificationPlugin.getPendingNotificationCount();
                    if (kDebugMode) {
                      print('count of notifications = $count');
                    }
                  },
                  text: 'Count Of Notifications'),
              const SizedBox(height: 10,),
              NotificationButtonWidget(
                  onPressed: () {
                    notificationPlugin.cancelNotification();
                  },
                  text: 'Cancel Specific Notify'),
              const SizedBox(height: 10,),
              NotificationButtonWidget(
                  onPressed: () {
                    notificationPlugin.cancelAllNotification();
                  },
                  text: 'Cancel All Notifications'),

            ],
          ),
        ),
      ),
      bottomSheet: NotificationButtonWidget(
          onPressed: () {
            Workmanager().registerPeriodicTask(
              "0",
              "Periodic Task",
              // When no frequency is provided the default 15 minutes is set.
              // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
              frequency: const Duration(minutes: 15),
              initialDelay: const Duration(seconds: 5),
            );

            Workmanager().registerPeriodicTask(
              "1",
              "Periodic Task at Day",
              // When no frequency is provided the default 15 minutes is set.
              // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
              frequency: const Duration(days: 1),
              initialDelay: const Duration(seconds: 5),
            );
          },
          text:
          'Daily Notify And Every Minute Notify With Work Manger'),
    );
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
    if (kDebugMode) {
      print('=============================');
    }
    if (kDebugMode) {
      print(receivedNotification.body);
    }
  }
}
