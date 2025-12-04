import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_view.dart';
import '../route_planner/route_planner_view.dart';
import '../map/map_view.dart';
import '../cost_calculator/cost_calculator_view.dart';
import 'main_layout_controller.dart';

class MainLayoutView extends GetView<MainLayoutController> {
  const MainLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeView(),
              RoutePlannerView(),
              MapView(), 
              CostCalculatorView(),
            ],
          )),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: controller.changePage,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 10,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon:
                    Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.alt_route_outlined),
                selectedIcon:
                    Icon(Icons.alt_route_rounded, color: AppColors.primary),
                label: 'Route Planner',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_rounded, color: AppColors.primary),
                label: 'Map View',
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon:
                    Icon(Icons.calculate_rounded, color: AppColors.primary),
                label: 'Cost Calculator',
              ),
            ],
          )),
    );
  }
}
