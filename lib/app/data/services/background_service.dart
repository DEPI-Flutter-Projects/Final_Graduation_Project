import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String taskName = 'inactivityCheck';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == taskName) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'elmoshwar_notifications_v2',
        'El-Moshwar Alerts',
        channelDescription: 'Navigation and system alerts',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        999,
        'We miss you! 🚗',
        'It\'s been a while. Ready for your next trip?',
        platformChannelSpecifics,
      );
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );

    await Workmanager().registerPeriodicTask(
      '1',
      taskName,
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
