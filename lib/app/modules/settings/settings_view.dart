import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/theme_service.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryLight),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildSectionHeader('Account'),
            _buildSettingsCard([
              _buildSettingsTile(
                Icons.person_outline,
                'Edit Profile',
                'Update your name and information',
                () => controller.editProfile(),
              ),
              _buildDivider(),
              _buildSettingsTile(
                Icons.lock_outline,
                'Change Password',
                'Update your password',
                () => controller.changePassword(),
              ),
              _buildDivider(),
              _buildSettingsTile(
                Icons.delete_outline,
                'Delete Account',
                'Permanently delete your account',
                () => controller.deleteAccount(),
                textColor: AppColors.error,
              ),
            ]),

            const SizedBox(height: 24),

            
            _buildSectionHeader('Appearance'),
            _buildThemeSelector(),
            const SizedBox(height: 24),

            _buildSectionHeader('App Preferences'),
            _buildSettingsCard([
              _buildDropdownTile(
                Icons.directions_car_outlined,
                'Default Transport Mode',
                controller.defaultTransportMode,
                ['Car', 'Metro', 'Microbus', 'Walk'],
                (value) => controller.setDefaultTransportMode(value!),
              ),
              _buildDivider(),
              _buildDropdownTile(
                Icons.straighten_outlined,
                'Distance Unit',
                controller.distanceUnit,
                ['KM', 'Miles'],
                (value) => controller.setDistanceUnit(value!),
              ),
              _buildDivider(),
              _buildDropdownTile(
                Icons.attach_money_outlined,
                'Currency',
                controller.currency,
                ['EGP', 'USD', 'EUR', 'GBP'],
                (value) => controller.setCurrency(value!),
              ),
              _buildDivider(),
              _buildDropdownTile(
                Icons.language_outlined,
                'Language',
                controller.language,
                ['English', 'Arabic'],
                (value) => controller.setLanguage(value!),
              ),
            ]),

            const SizedBox(height: 24),

            
            _buildSectionHeader('Notifications'),
            _buildSettingsCard([
              _buildSwitchTile(
                Icons.route_outlined,
                'Route Alerts',
                'Get notified about your routes',
                controller.routeAlerts,
                (value) => controller.toggleRouteAlerts(value),
              ),
              _buildDivider(),
              _buildSwitchTile(
                Icons.savings_outlined,
                'Savings Notifications',
                'Updates on money saved',
                controller.savingsAlerts,
                (value) => controller.toggleSavingsAlerts(value),
              ),
            ]),

            const SizedBox(height: 24),

            
            _buildSectionHeader('Data & Privacy'),
            _buildSettingsCard([
              _buildSettingsTile(
                Icons.cleaning_services_outlined,
                'Clear Cache',
                'Free up storage space',
                () => controller.clearCache(),
              ),
              _buildDivider(),
              _buildSettingsTile(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                'View our privacy policy',
                () => controller.openPrivacyPolicy(),
              ),
            ]),

            const SizedBox(height: 24),

            
            _buildSectionHeader('About'),
            _buildSettingsCard([
              _buildInfoTile(
                Icons.info_outline,
                'App Version',
                '1.0.0',
              ),
              _buildDivider(),
              _buildSettingsTile(
                Icons.description_outlined,
                'Terms of Service',
                'Read our terms',
                () => controller.openTerms(),
              ),
              _buildDivider(),
              _buildSettingsTile(
                Icons.support_agent_outlined,
                'Contact Support',
                'Get help from our team',
                () => controller.contactSupport(),
              ),
            ]),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(Get.context!).dividerColor),
      ),
      child: Obx(() {
        final currentMode = ThemeService.to.themeMode;
        return Row(
          children: [
            _buildThemeOption(
              icon: Icons.brightness_auto,
              label: 'System',
              isSelected: currentMode == ThemeMode.system,
              onTap: () => ThemeService.to.setTheme(ThemeMode.system),
            ),
            _buildThemeOption(
              icon: Icons.light_mode_rounded,
              label: 'Light',
              isSelected: currentMode == ThemeMode.light,
              onTap: () => ThemeService.to.setTheme(ThemeMode.light),
            ),
            _buildThemeOption(
              icon: Icons.dark_mode_rounded,
              label: 'Dark',
              isSelected: currentMode == ThemeMode.dark,
              onTap: () => ThemeService.to.setTheme(ThemeMode.dark),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.accent
                    : Theme.of(Get.context!)
                        .iconTheme
                        .color!
                        .withValues(alpha: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.accent
                      : Theme.of(Get.context!).textTheme.bodySmall!.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondaryLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textPrimaryLight),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondaryLight,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textTertiaryLight,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    RxBool value,
    Function(bool) onChanged,
  ) {
    return Obx(() => SwitchListTile(
          secondary: Icon(icon, color: AppColors.textPrimaryLight),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
          value: value.value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ));
  }

  Widget _buildDropdownTile(
    IconData icon,
    String title,
    RxString currentValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimaryLight),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          Obx(() => DropdownButton<String>(
                value: currentValue.value,
                underline: const SizedBox(),
                icon:
                    const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              )),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimaryLight),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: AppColors.divider,
    );
  }
}
