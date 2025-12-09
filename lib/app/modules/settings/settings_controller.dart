import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/currency_service.dart';
import '../../routes/app_routes.dart';
import 'views/change_password_view.dart';
import 'views/privacy_policy_view.dart';
import 'views/terms_of_service_view.dart';

class SettingsController extends GetxController {
  final defaultTransportMode = 'Car'.obs;
  final distanceUnit = 'KM'.obs;
  final currency = 'EGP'.obs;
  final language = 'English'.obs;
  final darkMode = false.obs;

  final routeAlerts = true.obs;
  final savingsAlerts = true.obs;

  final exchangeRate = 1.0.obs;

  final isLoading = false.obs;

  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final currentPasswordError = ''.obs;
  final newPasswordError = ''.obs;

  final _currencyService = CurrencyService();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void resetPasswordFields() {
    isCurrentPasswordVisible.value = false;
    isNewPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    currentPasswordError.value = '';
    newPasswordError.value = '';
  }

  Future<void> loadSettings() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('user_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        defaultTransportMode.value =
            response['default_transport_mode'] ?? 'Car';
        distanceUnit.value = response['distance_unit'] ?? 'KM';
        currency.value = response['currency'] ?? 'EGP';
        language.value = response['language'] ?? 'English';
        darkMode.value = response['dark_mode'] ?? false;
        routeAlerts.value = response['route_alerts'] ?? true;
        savingsAlerts.value = response['savings_alerts'] ?? true;
        exchangeRate.value = (response['exchange_rate'] ?? 1.0).toDouble();

        Get.changeThemeMode(darkMode.value ? ThemeMode.dark : ThemeMode.light);
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('user_preferences').upsert({
        'user_id': user.id,
        'default_transport_mode': defaultTransportMode.value,
        'distance_unit': distanceUnit.value,
        'currency': currency.value,
        'language': language.value,
        'dark_mode': darkMode.value,
        'route_alerts': routeAlerts.value,
        'savings_alerts': savingsAlerts.value,
        'exchange_rate': exchangeRate.value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  void editProfile() {
    Get.toNamed('/profile');
  }

  void changePassword() {
    resetPasswordFields();
    Get.toNamed(Routes.changePassword);
  }

  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.email == null) return;

    currentPasswordError.value = '';
    newPasswordError.value = '';

    isLoading.value = true;

    try {
      final authResponse =
          await Supabase.instance.client.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      if (authResponse.user == null) {
        isLoading.value = false;
        currentPasswordError.value = 'Incorrect current password';
        return;
      }

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      isLoading.value = false;

      Get.dialog(
        const SuccessDialog(),
        barrierDismissible: false,
      );
    } on AuthException catch (e) {
      isLoading.value = false;

      if (e.message.contains('Invalid login credentials') ||
          e.statusCode == '400') {
        currentPasswordError.value = 'Incorrect current password';
      } else if (e.message.toLowerCase().contains('different') ||
          e.message.toLowerCase().contains('same')) {
        newPasswordError.value = 'New password must be different';
      } else if (e.message.toLowerCase().contains('password')) {
        newPasswordError.value = e.message;
      } else {
        newPasswordError.value = e.message;
      }
    } catch (e) {
      isLoading.value = false;
      newPasswordError.value =
          'An unexpected error occurred. Please try again.';
    }
  }

  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> setDefaultTransportMode(String mode) async {
    defaultTransportMode.value = mode;
    await _saveSettings();
  }

  Future<void> setDistanceUnit(String unit) async {
    distanceUnit.value = unit;
    await _saveSettings();
  }

  Future<void> setCurrency(String curr) async {
    currency.value = curr;

    if (curr == 'EGP') {
      exchangeRate.value = 1.0;
    } else {
      final rate = await _currencyService.getExchangeRate('EGP', curr);
      if (rate != null) {
        exchangeRate.value = rate;
      }
    }

    await _saveSettings();
  }

  Future<void> setLanguage(String lang) async {
    language.value = lang;
    await _saveSettings();
  }

  Future<void> toggleDarkMode(bool value) async {
    darkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    await _saveSettings();
  }

  Future<void> toggleRouteAlerts(bool value) async {
    routeAlerts.value = value;
    await _saveSettings();
  }

  Future<void> toggleSavingsAlerts(bool value) async {
    savingsAlerts.value = value;
    await _saveSettings();
  }

  void clearCache() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the cache?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Get.back(), child: const Text('Clear')),
        ],
      ),
    );
  }

  void openPrivacyPolicy() {
    Get.to(() => const PrivacyPolicyView());
  }

  void openTerms() {
    Get.to(() => const TermsOfServiceView());
  }

  void contactSupport() {}
}
