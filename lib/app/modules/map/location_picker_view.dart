import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../core/theme/app_colors.dart';
import 'location_picker_controller.dart';

class LocationPickerView extends GetView<LocationPickerController> {
  const LocationPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LocationPickerController());
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Obx(() => FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: controller.selectedLocation.value,
                  initialZoom: 13.0,
                  onTap: controller.onMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate: controller.getTileUrl(),
                    userAgentPackageName: 'com.elmoshwar.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: controller.selectedLocation.value,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context)
                              .shadowColor
                              .withValues(alpha: 0.1),
                          blurRadius: 4)
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .shadowColor
                                .withValues(alpha: 0.1),
                            blurRadius: 4)
                      ],
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: controller.searchLocation,
                        ),
                      ),
                      onSubmitted: (_) => controller.searchLocation(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 80,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color:
                          Theme.of(context).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 4)
                ],
              ),
              child: Column(
                children: [
                  _buildModeButton(
                      context, MapMode.normal, Icons.map_outlined, controller),
                  const Divider(height: 1),
                  _buildModeButton(context, MapMode.satellite,
                      Icons.satellite_alt, controller),
                  const Divider(height: 1),
                  _buildModeButton(
                      context, MapMode.terrain, Icons.terrain, controller),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 230,
            child: FloatingActionButton(
              heroTag: 'my_location',
              onPressed: controller.goToCurrentLocation,
              backgroundColor: Theme.of(context).cardColor,
              mini: true,
              child: Icon(Icons.my_location,
                  color: Theme.of(context).iconTheme.color),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color:
                          Theme.of(context).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2))
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.selectedAddress.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (controller.isLoading.value)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        )),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirm Location',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(BuildContext context, MapMode mode, IconData icon,
      LocationPickerController controller) {
    return Obx(() {
      final isSelected = controller.currentMapMode.value == mode;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.setMapMode(mode),
          child: Container(
            padding: const EdgeInsets.all(10),
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
            child: Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
              size: 24,
            ),
          ),
        ),
      );
    });
  }
}
