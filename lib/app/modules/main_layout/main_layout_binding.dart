import 'package:get/get.dart';
import 'main_layout_controller.dart';
import '../home/home_controller.dart';
import '../route_planner/route_planner_controller.dart';
import '../map/map_controller.dart';
import '../cost_calculator/cost_calculator_controller.dart';

class MainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainLayoutController>(MainLayoutController());

    
    
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<RoutePlannerController>(() => RoutePlannerController());
    Get.lazyPut<MapController>(() => MapController());
    Get.lazyPut<CostCalculatorController>(() => CostCalculatorController());
  }
}
