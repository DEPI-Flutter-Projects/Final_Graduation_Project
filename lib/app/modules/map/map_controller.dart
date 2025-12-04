import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart' as fm; 
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/location_controller.dart';
import '../../data/services/notification_service.dart';

class MapController extends GetxController {
  final locationReady = false.obs;
  final currentLatLng = const LatLng(30.0444, 31.2357).obs; 
  final markers = <LatLng>[].obs;

  
  final routePoints = <LatLng>[].obs;
  final remainingDistance = '0 km'.obs;
  final remainingTime = '0 min'.obs;
  final totalDistance = 0.0.obs; 

  
  final mapStyle = 'Normal'.obs; 

  
  final fm.MapController mapController = fm.MapController();

  
  final LocationController _locationController = Get.find<LocationController>();

  
  final isTracking = false.obs;
  final currentRotation = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    
  }

  @override
  void onReady() async {
    super.onReady();
    refreshArguments();

    
    final enabled = await _locationController.ensureLocationEnabled();
    if (enabled) {
      _initLocation();
    }
  }

  void refreshArguments() {
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['mode'] == 'route_view' && args['stops'] != null) {
        final stops = args['stops'] as List;
        clearMarkers();
        final newMarkers = <LatLng>[];
        for (var stop in stops) {
          if (stop['lat'] != null && stop['lng'] != null) {
            newMarkers.add(LatLng(stop['lat'], stop['lng']));
          }
        }
        markers.assignAll(newMarkers);
        if (markers.length >= 2) {
          _fetchRoute();
        }
      } else if (args['mode'] == 'analysis_view') {
        
        
        if (args['optimized_stops'] != null) {
          final stops = args['optimized_stops'] as List;
          clearMarkers();
          final newMarkers = <LatLng>[];
          for (var stop in stops) {
            if (stop['lat'] != null && stop['lng'] != null) {
              newMarkers.add(LatLng(stop['lat'], stop['lng']));
            }
          }
          markers.assignAll(newMarkers);
          if (markers.length >= 2) {
            _fetchRoute();
          }
        }
      }
    }
  }

  void toggleMapStyle() {
    if (mapStyle.value == 'Normal') {
      mapStyle.value = 'Terrain';
    } else if (mapStyle.value == 'Terrain') {
      mapStyle.value = 'Dark';
    } else {
      mapStyle.value = 'Normal';
    }
  }

  void rotateMap() {
    
    double newRotation = currentRotation.value + 90.0;
    if (newRotation >= 360) newRotation = 0;

    mapController.rotate(newRotation);
    currentRotation.value = newRotation;
  }

  void resetRotation() {
    mapController.rotate(0);
    currentRotation.value = 0;
  }

  void toggleTracking() {
    isTracking.value = !isTracking.value;
    if (isTracking.value) {
      
      mapController.move(currentLatLng.value, mapController.camera.zoom);
    }
  }

  
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  
  bool _hasSentArrivalAlert = false;
  Timer? _gpsTimeoutTimer;

  void _initLocation() {
    
    if (_locationController.currentPosition.value != null) {
      final pos = _locationController.currentPosition.value!;
      currentLatLng.value = LatLng(pos.latitude, pos.longitude);
      locationReady.value = true;
    }

    
    ever(_locationController.currentPosition, (position) {
      _resetGpsTimer();

      if (position != null) {
        final newPos = LatLng(position.latitude, position.longitude);
        currentLatLng.value = newPos;
        locationReady.value = true;

        
        if (isTracking.value) {
          mapController.move(newPos, mapController.camera.zoom);
        }

        
        if (routePoints.isNotEmpty) {
          _checkArrivalAlert(newPos);
        }
      }
    });
  }

  void _resetGpsTimer() {
    _gpsTimeoutTimer?.cancel();
    _gpsTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (isTracking.value || routePoints.isNotEmpty) {
        _notificationService.showNotification(
          title: 'GPS Signal Lost 📡',
          body:
              'We haven\'t received your location in a while. Check your GPS settings.',
          type: 'navigation',
        );
      }
    });
  }

  void _checkArrivalAlert(LatLng currentPos) {
    if (routePoints.isEmpty) return;

    final destination = routePoints.last;
    final distance =
        const Distance().as(LengthUnit.Meter, currentPos, destination);

    
    final threshold = (totalDistance.value * 0.1).clamp(200.0, 5000.0);

    
    
    if (distance < threshold && !_hasSentArrivalAlert) {
      String body;
      if (distance < 100) {
        body = 'You have arrived at your destination!';
      } else {
        body =
            'You are less than ${(threshold / 1000).toStringAsFixed(1)}km away from your destination.';
      }

      _notificationService.showNotification(
        title: distance < 100 ? 'You have Arrived! 📍' : 'Arriving Soon! 🏁',
        body: body,
        type: 'navigation',
      );
      _hasSentArrivalAlert = true;
    } else if (distance > (threshold * 2)) {
      _hasSentArrivalAlert = false; 
    }
  }

  void addMarker(LatLng point) {
    markers.add(point);
    if (markers.length >= 2) {
      _fetchRoute();
    }
  }

  void clearMarkers() {
    markers.clear();
    routePoints.clear();
    remainingDistance.value = '0 km';
    remainingTime.value = '0 min';
    _hasSentArrivalAlert = false;
  }

  void setRoute(LatLng start, LatLng end) {
    clearMarkers();
    addMarker(start);
    addMarker(end);
    
  }

  Future<void> _fetchRoute() async {
    if (markers.length < 2) return;

    try {
      
      final url = Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car/geojson');

      
      final body = json.encode({
        "coordinates": markers.map((p) => [p.longitude, p.latitude]).toList(),
      });

      final response = await http.post(
        url,
        headers: {
          'Authorization':
              '5b3ce3597851110001cf6248dabfee823c124943a4373830acc163ed', 
          'Content-Type': 'application/json; charset=UTF-8',
          'User-Agent': 'El-Moshwar/1.0', 
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        if (features.isNotEmpty) {
          final feature = features.first;
          final geometry = feature['geometry'];
          final coordinates = geometry['coordinates'] as List;

          
          final points = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();

          routePoints.assignAll(points);

          
          final properties = feature['properties'];
          final summary = properties['summary'];
          final distanceMeters = summary['distance'] as num;
          final durationSeconds = summary['duration'] as num;

          totalDistance.value = distanceMeters.toDouble();
          remainingDistance.value =
              '${(distanceMeters / 1000).toStringAsFixed(1)} km';
          remainingTime.value = '${(durationSeconds / 60).round()} min';

          
          isTracking.value = true;

          
          _fitCameraToRoute(points);
        }
      } else {
        debugPrint(
            'Error fetching route: ${response.statusCode} - ${response.body}');
        Get.snackbar('Route Error',
            'Could not fetch route. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
      Get.snackbar('Error', 'Failed to connect to routing service.');
    }
  }

  void _fitCameraToRoute(List<LatLng> points) {
    if (points.isEmpty) return;

    final bounds = fm.LatLngBounds.fromPoints(points);

    
    mapController.fitCamera(
      fm.CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  Future<void> launchMaps() async {
    if (markers.length < 2) return;

    final start = markers.first;
    final end = markers.last;

    String waypointsString = '';
    if (markers.length > 2) {
      final waypoints = markers.sublist(1, markers.length - 1);
      waypointsString = '&waypoints=' +
          waypoints.map((p) => '${p.latitude},${p.longitude}').join('|');
    }

    
    
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}$waypointsString&travelmode=driving');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        
        debugPrint('Could not launch maps url: $url');
        Get.snackbar('Error', 'Could not open Maps application');
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }
}
