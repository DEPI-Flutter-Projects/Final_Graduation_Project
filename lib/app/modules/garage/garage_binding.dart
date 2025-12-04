import 'package:get/get.dart';
import 'garage_controller.dart';

class GarageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GarageController>(() => GarageController());
  }
}
