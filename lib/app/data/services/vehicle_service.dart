import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VehicleService extends GetxService {
  final RxList<Map<String, dynamic>> userVehicles =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  final Rxn<Map<String, dynamic>> activeVehicle = Rxn<Map<String, dynamic>>();

  late Box _box;

  @override
  void onInit() {
    super.onInit();
    _initService();
  }

  Future<void> _initService() async {
    _box = await Hive.openBox('vehicle_cache');
    _loadVehiclesFromCache();

    // Fetch latest from network
    fetchUserVehicles();
  }

  void setActiveVehicle(Map<String, dynamic> vehicle) {
    activeVehicle.value = vehicle;
  }

  void _loadVehiclesFromCache() {
    try {
      if (_box.containsKey('user_vehicles')) {
        final List<dynamic> cachedData = _box.get('user_vehicles');
        userVehicles.assignAll(cachedData.cast<Map<String, dynamic>>());
        // Set active vehicle from cache
        activeVehicle.value = getDefaultVehicle();
      }
    } catch (e) {
      debugPrint('Error loading vehicles from cache: $e');
    }
  }

  Future<void> _saveVehiclesToCache() async {
    try {
      await _box.put('user_vehicles', userVehicles);
    } catch (e) {
      debugPrint('Error saving vehicles to cache: $e');
    }
  }

  Future<void> fetchUserVehicles() async {
    isLoading.value = true;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('user_vehicles')
          .select('*, car_models(*, car_brands(name, logo_url))')
          .eq('user_id', userId)
          .order('is_default', ascending: false);

      final vehicles = List<Map<String, dynamic>>.from(response);
      userVehicles.assignAll(vehicles);

      // Update cache
      _saveVehiclesToCache();

      // Update active vehicle if not set or if needed
      if (activeVehicle.value == null) {
        activeVehicle.value = getDefaultVehicle();
      }
    } catch (e) {
      debugPrint('Error fetching vehicles in VehicleService: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic>? getDefaultVehicle() {
    if (userVehicles.isEmpty) return null;
    return userVehicles.firstWhere(
      (v) => v['is_default'] == true,
      orElse: () => userVehicles.first,
    );
  }
}
