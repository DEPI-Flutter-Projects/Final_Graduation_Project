import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../settings/settings_controller.dart';
import 'route_planner_controller.dart';

class RoutePlannerView extends GetView<RoutePlannerController> {
  const RoutePlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Plan New Route',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: theme.iconTheme,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transportation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Row(
                    children: [
                      _buildTransportCard(
                        'Car',
                        Icons.directions_car,
                        controller.selectedTransportMode.value == 'Car',
                      ),
                      const SizedBox(width: 12),
                      _buildTransportCard(
                        'Metro',
                        Icons.subway,
                        controller.selectedTransportMode.value == 'Metro',
                      ),
                      const SizedBox(width: 12),
                      _buildTransportCard(
                        'Microbus',
                        Icons.directions_bus,
                        controller.selectedTransportMode.value == 'Microbus',
                      ),
                    ],
                  )),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.selectedTransportMode.value == 'Car') {
                  return _buildCarOptions();
                } else if (controller.selectedTransportMode.value == 'Metro') {
                  return _buildMetroOptions();
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.route, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Route Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Start Location',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.startLocationController,
                      readOnly: true,
                      onTap: () => controller.pickLocation(true),
                      decoration: InputDecoration(
                        hintText: 'Enter start location',
                        prefixIcon: const Icon(Icons.my_location,
                            size: 20, color: AppColors.success),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.map,
                                  size: 20, color: AppColors.primary),
                              onPressed: () => controller.pickLocation(true),
                              tooltip: 'Pick on Map',
                            ),
                            Obx(() => controller.isLocating.value
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.gps_fixed, size: 20),
                                    onPressed: controller.useCurrentLocation,
                                    tooltip: 'Use Current Location',
                                  )),
                          ],
                        ),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => controller.stops.length < 5
                        ? Center(
                            child: OutlinedButton.icon(
                              onPressed: controller.addStop,
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(
                                'Add Stop (${controller.stops.length}/5)',
                                style: const TextStyle(fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                side: BorderSide(
                                    color: theme.colorScheme.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                            ),
                          )
                        : const SizedBox.shrink()),
                    Obx(() => Column(
                          children:
                              controller.stops.asMap().entries.map((entry) {
                            int index = entry.key;
                            var stop = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: TextField(
                                controller: stop,
                                readOnly: true,
                                onTap: () => controller.pickLocation(false,
                                    stopIndex: index),
                                decoration: InputDecoration(
                                  hintText: 'Stop ${index + 1}',
                                  prefixIcon: const Icon(
                                      Icons.location_on_outlined,
                                      size: 20),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.map,
                                            size: 20, color: AppColors.primary),
                                        onPressed: () =>
                                            controller.pickLocation(false,
                                                stopIndex: index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 20),
                                        onPressed: () =>
                                            controller.removeStop(index),
                                      ),
                                    ],
                                  ),
                                  filled: true,
                                  fillColor: theme.scaffoldBackgroundColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                              ),
                            );
                          }).toList(),
                        )),
                    const SizedBox(height: 16),
                    Text(
                      'End Location',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.endLocationController,
                      readOnly: true,
                      onTap: () => controller.pickLocation(false),
                      decoration: InputDecoration(
                        hintText: 'Enter end location',
                        prefixIcon: const Icon(Icons.location_on,
                            size: 20, color: AppColors.error),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.map,
                              size: 20, color: AppColors.primary),
                          onPressed: () => controller.pickLocation(false),
                          tooltip: 'Pick on Map',
                        ),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton(
                            onPressed: controller.isCalculating.value
                                ? null
                                : controller.calculateRoute,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isCalculating.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calculate, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Calculate Route',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() {
                  if (controller.routeResult.value == null) {
                    return Column(
                      children: [
                        const Text(
                          'Route Results',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Icon(
                          Icons.alt_route_outlined,
                          size: 64,
                          color: AppColors.textTertiaryLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enter start and end locations to calculate route',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Route Results',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultRow('Mode',
                          controller.routeResult.value!['mode'] ?? 'Unknown'),
                      _buildResultRow('Distance',
                          '${controller.routeResult.value!['distance']} km'),
                      _buildResultRow('Duration',
                          '${controller.routeResult.value!['duration']} min'),
                      _buildResultRow('Estimated Cost',
                          controller.routeResult.value!['cost']),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.startNavigation,
                          icon: const Icon(Icons.navigation),
                          label: const Text('Start Navigation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: controller.scrollToTop,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.textTheme.bodyMedium?.color,
                            side: BorderSide(color: theme.dividerColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Edit Route',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.shareRoute,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            foregroundColor: theme.textTheme.bodyLarge?.color,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Share Route',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.bodyLarge?.color)),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransportCard(String title, IconData icon, bool isSelected) {
    final theme = Get.theme;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setTransportMode(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? theme.colorScheme.primary : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarOptions() {
    final theme = Get.theme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Vehicle',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => InkWell(
                onTap: controller.selectVehicle,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: controller.selectedVehicle.value != null
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: controller.selectedVehicle.value != null
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: controller.selectedVehicle.value != null
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.selectedVehicle.value?['name'] ??
                                  'Select Vehicle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: controller.selectedVehicle.value != null
                                    ? theme.textTheme.bodyLarge?.color
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            if (controller.selectedVehicle.value != null)
                              Text(
                                '${controller.selectedVehicle.value!['efficiency']} KM/L • ${controller.selectedVehicle.value!['fuel']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: theme.disabledColor),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMetroOptions() {
    final theme = Get.theme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildExpandedPreference('Fastest'),
              const SizedBox(width: 8),
              _buildExpandedPreference('Cheapest'),
              const SizedBox(width: 8),
              _buildExpandedPreference('Least Stations'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedPreference(String label) {
    final theme = Get.theme;
    return Expanded(
      child: Obx(() {
        final isSelected = controller.metroPreference.value == label;
        return GestureDetector(
          onTap: () => controller.metroPreference.value = label,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isSelected ? theme.colorScheme.primary : theme.dividerColor,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResultRow(String label, String value) {
    final theme = Get.theme;
    String displayValue = value;

    if (label == 'Estimated Cost') {
      try {
        final settings = Get.find<SettingsController>();
        final currency = settings.currency.value;
        final rate = settings.exchangeRate.value;

        final costStr = value.replaceAll(RegExp(r'[^0-9.]'), '');
        final cost = double.parse(costStr);

        displayValue = '$currency ${(cost * rate).toStringAsFixed(2)}';
      } catch (e) {
        // Ignored
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
