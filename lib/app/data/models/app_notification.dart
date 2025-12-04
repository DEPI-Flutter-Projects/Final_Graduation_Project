import 'package:hive/hive.dart';

part 'app_notification.g.dart';

@HiveType(typeId: 2)
class AppNotification extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final String
      type; 

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}
