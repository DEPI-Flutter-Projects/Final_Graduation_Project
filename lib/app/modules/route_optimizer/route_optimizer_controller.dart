import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/location_controller.dart';
import '../../routes/app_routes.dart';
import '../map/location_picker_view.dart';
import '../map/map_controller.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum StopPriority { low, medium, high }

class RouteStop {
  String id;
  String name;
  String? address;
  double? lat;
  double? lng;
  String type;
  StopPriority priority;
  Color color;
  TimeOfDay? timeConstraint;
  String? visitAfterId;

  RouteStop({
    required this.id,
    required this.name,
    this.address,
    this.lat,
    this.lng,
    this.type = 'Other',
    this.priority = StopPriority.medium,
    this.color = Colors.blue,
    this.timeConstraint,
    this.visitAfterId,
  });

  RouteStop copyWith() {
    return RouteStop(
      id: id,
      name: name,
      address: address,
      lat: lat,
      lng: lng,
      type: type,
      priority: priority,
      color: color,
      timeConstraint: timeConstraint,
      visitAfterId: visitAfterId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'type': type,
      'address': address,
      'visitAfterId': visitAfterId,
    };
  }
}

class RouteOptimizerController extends GetxController {
  final LocationController locationController = Get.find<LocationController>();

  final stops = <RouteStop>[].obs;
  final originalStops = <RouteStop>[].obs;
  final isOptimizing = false.obs;
  final isOptimized = false.obs;
  final optimizationCriteria = 'Distance'.obs;

  final shortcuts = <Map<String, dynamic>>[
    {'name': 'Home', 'icon': Icons.home, 'color': Colors.blue, 'type': 'Home'},
    {
      'name': 'Work',
      'icon': Icons.work,
      'color': Colors.orange,
      'type': 'Work'
    },
    {
      'name': 'Gym',
      'icon': Icons.fitness_center,
      'color': Colors.purple,
      'type': 'Other'
    },
    {
      'name': 'Market',
      'icon': Icons.shopping_cart,
      'color': Colors.green,
      'type': 'Shop'
    },
  ].obs;

  final _deletedStops = <RouteStop>[];

  late Box box;

