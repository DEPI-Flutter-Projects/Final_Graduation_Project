import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_routes.dart';
import '../settings/settings_controller.dart';

class FavoritesController extends GetxController {
  final favoriteRoutes = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('user_routes')
          .select()
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> routes = [];

      for (var item in response) {
        final createdAt = DateTime.parse(item['created_at']);
        final dateString =
            '${createdAt.day}/${createdAt.month}/${createdAt.year}';

        
        final settings = Get.find<SettingsController>();
        String currencySymbol = settings.currency.value;
        double rate = settings.exchangeRate.value;

        double cost =
            ((item['estimated_cost'] ?? item['cost'] ?? 0) as num).toDouble();
        double saved = ((item['saved_amount'] ?? 0) as num).toDouble();

        routes.add({
          'id': item['id'],
          'to': item['end_address'] ?? item['to_location'] ?? 'Unknown',
          'from': item['start_address'] ?? item['from_location'] ?? 'Unknown',
          'date': dateString,
          'cost': '$currencySymbol ${(cost * rate).toStringAsFixed(2)}',
          'saved': '$currencySymbol ${(saved * rate).toStringAsFixed(2)}',
          'mode': item['transport_mode'] ?? 'Car',
          'is_favorite': true,
        });
      }

      favoriteRoutes.assignAll(routes);
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void openRouteDetails(Map<String, dynamic> route) {
    Get.toNamed(Routes.ROUTE_DETAILS, arguments: route)?.then((_) {
      
      loadFavorites();
    });
  }
}
