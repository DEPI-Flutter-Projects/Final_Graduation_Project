import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/location_controller.dart';

class TripController extends GetxController {
  final LocationController locationController = Get.find<LocationController>();
  final MapController mapController = MapController();

  final Rx<LatLng> center = const LatLng(30.0444, 31.2357).obs; 

  @override
  void onInit() {
    super.onInit();
    
    ever(locationController.currentPosition, (position) {
      if (position != null) {
        center.value = LatLng(position.latitude, position.longitude);
        
      }
    });
  }
}
