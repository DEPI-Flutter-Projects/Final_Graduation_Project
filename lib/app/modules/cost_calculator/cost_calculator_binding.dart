import 'package:get/get.dart';
import 'cost_calculator_controller.dart';

class CostCalculatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CostCalculatorController>(() => CostCalculatorController());
  }
}
