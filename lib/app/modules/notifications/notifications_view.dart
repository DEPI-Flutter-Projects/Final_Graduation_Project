import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import 'notifications_controller.dart';
import '../../data/models/app_notification.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimaryLight, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColors.primary),
            tooltip: 'Mark all as read',
            onPressed: controller.markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Clear all',
            onPressed: () {
              Get.defaultDialog(
                title: 'Clear Notifications',
                middleText:
                    'Are you sure you want to delete all notifications?',
                textConfirm: 'Clear',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  controller.clearAll();
                  Get.back();
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationItem(notification);
          },
        );
      }),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        
        
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        color: notification.isRead
            ? Colors.white
            : AppColors.primary.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notification.isRead
                ? Colors.transparent
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getTypeColor(notification.type).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(notification.type),
              color: _getTypeColor(notification.type),
              size: 24,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight:
                  notification.isRead ? FontWeight.normal : FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                notification.body,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM d, h:mm a').format(notification.timestamp),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          onTap: () => controller.markAsRead(notification.id),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'level_up':
        return Colors.purple;
      case 'savings':
        return Colors.green;
      case 'navigation':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'system':
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'level_up':
        return Icons.military_tech;
      case 'savings':
        return Icons.savings;
      case 'navigation':
        return Icons.navigation;
      case 'maintenance':
        return Icons.build;
      case 'system':
      default:
        return Icons.notifications;
    }
  }
}
