import 'package:get/get.dart';
import 'route_optimizer_controller.dart';

class RouteOptimizerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RouteOptimizerController>(
      () => RouteOptimizerController(),
    );
  }
}
