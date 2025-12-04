import 'package:get/get.dart';
import 'route_planner_controller.dart';

class RoutePlannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoutePlannerController>(() => RoutePlannerController());
  }
}