  @override
  void onInit() {
    super.onInit();
    box = Hive.box('route_optimizer');

    if (box.containsKey('current_stops')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showRestoreDialog();
        });
      });
    }
  }

  void addStop(
      {String? name,
      String? type,
      Color? color,
      double? lat,
      double? lng,
      String? address}) {
    if (lat != null && lng != null) {
      final duplicate =
          stops.firstWhereOrNull((s) => s.lat == lat && s.lng == lng);

      if (duplicate != null) {
        Get.dialog(
          AlertDialog(
            title: const Text('Duplicate Location'),
            content: Text(
                'This location is already added as "${duplicate.name}". Do you want to revisit it?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  _addStopInternal(
                      name: name,
                      type: type,
                      color: color,
                      lat: lat,
                      lng: lng,
                      address: address);
                },
                child: const Text('Add Anyway'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  _showRevisitDialog(
                      name: name,
                      type: type,
                      color: color,
                      lat: lat,
                      lng: lng,
                      address: address);
                },
                child: const Text('Revisit After...'),
              ),
            ],
          ),
        );
        return;
      }
    }

    _addStopInternal(
        name: name,
        type: type,
        color: color,
        lat: lat,
        lng: lng,
        address: address);
  }

  void _addStopInternal(
      {String? name,
      String? type,
      Color? color,
      double? lat,
      double? lng,
      String? address,
      String? visitAfterId}) {
    final id = const Uuid().v4();
    stops.add(RouteStop(
      id: id,
      name: name ?? 'New Stop',
      type: type ?? 'Other',
      color: color ?? _getRandomColor(),
      lat: lat,
      lng: lng,
      address: address,
      visitAfterId: visitAfterId,
    ));
    isOptimized.value = false;
    _saveSession();
  }

  void _showRevisitDialog(
      {String? name,
      String? type,
      Color? color,
      double? lat,
      double? lng,
      String? address}) {
    String? selectedStopId;
    Get.dialog(
      AlertDialog(
        title: const Text('Revisit After Which Stop?'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final stop = stops[index];
              return ListTile(
                title: Text(stop.name),
                subtitle: Text(stop.address ?? 'No address'),
                onTap: () {
                  selectedStopId = stop.id;
                  Get.back();
                  _addStopInternal(
                      name: name,
                      type: type,
                      color: color,
                      lat: lat,
                      lng: lng,
                      address: address,
                      visitAfterId: selectedStopId);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> addShortcut(Map<String, dynamic> shortcut) async {
    if (shortcut.containsKey('lat') && shortcut.containsKey('lng')) {
      addStop(
        name: shortcut['name'],
        type: shortcut['type'],
        color: shortcut['color'],
        lat: shortcut['lat'],
        lng: shortcut['lng'],
        address: shortcut['address'],
      );
    } else {
      final result = await Get.dialog(
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const SizedBox(
              width: double.infinity,
              height: 500,
              child: LocationPickerView(),
            ),
          ),
        ),
      );

      if (result != null && result is Map) {
        final LatLng coords = result['coordinates'];
        final String address = result['address'];

        addStop(
          name: shortcut['name'],
          type: shortcut['type'],
          color: shortcut['color'],
          lat: coords.latitude,
          lng: coords.longitude,
          address: address,
        );
      } else {
        addStop(
          name: shortcut['name'],
          type: shortcut['type'],
          color: shortcut['color'],
        );
      }
    }
  }

  void removeStop(String id) {
    final index = stops.indexWhere((stop) => stop.id == id);
    if (index != -1) {
      final stop = stops[index];
      _deletedStops.add(stop);
      stops.removeAt(index);
      isOptimized.value = false;
      _saveSession();

      Get.snackbar(
        'Stop Removed',
        '${stop.name} has been removed',
        mainButton: TextButton(
          onPressed: undoDelete,
          child: const Text('UNDO', style: TextStyle(color: Colors.white)),
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade900,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        overlayBlur: 0,
        icon: const Icon(Icons.delete_outline, color: Colors.white),
      );
    }
  }

  void undoDelete() {
    if (_deletedStops.isNotEmpty) {
      final stop = _deletedStops.removeLast();
      stops.add(stop);
      isOptimized.value = false;
      _saveSession();
    }
  }

  void reorderStops(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final RouteStop item = stops.removeAt(oldIndex);
    stops.insert(newIndex, item);
    isOptimized.value = false;
    _saveSession();
  }

  void updateStopDetails(String id,
      {TimeOfDay? time,
      StopPriority? priority,
      String? name,
      String? address,
      double? lat,
      double? lng}) {
    final index = stops.indexWhere((stop) => stop.id == id);
    if (index != -1) {
      if (time != null) stops[index].timeConstraint = time;
      if (priority != null) stops[index].priority = priority;
      if (name != null) stops[index].name = name;
      if (address != null) stops[index].address = address;
      if (lat != null && lng != null) {
        stops[index].lat = lat;
        stops[index].lng = lng;
      }
      stops.refresh();
      isOptimized.value = false;
      _saveSession();
    }
  }

  void toggleStopPriority(String id) {
    final index = stops.indexWhere((stop) => stop.id == id);
    if (index != -1) {
      final current = stops[index].priority;
      final next =
          StopPriority.values[(current.index + 1) % StopPriority.values.length];
      stops[index].priority = next;
      stops.refresh();
      isOptimized.value = false;
      _saveSession();
    }
  }

  Future<void> optimizeRoute() async {
    if (stops.length < 2) {
      Get.snackbar(
        'Not enough stops',
        'Please add at least 2 stops to optimize.',
        backgroundColor: Colors.orange.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        overlayBlur: 0,
      );
      return;
    }

    isOptimizing.value = true;

    if (!isOptimized.value) {
      originalStops.assignAll(stops.map((s) => s.copyWith()).toList());
    } else {
      stops.assignAll(originalStops.map((s) => s.copyWith()).toList());
    }

    await Future.delayed(const Duration(seconds: 1));

    final validStops =
        stops.where((s) => s.lat != null && s.lng != null).toList();
    final invalidStops =
        stops.where((s) => s.lat == null || s.lng == null).toList();

    if (validStops.isEmpty) {
      stops.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    } else {
      List<RouteStop> optimizedOrder = [];

      final start = validStops.first;
      final end = validStops.last;
      final intermediate = validStops.sublist(1, validStops.length - 1);

      optimizedOrder.add(start);
      List<RouteStop> remaining = List.from(intermediate);

      if (optimizationCriteria.value == 'Time') {
        final timedStops =
            remaining.where((s) => s.timeConstraint != null).toList();

        timedStops.sort((a, b) {
          final t1 = a.timeConstraint!;
          final t2 = b.timeConstraint!;
          int cmp = t1.hour.compareTo(t2.hour);
          if (cmp == 0) cmp = t1.minute.compareTo(t2.minute);
          return cmp;
        });

        optimizedOrder.addAll(timedStops);
        remaining.removeWhere((s) => s.timeConstraint != null);
      }

      if (optimizedOrder.isEmpty && remaining.isNotEmpty) {}

      while (remaining.isNotEmpty) {
        final current = optimizedOrder.last;
        RouteStop? nearest;
        double minDistance = double.infinity;

        for (var candidate in remaining) {
          if (candidate.visitAfterId != null) {
            bool dependencyMet =
                optimizedOrder.any((s) => s.id == candidate.visitAfterId);
            if (!dependencyMet) {
              continue;
            }
          }

          final dist = _calculateDistance(
              current.lat!, current.lng!, candidate.lat!, candidate.lng!);
          double priorityFactor = 1.0;

          if (optimizationCriteria.value == 'Time') {
            if (candidate.priority == StopPriority.high) priorityFactor = 0.6;
            if (candidate.priority == StopPriority.medium) priorityFactor = 0.8;
          }

          final weightedDist = dist * priorityFactor;

          if (weightedDist < minDistance) {
            minDistance = weightedDist;
            nearest = candidate;
          }
        }

        if (nearest == null) {
          for (var candidate in remaining) {
            if (candidate.visitAfterId != null) {
              bool dependencyMet =
                  optimizedOrder.any((s) => s.id == candidate.visitAfterId);
              if (!dependencyMet) continue;
            }
            nearest = candidate;
            break;
          }

          nearest ??= remaining.first;
        }

        optimizedOrder.add(nearest);
        remaining.remove(nearest);
      }

      optimizedOrder.add(end);

      if (optimizationCriteria.value != 'Time') {
        _applyTwoOpt(optimizedOrder);
      }

      stops.assignAll([...optimizedOrder, ...invalidStops]);
    }

    isOptimizing.value = false;
    isOptimized.value = true;

    final originalDist = calculateTotalDistance(originalStops);
    final optimizedDist = calculateTotalDistance(stops);
    final savedDist = originalDist - optimizedDist;

    final originalTimeMin = (originalDist / 30) * 60;
    final optimizedTimeMin = (optimizedDist / 30) * 60;
    final savedTime = originalTimeMin - optimizedTimeMin;

    String message = '';
    if (optimizationCriteria.value == 'Time') {
      message =
          'Saved ~${savedTime.toStringAsFixed(0)} mins! (Est. based on distance)';
    } else if (optimizationCriteria.value == 'Fuel') {
      final savedFuel = savedDist * 0.1;
      message = 'Saved ~${savedFuel.toStringAsFixed(1)} L of fuel!';
    } else {
      message = 'Saved ${savedDist.toStringAsFixed(1)} km!';
    }

    Get.snackbar(
      'Route Optimized!',
      '$message Tap the map to see details.',
      backgroundColor: Colors.green.shade800,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      overlayBlur: 0,
      mainButton: TextButton(
        onPressed: viewRouteAnalysis,
        child: const Text('ANALYZE',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    _saveSession();
    _saveToHistory(savedDist, savedTime, message);
  }

  double calculateTotalDistance(List<RouteStop> routeStops) {
    double total = 0.0;
    for (int i = 0; i < routeStops.length - 1; i++) {
      final s1 = routeStops[i];
      final s2 = routeStops[i + 1];
      if (s1.lat != null &&
          s1.lng != null &&
          s2.lat != null &&
          s2.lng != null) {
        total += _calculateDistance(s1.lat!, s1.lng!, s2.lat!, s2.lng!);
      }
    }
    return total;
  }

  void viewRouteAnalysis() {
    final validOriginal =
        originalStops.where((s) => s.lat != null && s.lng != null).toList();
    final validOptimized =
        stops.where((s) => s.lat != null && s.lng != null).toList();

    if (validOptimized.length < 2) return;

    Get.toNamed(Routes.mapView, arguments: {
      'mode': 'analysis_view',
      'original_stops': validOriginal.map((s) => s.toJson()).toList(),
      'optimized_stops': validOptimized.map((s) => s.toJson()).toList(),
    });

    if (Get.isRegistered<MapController>()) {
      Get.find<MapController>().refreshArguments();
    }
  }

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const Distance distance = Distance();
    return distance.as(
        LengthUnit.Kilometer, LatLng(lat1, lng1), LatLng(lat2, lng2));
  }

  void updateStopLocation(String id, String address, double lat, double lng) {
    final index = stops.indexWhere((stop) => stop.id == id);
    if (index != -1) {
      stops[index].address = address;
      stops[index].lng = lng;
      stops.refresh();
      isOptimized.value = false;
      _saveSession();
    }
  }

  Future<void> updateStopAddressText(String id, String newAddress) async {
    final index = stops.indexWhere((stop) => stop.id == id);
    if (index != -1) {
      stops[index].address = newAddress;
      stops.refresh();

      if (newAddress.isNotEmpty) {
        try {
          List<geo.Location> locations =
              await geo.locationFromAddress(newAddress);
          if (locations.isNotEmpty) {
            final loc = locations.first;
            stops[index].lat = loc.latitude;
            stops[index].lng = loc.longitude;
            stops.refresh();
            debugPrint(
                'Geocoded $newAddress to ${loc.latitude}, ${loc.longitude}');
          }
        } catch (e) {
          debugPrint('Error geocoding address: $e');
        }
      }
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.amber,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lime,
      Colors.deepOrange,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  Future<void> pickLocationForStop(String stopId) async {
    final result = await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const SizedBox(
            width: double.infinity,
            height: 500,
            child: LocationPickerView(),
          ),
        ),
      ),
    );

    if (result != null && result is Map) {
      final LatLng coords = result['coordinates'];
      final String address = result['address'];
      updateStopLocation(stopId, address, coords.latitude, coords.longitude);
    }
  }

  void viewRouteOnMap() {
    final validStops =
        stops.where((s) => s.lat != null && s.lng != null).toList();
    if (validStops.length < 2) {
      Get.snackbar(
        'Cannot view route',
        'Need at least 2 locations with coordinates.',
        backgroundColor: Colors.orange.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        overlayBlur: 0,
      );
      return;
    }

    Get.toNamed(Routes.mapView, arguments: {
      'mode': 'route_view',
      'stops': validStops
          .map((s) => {
                'lat': s.lat,
                'lng': s.lng,
                'name': s.name,
                'address': s.address
              })
          .toList()
    });

    if (Get.isRegistered<MapController>()) {
      Get.find<MapController>().refreshArguments();
    }
  }

  Future<void> launchNavigation() async {
    final enabled =
        await Get.find<LocationController>().ensureLocationEnabled();
    if (!enabled) return;

    final validStops =
        stops.where((s) => s.lat != null && s.lng != null).toList();
    if (validStops.length < 2) {
      Get.snackbar(
        'Cannot navigate',
        'Need at least 2 locations.',
        backgroundColor: Colors.orange.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.navigation, color: Colors.white),
        overlayBlur: 0,
      );
      return;
    }

    final origin = validStops.first;
    final destination = validStops.last;

    String waypointsString = '';
    if (validStops.length > 2) {
      final waypoints = validStops.sublist(1, validStops.length - 1);
      waypointsString =
          '&waypoints=${waypoints.map((s) => '${s.lat},${s.lng}').join('|')}';
    }

    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${origin.lat},${origin.lng}&destination=${destination.lat},${destination.lng}$waypointsString&travelmode=driving');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open Maps application',
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          overlayBlur: 0,
        );
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
      Get.snackbar(
        'Error',
        'Could not open Maps application',
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        overlayBlur: 0,
      );
    }
  }

  Future<List<Map<String, dynamic>>> analyzeAllRoutes() async {
    final baselineStops = isOptimized.value ? originalStops : stops;
    if (baselineStops.length < 3) return [];

    final results = <Map<String, dynamic>>[];
    final criteriaList = ['Distance', 'Time', 'Fuel'];

    for (var criteria in criteriaList) {
      final tempStops = baselineStops.map((s) => s.copyWith()).toList();
      final start = tempStops.first;
      final end = tempStops.last;
      final intermediate = tempStops.sublist(1, tempStops.length - 1);

      final optimizedOrder = <RouteStop>[start];
      final remaining = List<RouteStop>.from(intermediate);

      if (criteria == 'Time') {
        final timedStops =
            remaining.where((s) => s.timeConstraint != null).toList();
        timedStops.sort((a, b) {
          final t1 = a.timeConstraint!;
          final t2 = b.timeConstraint!;
          int cmp = t1.hour.compareTo(t2.hour);
          if (cmp == 0) cmp = t1.minute.compareTo(t2.minute);
          return cmp;
        });
        optimizedOrder.addAll(timedStops);
        remaining.removeWhere((s) => s.timeConstraint != null);
      }

      if (optimizedOrder.isEmpty && remaining.isNotEmpty) {
        int startIndex = -1;
        for (int i = 0; i < remaining.length; i++) {
          if (remaining[i].visitAfterId == null) {
            startIndex = i;
            break;
          }
          bool dependencyMet =
              optimizedOrder.any((s) => s.id == remaining[i].visitAfterId);
          if (dependencyMet) {
            startIndex = i;
            break;
          }
        }
        if (startIndex != -1) {
          optimizedOrder.add(remaining[startIndex]);
          remaining.removeAt(startIndex);
        } else {
          optimizedOrder.add(remaining.first);
          remaining.removeAt(0);
        }
      }

      while (remaining.isNotEmpty) {
        final current = optimizedOrder.last;
        RouteStop? nearest;
        double minDistance = double.infinity;

        for (var candidate in remaining) {
          if (candidate.visitAfterId != null) {
            bool dependencyMet =
                optimizedOrder.any((s) => s.id == candidate.visitAfterId);
            if (!dependencyMet) continue;
          }

          final dist = _calculateDistance(
              current.lat!, current.lng!, candidate.lat!, candidate.lng!);
          double priorityFactor = 1.0;

          if (criteria == 'Time') {
            if (candidate.priority == StopPriority.high) priorityFactor = 0.6;
            if (candidate.priority == StopPriority.medium) priorityFactor = 0.8;
          }

          final weightedDist = dist * priorityFactor;

          if (weightedDist < minDistance) {
            minDistance = weightedDist;
            nearest = candidate;
          }
        }

        if (nearest == null) {
          for (var candidate in remaining) {
            if (candidate.visitAfterId != null) {
              bool dependencyMet =
                  optimizedOrder.any((s) => s.id == candidate.visitAfterId);
              if (!dependencyMet) continue;
            }
            nearest = candidate;
            break;
          }
          nearest ??= remaining.first;
        }

        optimizedOrder.add(nearest);
        remaining.remove(nearest);
      }

      optimizedOrder.add(end);

      if (criteria != 'Time') {
        _applyTwoOpt(optimizedOrder);
      }

      double totalDist = 0;
      for (int i = 0; i < optimizedOrder.length - 1; i++) {
        totalDist += _calculateDistance(
            optimizedOrder[i].lat!,
            optimizedOrder[i].lng!,
            optimizedOrder[i + 1].lat!,
            optimizedOrder[i + 1].lng!);
      }

      double speed = 30.0;
      double fuelRate = 0.15;

      if (criteria == 'Time') {
        speed = 35.0;

        totalDist *= 1.02;
      } else if (criteria == 'Fuel') {
        fuelRate = 0.14;
        speed = 28.0;
      }

      double timeMinutes = (totalDist / speed) * 60;
      double fuelCost = totalDist * fuelRate;

      results.add({
        'criteria': criteria,
        'distance': totalDist,
        'time': timeMinutes,
        'cost': fuelCost,
        'stops': optimizedOrder,
      });
    }

    return results;
  }

  void _applyTwoOpt(List<RouteStop> route) {
    if (route.length < 4) {
      return;
    }

    bool improved = true;
    int iterations = 0;

    while (improved && iterations < 50) {
      improved = false;
      iterations++;

      for (int i = 1; i < route.length - 2; i++) {
        for (int j = i + 1; j < route.length - 1; j++) {
          if (j - i == 1) continue;

          double d1 = _calculateDistance(route[i - 1].lat!, route[i - 1].lng!,
              route[i].lat!, route[i].lng!);
          double d2 = _calculateDistance(route[j].lat!, route[j].lng!,
              route[j + 1].lat!, route[j + 1].lng!);
          double currentDist = d1 + d2;

          double d3 = _calculateDistance(route[i - 1].lat!, route[i - 1].lng!,
              route[j].lat!, route[j].lng!);
          double d4 = _calculateDistance(route[i].lat!, route[i].lng!,
              route[j + 1].lat!, route[j + 1].lng!);
          double newDist = d3 + d4;

          if (newDist < currentDist) {
            final newRoute = List<RouteStop>.from(route);
            _reverseSegment(newRoute, i, j);

            if (_isValidRoute(newRoute)) {
              route.setRange(0, route.length, newRoute);
              improved = true;
            }
          }
        }
      }
    }
  }

  void _reverseSegment(List<RouteStop> route, int i, int j) {
    while (i < j) {
      final temp = route[i];
      route[i] = route[j];
      route[j] = temp;
      i++;
      j--;
    }
  }

  bool _isValidRoute(List<RouteStop> route) {
    for (int i = 0; i < route.length; i++) {
      final stop = route[i];
      if (stop.visitAfterId != null) {
        final dependencyIndex =
            route.indexWhere((s) => s.id == stop.visitAfterId);
        if (dependencyIndex == -1 || dependencyIndex > i) {
          return false;
        }
      }
    }
    return true;
  }

  void updateShortcut(
      Map<String, dynamic> shortcut, Map<String, dynamic> newData) {
    shortcut['name'] = newData['name'];
    shortcut['icon'] = newData['icon'];
    shortcut['color'] = newData['color'];

    if (newData['address'] != null &&
        newData['address'].toString().isNotEmpty) {
      shortcut['address'] = newData['address'];
      shortcut['lat'] = newData['lat'];
      shortcut['lng'] = newData['lng'];
    } else {
      shortcut.remove('address');
      shortcut.remove('lat');
      shortcut.remove('lng');
    }

    shortcuts.refresh();
    Get.snackbar(
        'Shortcut Updated', '${shortcut['name']} updated successfully!');
  }

  void createShortcut(Map<String, dynamic> shortcutData) {
    if (!shortcutData.containsKey('type')) {
      shortcutData['type'] = 'Other';
    }

    shortcuts.add(shortcutData);
    Get.snackbar(
        'Shortcut Created', '${shortcutData['name']} added to shortcuts!');
  }

  Future<Map<String, dynamic>?> pickLocationForShortcut() async {
    final result = await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const SizedBox(
            width: double.infinity,
            height: 500,
            child: LocationPickerView(),
          ),
        ),
      ),
    );

    if (result != null && result is Map) {
      return result as Map<String, dynamic>;
    }
    return null;
  }

  void _saveSession() {
    final stopsJson = stops.map((s) => s.toJson()).toList();
    box.put('current_stops', stopsJson);
    box.put('criteria', optimizationCriteria.value);
  }

  void _showRestoreDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history_edu_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              const Text(
                'We found an unfinished route from your last session. Would you like to pick up where you left off?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryLight,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start Fresh',
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog first to avoid context issues
                        try {
                          _restoreSession();
                        } catch (e) {
                          // Get.log('Error restoring session: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Restore Route',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _restoreSession() {
    if (box.containsKey('current_stops')) {
      final savedStops = box.get('current_stops') as List;
      final savedCriteria = box.get('criteria') as String?;

      if (savedStops.isNotEmpty) {
        stops.assignAll(savedStops.map((json) {
          return RouteStop(
            id: json['id'],
            name: json['name'],
            lat: json['lat'],
            lng: json['lng'],
            address: json['address'],
            type: json['type'] ?? 'Other',
            visitAfterId: json['visitAfterId'],
            color: _getRandomColor(),
            priority: StopPriority.medium,
          );
        }).toList());

        if (savedCriteria != null) {
          optimizationCriteria.value = savedCriteria;
        }

        Get.snackbar(
          'Session Restored',
          'Your previous route has been loaded.',
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  void _saveToHistory(double savedDist, double savedTime, String message) {
    final historyItem = {
      'date': DateTime.now().toIso8601String(),
      'stops': stops.map((s) => s.toJson()).toList(),
      'criteria': optimizationCriteria.value,
      'saved_dist': savedDist,
      'saved_time': savedTime,
      'message': message,
    };

    final history = box.get('history', defaultValue: []) as List;
    history.insert(0, historyItem);
    if (history.length > 10) history.removeLast();
    box.put('history', history);
  }

  List<Map<String, dynamic>> getHistory() {
    final history = box.get('history', defaultValue: []) as List;
    return history.cast<Map<String, dynamic>>();
  }

  void restoreFromHistory(Map<String, dynamic> historyItem) {
    final savedStops = historyItem['stops'] as List;
    stops.assignAll(savedStops.map((json) {
      return RouteStop(
        id: json['id'],
        name: json['name'],
        lat: json['lat'],
        lng: json['lng'],
        address: json['address'],
        type: json['type'] ?? 'Other',
        color: _getRandomColor(),
      );
    }).toList());

    optimizationCriteria.value = historyItem['criteria'];
    isOptimized.value = true;
    _saveSession();
    Get.back();
    Get.snackbar('History Restored', 'Route restored from history.');
  }

  void resetToOriginal() {
    if (originalStops.isNotEmpty) {
      stops.assignAll(originalStops.map((s) => s.copyWith()).toList());
      isOptimized.value = false;
      _saveSession();
      Get.snackbar('Reset', 'Route reset to original order.');
    } else {
      Get.snackbar('Info', 'No original route to reset to.');
    }
  }
}
