import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/theme_service.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Account', theme),
              _buildSettingsCard([
                _buildSettingsTile(
                  Icons.person_outline,
                  'Edit Profile',
                  'Update your name and information',
                  () => controller.editProfile(),
                  theme,
                ),
                _buildDivider(theme),
                _buildSettingsTile(
                  Icons.lock_outline,
                  'Change Password',
                  'Update your password',
                  () => controller.changePassword(),
                  theme,
                ),
                _buildDivider(theme),
                _buildSettingsTile(
                  Icons.delete_outline,
                  'Delete Account',
                  'Permanently delete your account',
                  () => controller.deleteAccount(),
                  theme,
                  textColor: theme.colorScheme.error,
                ),
              ], theme),
              const SizedBox(height: 24),
              _buildSectionHeader('Appearance', theme),
              _buildThemeSelector(theme),
              const SizedBox(height: 24),
              _buildSectionHeader('App Preferences', theme),
              _buildSettingsCard([
                _buildDropdownTile(
                  Icons.directions_car_outlined,
                  'Default Transport Mode',
                  controller.defaultTransportMode,
                  ['Car', 'Metro', 'Microbus', 'Walk'],
                  (value) => controller.setDefaultTransportMode(value!),
                  theme,
                ),
                _buildDivider(theme),
                _buildDropdownTile(
                  Icons.straighten_outlined,
                  'Distance Unit',
                  controller.distanceUnit,
                  ['KM', 'Miles'],
                  (value) => controller.setDistanceUnit(value!),
                  theme,
                ),
                _buildDivider(theme),
                _buildDropdownTile(
                  Icons.attach_money_outlined,
                  'Currency',
                  controller.currency,
                  ['EGP', 'USD', 'EUR', 'GBP'],
                  (value) => controller.setCurrency(value!),
                  theme,
                ),
                _buildDivider(theme),
                _buildDropdownTile(
                  Icons.language_outlined,
                  'Language',
                  controller.language,
                  ['English', 'Arabic'],
                  (value) => controller.setLanguage(value!),
                  theme,
                ),
              ], theme),
              const SizedBox(height: 24),
              _buildSectionHeader('Notifications', theme),
              _buildSettingsCard([
                _buildSwitchTile(
                  Icons.route_outlined,
                  'Route Alerts',
                  'Get notified about your routes',
                  controller.routeAlerts,
                  (value) => controller.toggleRouteAlerts(value),
                  theme,
                ),
                _buildDivider(theme),
                _buildSwitchTile(
                  Icons.savings_outlined,
                  'Savings Notifications',
                  'Updates on money saved',
                  controller.savingsAlerts,
                  (value) => controller.toggleSavingsAlerts(value),
                  theme,
                ),
              ], theme),
              const SizedBox(height: 24),
              _buildSectionHeader('Data & Privacy', theme),
              _buildSettingsCard([
                _buildSettingsTile(
                  Icons.cleaning_services_outlined,
                  'Clear Cache',
                  'Free up storage space',
                  () => controller.clearCache(),
                  theme,
                ),
                _buildDivider(theme),
                _buildSettingsTile(
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  'View our privacy policy',
                  () => controller.openPrivacyPolicy(),
                  theme,
                ),
              ], theme),
              const SizedBox(height: 24),
              _buildSectionHeader('About', theme),
              _buildSettingsCard([
                _buildInfoTile(
                  Icons.info_outline,
                  'App Version',
                  '1.0.0',
                  theme,
                ),
                _buildDivider(theme),
                _buildSettingsTile(
                  Icons.description_outlined,
                  'Terms of Service',
                  'Read our terms',
                  () => controller.openTerms(),
                  theme,
                ),
                _buildDivider(theme),
                _buildSettingsTile(
                  Icons.support_agent_outlined,
                  'Contact Support',
                  'Get help from our team',
                  () => controller.contactSupport(),
                  theme,
                ),
              ], theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
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
              theme: theme,
            ),
            _buildThemeOption(
              icon: Icons.light_mode_rounded,
              label: 'Light',
              isSelected: currentMode == ThemeMode.light,
              onTap: () => ThemeService.to.setTheme(ThemeMode.light),
              theme: theme,
            ),
            _buildThemeOption(
              icon: Icons.dark_mode_rounded,
              label: 'Dark',
              isSelected: currentMode == ThemeMode.dark,
              onTap: () => ThemeService.to.setTheme(ThemeMode.dark),
              theme: theme,
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
    required ThemeData theme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color?.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodySmall?.color, // Secondary text color
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
    VoidCallback onTap,
    ThemeData theme, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? theme.iconTheme.color),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor ?? theme.textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.disabledColor,
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
    ThemeData theme,
  ) {
    return Obx(() => SwitchListTile(
          secondary: Icon(icon, color: theme.iconTheme.color),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall,
          ),
          value: value.value,
          onChanged: onChanged,
          activeTrackColor: theme.colorScheme.primary,
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
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: theme.iconTheme.color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Obx(() => DropdownButton<String>(
                value: currentValue.value,
                dropdownColor: theme.cardColor,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down,
                    color: theme.colorScheme.primary),
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
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

  Widget _buildInfoTile(
      IconData icon, String title, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: theme.iconTheme.color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: theme.dividerColor,
    );
  }
}
