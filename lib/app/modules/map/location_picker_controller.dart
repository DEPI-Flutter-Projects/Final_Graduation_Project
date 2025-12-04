import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/utils/app_snackbars.dart';

enum MapMode { normal, satellite, terrain }

class LocationPickerController extends GetxController {
  final MapController mapController = MapController();
  final searchController = TextEditingController();

  final Rx<MapMode> currentMapMode = MapMode.normal.obs;
  final Rx<LatLng> selectedLocation =
      const LatLng(30.0444, 31.2357).obs; 
  final RxString selectedAddress = 'Tap on map to select location'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null && Get.arguments is LatLng) {
      selectedLocation.value = Get.arguments as LatLng;
      getAddressFromLatLng(selectedLocation.value);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    mapController.dispose();
    super.onClose();
  }

  void setMapMode(MapMode mode) {
    currentMapMode.value = mode;
  }

  String getTileUrl() {
    switch (currentMapMode.value) {
      case MapMode.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapMode.terrain:
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
      case MapMode.normal:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  Future<void> searchLocation() async {
    if (searchController.text.isEmpty) return;

    isLoading.value = true;
    try {
      List<Location> locations =
          await locationFromAddress(searchController.text);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);

        selectedLocation.value = latLng;
        mapController.move(latLng, 15);

        
        await getAddressFromLatLng(latLng);
      } else {
        AppSnackbars.showError('Error', 'Location not found');
      }
    } catch (e) {
      AppSnackbars.showError('Error', 'Could not find location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onMapTap(TapPosition tapPosition, LatLng point) async {
    selectedLocation.value = point;
    await getAddressFromLatLng(point);
  }

  Future<void> getAddressFromLatLng(LatLng point) async {
    isLoading.value = true;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        
        String address = '';
        if (place.street != null && place.street!.isNotEmpty) {
          address += '${place.street}, ';
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += '${place.subLocality}, ';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += '${place.locality}';
        }

        if (address.isEmpty) {
          address =
              '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
        }

        selectedAddress.value = address;
        
        searchController.text = address;
      } else {
        selectedAddress.value =
            '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      selectedAddress.value =
          '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
      debugPrint('Error getting address: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToCurrentLocation() async {
    isLoading.value = true;
    try {
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppSnackbars.showError('Permission Denied',
              'Location permission is required to find your location.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppSnackbars.showError('Permission Denied',
            'Location permission is permanently denied. Please enable it in settings.');
        return;
      }

      
      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      selectedLocation.value = latLng;
      mapController.move(latLng, 15);
      await getAddressFromLatLng(latLng);
    } catch (e) {
      AppSnackbars.showError('Error', 'Could not get current location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void confirmLocation() {
    Get.back(result: {
      'coordinates': selectedLocation.value,
      'address': selectedAddress.value,
    });
  }
}
