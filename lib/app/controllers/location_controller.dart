import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocationController extends GetxController {
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLocationServiceEnabled = false.obs;
  final RxBool isPermissionGranted = false.obs;

  StreamSubscription<Position>? _positionStreamSubscription;
  Box? _locationBox;

  @override
  void onInit() {
    super.onInit();
    _initHiveAndLoadCache();
    checkLocationPermissions();
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initHiveAndLoadCache() async {
    try {
      _locationBox = await Hive.openBox('location_cache');
      final lat = _locationBox?.get('latitude');
      final lng = _locationBox?.get('longitude');

      if (lat != null && lng != null) {
        
        currentPosition.value = Position(
          latitude: lat,
          longitude: lng,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        debugPrint('Loaded cached location: $lat, $lng');
      }
    } catch (e) {
      debugPrint('Error loading location cache: $e');
    }
  }

  Future<void> checkLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    isLocationServiceEnabled.value = serviceEnabled;

    if (!serviceEnabled) {
      
      
      return;
    }

    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        
        
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      
      return;
    }

    isPermissionGranted.value = true;
    _startLocationUpdates();
  }

  Future<bool> ensureLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final result = await Get.defaultDialog(
        title: "Ya Basha!",
        titleStyle:
            const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        middleText:
            "We need GPS to calculate the trip cost accurately. Can you turn it on?",
        middleTextStyle: const TextStyle(fontFamily: 'Cairo'),
        confirm: ElevatedButton(
          onPressed: () async {
            Get.back(result: true);
            await Geolocator.openLocationSettings();
            
            await Future.delayed(const Duration(seconds: 1));
            checkLocationPermissions();
          },
          child: const Text("Enable GPS"),
        ),
        cancel: TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text("Later"),
        ),
        barrierDismissible: false,
      );
      return result ?? false;
    }

    if (!isPermissionGranted.value) {
      await checkLocationPermissions();
      return isPermissionGranted.value;
    }

    return true;
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      currentPosition.value = position;
      _cacheLocation(position);
    });
  }

  void _cacheLocation(Position position) {
    _locationBox?.put('latitude', position.latitude);
    _locationBox?.put('longitude', position.longitude);
  }
}
