import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../models/app_notification.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late Box<AppNotification> _notificationsBox;
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }

  Future<NotificationService> init() async {
    await _initNotifications();
    return this;
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AppNotificationAdapter());
    }
    _notificationsBox = await Hive.openBox<AppNotification>('notifications');
    _loadNotifications();

    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        
        
      },
    );

    await _createNotificationChannel();
    await requestPermissions();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'elmoshwar_notifications_v3', 
      'El-Moshwar Alerts', 
      description: 'Navigation and system alerts', 
      importance: Importance.max, 
      playSound: true,
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> requestPermissions() async {
    
    final status = await Permission.notification.request();
    if (status.isDenied) {
      
      debugPrint('Notification permission denied');
    }

    
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _loadNotifications() {
    notifications.assignAll(_notificationsBox.values.toList().reversed);
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required String type,
    String? payload,
  }) async {
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'elmoshwar_notifications_v3', 
      'El-Moshwar Alerts',
      channelDescription: 'Navigation and system alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true, 
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
    );

    await _notificationsBox.add(notification);
    notifications.insert(0, notification);
    _updateUnreadCount();
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final notification = notifications[index];
      notification.isRead = true;
      await notification.save();
      notifications[index] = notification; 
      _updateUnreadCount();
    }
  }

  Future<void> markAllAsRead() async {
    for (var notification in notifications) {
      if (!notification.isRead) {
        notification.isRead = true;
        await notification.save();
      }
    }
    notifications.refresh();
    _updateUnreadCount();
  }

  Future<void> clearAll() async {
    await _notificationsBox.clear();
    notifications.clear();
    _updateUnreadCount();
  }
}
