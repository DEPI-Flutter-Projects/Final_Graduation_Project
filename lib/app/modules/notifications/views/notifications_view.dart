import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
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
            onPressed: () => controller.markAllAsRead(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Clear all',
            onPressed: () {
              Get.defaultDialog(
                title: 'Clear History',
                middleText:
                    'Are you sure you want to delete all notifications?',
                textConfirm: 'Delete',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                buttonColor: AppColors.error,
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
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_off_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  'No notifications yet',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll let you know when something happens',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
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
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                
                
                
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? Colors.white
                      : AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: notification.isRead
                        ? Colors.transparent
                        : AppColors.primary.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
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
                      color: _getIconColor(notification.type)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(notification.type),
                      color: _getIconColor(notification.type),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: GoogleFonts.outfit(
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondaryLight,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeago.format(notification.timestamp),
                        style: GoogleFonts.outfit(
                          color: AppColors.textTertiaryLight,
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

  Color _getIconColor(String type) {
    switch (type) {
      case 'level_up':
        return Colors.amber;
      case 'savings':
        return AppColors.success;
      case 'navigation':
        return AppColors.primary;
      case 'maintenance':
        return Colors.orange;
      case 'system':
        return Colors.blue;
      default:
        return AppColors.textSecondaryLight;
    }
  }
}
