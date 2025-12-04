import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_routes.dart';
import '../../core/utils/app_snackbars.dart';
import '../route_planner/route_planner_controller.dart';
import '../main_layout/main_layout_controller.dart';
import '../home/home_controller.dart';
import '../favorites/favorites_controller.dart';

class RouteDetailsController extends GetxController {
  final route = Rx<Map<String, dynamic>>({});
  final isFavorite = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      route.value = Get.arguments as Map<String, dynamic>;
      
      if (route.value.containsKey('is_favorite')) {
        isFavorite.value = route.value['is_favorite'] ?? false;
      } else {
        
        
        _checkFavoriteStatus();
      }
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final routeId = route.value['id'];
    if (routeId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('user_routes')
          .select('is_favorite')
          .eq('id', routeId)
          .single();

      isFavorite.value = response['is_favorite'] ?? false;
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
  }

  Future<void> toggleFavorite() async {
    final routeId = route.value['id'];
    if (routeId == null) return;

    try {
      isLoading.value = true;
      final newStatus = !isFavorite.value;

      await Supabase.instance.client
          .from('user_routes')
          .update({'is_favorite': newStatus}).eq('id', routeId);

      isFavorite.value = newStatus;

      
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadRecentRoutes();
      }
      if (Get.isRegistered<FavoritesController>()) {
        Get.find<FavoritesController>().loadFavorites();
      }
    } catch (e) {
      AppSnackbars.showError('Error', 'Failed to update favorite status: $e');
      debugPrint('Error toggling favorite: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void repeatRoute() {
    final args = {
      'from': route.value['from'] ?? '',
      'to': route.value['to'] ?? '',
      'mode': route.value['mode'] ?? 'Car',
    };

    _navigateToPlanner(args);
  }

  void reverseRoute() {
    final args = {
      'from': route.value['to'] ?? '',
      'to': route.value['from'] ?? '',
      'mode': route.value['mode'] ?? 'Car',
    };

    _navigateToPlanner(args);
  }

  void _navigateToPlanner(Map<String, dynamic> args) {
    
    if (Get.isRegistered<RoutePlannerController>()) {
      Get.find<RoutePlannerController>().setRouteArgs(args);
    }

    
    
    if (Get.isRegistered<MainLayoutController>()) {
      Get.find<MainLayoutController>()
          .changePage(1); 
      
      
      
      
    }

    
    
    
    Get.toNamed(Routes.ROUTE_PLANNER, arguments: args);
  }
}
