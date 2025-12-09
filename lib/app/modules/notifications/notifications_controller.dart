import 'package:get/get.dart';
import '../../data/services/notification_service.dart';

class NotificationsController extends GetxController {
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  get notifications => _notificationService.notifications;
  get unreadCount => _notificationService.unreadCount;

  void markAsRead(String id) {
    _notificationService.markAsRead(id);
  }

  void deleteNotification(String id) {
    _notificationService.deleteNotification(id);
  }

  void markAllAsRead() {
    _notificationService.markAllAsRead();
  }

  void clearAll() {
    _notificationService.clearAll();
  }
}
