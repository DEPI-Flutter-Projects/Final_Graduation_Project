import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleController extends GetxController {
  
  final vehicles = <Map<String, dynamic>>[].obs;

  
  final selectedVehicleId = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    try {
      final response = await Supabase.instance.client
          .from('vehicles')
          .select()
          .order('name');

      vehicles.assignAll(List<Map<String, dynamic>>.from(response));
      
      if (selectedVehicleId.value == null && vehicles.isNotEmpty) {
        selectedVehicleId.value = vehicles.first['vehicle_id'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching vehicles: $e');
      }
    }
  }

  void setDefaultVehicle(String vehicleId) async {
    selectedVehicleId.value = vehicleId;
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await Supabase.instance.client.from('user_preferences').upsert({
      'user_id': user.id,
      'default_vehicle_id': vehicleId,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  
  Future<void> addVehicleLabel(String vehicleId, String label) async {
    await Supabase.instance.client.from('vehicle_labels').insert({
      'vehicle_id': vehicleId,
      'label': label,
    });
    
  }
}
