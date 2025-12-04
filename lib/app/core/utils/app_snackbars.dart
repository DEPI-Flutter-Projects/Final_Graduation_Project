import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class AppSnackbars {
  static DateTime? _lastSnackbarTime;
  static const Duration _debounceDuration = Duration(milliseconds: 2000);

  static bool _shouldShow() {
    final now = DateTime.now();
    if (_lastSnackbarTime != null &&
        now.difference(_lastSnackbarTime!) < _debounceDuration) {
      return false;
    }
    _lastSnackbarTime = now;
    return true;
  }

  static void showSuccess(String title, String message) {
    if (!_shouldShow()) return;
    Get.closeAllSnackbars(); 
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
      borderRadius: 12,
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimaryLight,
      icon: const Icon(Icons.check_circle, color: AppColors.success, size: 28),
      shouldIconPulse: true,
      leftBarIndicatorColor: AppColors.success,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      duration: const Duration(seconds: 4),
    );
  }

  static void showError(String title, String message) {
    if (!_shouldShow()) return;
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimaryLight,
      icon: const Icon(Icons.error, color: AppColors.error, size: 28),
      shouldIconPulse: true,
      leftBarIndicatorColor: AppColors.error,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      duration: const Duration(seconds: 4),
    );
  }

  static void showWarning(String title, String message) {
    if (!_shouldShow()) return;
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimaryLight,
      icon: const Icon(Icons.warning_amber_rounded,
          color: AppColors.warning, size: 28),
      shouldIconPulse: true,
      leftBarIndicatorColor: AppColors.warning,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimaryLight,
      icon: const Icon(Icons.info_outline, color: AppColors.primary, size: 28),
      shouldIconPulse: true,
      leftBarIndicatorColor: AppColors.primary,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      duration: const Duration(seconds: 3),
    );
  }
}
