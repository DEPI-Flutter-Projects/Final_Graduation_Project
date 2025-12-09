import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: theme.iconTheme.color, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: theme.colorScheme.primary),
            tooltip: 'Mark all as read',
            onPressed: () => controller.markAllAsRead(),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            tooltip: 'Clear all',
            onPressed: () {
              Get.defaultDialog(
                title: 'Clear History',
                middleText:
                    'Are you sure you want to delete all notifications?',
                textConfirm: 'Delete',
                textCancel: 'Cancel',
                confirmTextColor: theme.colorScheme.onError,
                buttonColor: theme.colorScheme.error,
                backgroundColor: theme.cardColor,
                titleStyle: theme.textTheme.titleLarge,
                middleTextStyle: theme.textTheme.bodyMedium,
                onConfirm: () {
                  controller.clearAll();
                  Get.back();
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  Text(
                    'No notifications yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll let you know when something happens',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
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
              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.delete, color: theme.colorScheme.onError),
                ),
                onDismissed: (direction) {
                  controller.deleteNotification(notification.id);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? theme.cardColor
                        : theme.colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notification.isRead
                          ? Colors.transparent
                          : theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getIconColor(notification.type, theme)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIcon(notification.type),
                        color: _getIconColor(notification.type, theme),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timeago.format(notification.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => controller.markAsRead(notification.id),
                  ),
                ).animate().fadeIn(delay: (50 * index).ms).slideX(),
              );
            },
          );
        }),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'level_up':
        return Icons.star_rounded;
      case 'savings':
        return Icons.savings_rounded;
      case 'navigation':
        return Icons.navigation_rounded;
      case 'maintenance':
        return Icons.build_rounded;
      case 'system':
        return Icons.info_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String type, ThemeData theme) {
    switch (type) {
      case 'level_up':
        return Colors.amber;
      case 'savings':
        return Colors.green;
      case 'navigation':
        return theme.colorScheme.primary;
      case 'maintenance':
        return Colors.orange;
      case 'system':
        return Colors.blue;
      default:
        return theme.disabledColor;
    }
  }
}
