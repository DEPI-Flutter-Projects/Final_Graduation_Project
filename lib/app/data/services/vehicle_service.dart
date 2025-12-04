import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService extends GetxService {
  final RxList<Map<String, dynamic>> userVehicles =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  final RxMap<String, double> fuelPrices = <String, double>{}.obs;
  final RxList<String> fuelTypes = <String>[].obs;

  final Rxn<Map<String, dynamic>> activeVehicle = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchUserVehicles().then((_) {
      
      activeVehicle.value = getDefaultVehicle();
    });
    fetchFuelPrices();
  }

  void setActiveVehicle(Map<String, dynamic> vehicle) {
    activeVehicle.value = vehicle;
  }

  Future<void> fetchFuelPrices() async {
    try {
      final response = await Supabase.instance.client
          .from('fuel_prices')
          .select('type, price')
          .order('id');

      final prices = <String, double>{};
      final types = <String>[];

      for (var item in response) {
        final type = item['type'] as String;
        final price = (item['price'] as num).toDouble();
        prices[type] = price;
        types.add(type);
      }

      
      types.sort((a, b) {
        final order = {
          'Petrol 80': 1,
          'Petrol 92': 2,
          'Petrol 95': 3,
          'CNG': 4,
          'Diesel': 5,
        };
        return (order[a] ?? 99).compareTo(order[b] ?? 99);
      });

      fuelPrices.assignAll(prices);
      fuelTypes.assignAll(types);
    } catch (e) {
      debugPrint('Error fetching fuel prices: $e');
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

      userVehicles.assignAll(List<Map<String, dynamic>>.from(response));
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
