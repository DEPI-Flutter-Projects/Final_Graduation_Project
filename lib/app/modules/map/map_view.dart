import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'map_controller.dart' as app_map;

class MapView extends GetView<app_map.MapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? Colors.transparent,
        elevation: 0,
        title: Text(
          'Map View',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Obx(() {
            return FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.currentLatLng.value,
                initialZoom: 13.0,
                onTap: (tapPos, point) {
                  controller.addMarker(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _getTileUrl(controller.mapStyle.value),
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.elmoshwar.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.routePoints,
                      strokeWidth: 4.0,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: controller.markers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final point = entry.value;

                    return Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: controller.currentLatLng.value,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.navigation,
                            color: AppColors.primary, size: 30),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'rotate_map',
                  onPressed: controller.rotateMap,
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Theme.of(context).iconTheme.color,
                  child: const Icon(Icons.rotate_right),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'style_toggle',
                  onPressed: controller.toggleMapStyle,
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Theme.of(context).iconTheme.color,
                  child: const Icon(Icons.layers_outlined),
                ),
                const SizedBox(height: 8),
                Obx(() => FloatingActionButton.small(
                      heroTag: 'track_location',
                      onPressed: controller.toggleTracking,
                      backgroundColor: controller.isTracking.value
                          ? AppColors.primary
                          : Theme.of(context).cardColor,
                      foregroundColor: controller.isTracking.value
                          ? Colors.white
                          : Theme.of(context).iconTheme.color,
                      child: Icon(controller.isTracking.value
                          ? Icons.gps_fixed
                          : Icons.gps_not_fixed),
                    )),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'clear_markers',
                  onPressed: controller.clearMarkers,
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: AppColors.error,
                  child: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Obx(() {
              if (controller.routePoints.isEmpty) {
                return const SizedBox.shrink();
              }

              return SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .shadowColor
                            .withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(
                            Icons.timer_outlined,
                            controller.remainingTime.value,
                            'Time',
                            context,
                          ),
                          Container(
                              height: 40,
                              width: 1,
                              color: Theme.of(context).dividerColor),
                          _buildInfoItem(
                            Icons.directions_car_outlined,
                            controller.remainingDistance.value,
                            'Distance',
                            context,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.launchMaps,
                          icon: const Icon(Icons.map),
                          label: const Text('Start Navigation (Google Maps)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      IconData icon, String value, String label, BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  String _getTileUrl(String style) {
    switch (style) {
      case 'Terrain':
        return "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png";
      case 'Dark':
        return "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png";
      case 'Normal':
      default:
        return "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
    }
  }
}
