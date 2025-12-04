import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/location_controller.dart';
import '../../data/services/car_data_service.dart';
import '../profile/profile_controller.dart';
import '../settings/settings_controller.dart';

class HomeController extends GetxController {
  final LocationController locationController = Get.find<LocationController>();
  final CarDataService carDataService = Get.find<CarDataService>();
  
  final ProfileController profileController = Get.find<ProfileController>();

  final recentRoutes = <Map<String, dynamic>>[].obs;
  final smartSuggestions = <Map<String, dynamic>>[].obs;

  final moneySavedThisMonth = 0.0.obs;
  final moneySavedLastMonth = 0.0.obs; 
  final totalMoneySaved = 0.0.obs;
  final savingsGoal = 1000.0.obs; 
  final RxString debugLog = ''.obs;
  final totalTripsThisMonth = 0.obs;
  final avgSavingsPerTrip = 0.0.obs;

  final moneySavedTrend = '0%'.obs;
  final tripsTrend = '0'.obs;
  final avgSavingsTrend = '0.0'.obs;
  final moneySavedTrendPositive = true.obs;
  final tripsTrendPositive = true.obs;
  final avgSavingsTrendPositive = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentRoutes();
    _loadSmartSuggestions();
    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final now = DateTime.now();
      
      final startOfThisMonth = DateTime(now.year, now.month, 1);
      final startOfLastMonth = DateTime(now.year, now.month - 1, 1);

      
      final startOfThisMonthUtc = startOfThisMonth.toUtc().toIso8601String();
      final startOfLastMonthUtc = startOfLastMonth.toUtc().toIso8601String();

      
      final responseThisMonth = await Supabase.instance.client
          .from('user_routes')
          .select('saved_amount, estimated_cost')
          .eq('user_id', userId)
          .gte('created_at', startOfThisMonthUtc);

      
      final responseLastMonth = await Supabase.instance.client
          .from('user_routes')
          .select('saved_amount, estimated_cost')
          .eq('user_id', userId)
          .gte('created_at', startOfLastMonthUtc)
          .lt('created_at', startOfThisMonthUtc);

      
      final responseAllTime = await Supabase.instance.client
          .from('user_routes')
          .select('saved_amount, created_at')
          .eq('user_id', userId);

      debugPrint('--- Savings Debug ---');
      debugPrint('Start This Month UTC: $startOfThisMonthUtc');
      debugPrint('Start Last Month UTC: $startOfLastMonthUtc');
      debugPrint('All Time Records: ${responseAllTime.length}');
      for (var item in responseAllTime) {
        debugPrint(
            'Record: ${item['created_at']} - Saved: ${item['saved_amount']}');
      }
      debugPrint('This Month Records: ${responseThisMonth.length}');
      debugPrint('---------------------');

      
      double savedThisMonth = 0;
      int tripsThisMonth = 0;
      for (var item in responseThisMonth) {
        savedThisMonth += (item['saved_amount'] ?? 0) as num;
        tripsThisMonth++;
      }
      double avgSavedThisMonth =
          tripsThisMonth > 0 ? savedThisMonth / tripsThisMonth : 0.0;

      
      double savedLastMonth = 0;
      int tripsLastMonth = 0;
      for (var item in responseLastMonth) {
        savedLastMonth += (item['saved_amount'] ?? 0) as num;
        tripsLastMonth++;
      }
      double avgSavedLastMonth =
          tripsLastMonth > 0 ? savedLastMonth / tripsLastMonth : 0.0;

      
      double savedTotal = 0;
      for (var item in responseAllTime) {
        savedTotal += (item['saved_amount'] ?? 0) as num;
      }

      
      moneySavedThisMonth.value = savedThisMonth;
      moneySavedLastMonth.value = savedLastMonth; 
      totalMoneySaved.value = savedTotal;
      totalTripsThisMonth.value = tripsThisMonth;
      avgSavingsPerTrip.value = avgSavedThisMonth;

      
      moneySavedTrend.value =
          _calculatePercentageChange(savedLastMonth, savedThisMonth);
      moneySavedTrendPositive.value = savedThisMonth >= savedLastMonth;

      int tripsDiff = tripsThisMonth - tripsLastMonth;
      tripsTrend.value = tripsDiff >= 0 ? '+$tripsDiff' : '$tripsDiff';
      tripsTrendPositive.value = tripsDiff >= 0;

      double avgDiff = avgSavedThisMonth - avgSavedLastMonth;
      avgSavingsTrend.value = avgDiff >= 0
          ? '+${avgDiff.toStringAsFixed(1)}'
          : avgDiff.toStringAsFixed(1);
      avgSavingsTrendPositive.value = avgDiff >= 0;
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
    }
  }

  String _calculatePercentageChange(double oldVal, double newVal) {
    if (oldVal == 0) {
      return newVal > 0 ? '+100%' : '0%';
    }
    double change = ((newVal - oldVal) / oldVal) * 100;
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(0)}%';
  }

  Future<void> loadRecentRoutes() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('HomeController: User ID is null, cannot load routes');
        return;
      }

      debugPrint('HomeController: Loading recent routes for user $userId');

      final response = await Supabase.instance.client
          .from('user_routes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      final List<Map<String, dynamic>> routes = [];

      for (var item in response) {
        final createdAt = DateTime.parse(item['created_at']);
        final now = DateTime.now();
        final difference = now.difference(createdAt);
        String dateString;

        if (difference.inDays == 0) {
          if (difference.inHours == 0) {
            dateString = '${difference.inMinutes} mins ago';
          } else {
            dateString = '${difference.inHours} hours ago';
          }
        } else if (difference.inDays == 1) {
          dateString = 'Yesterday';
        } else {
          dateString = '${difference.inDays} days ago';
        }

        
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
          'full_date': createdAt.toString(), 
          'cost': '$currencySymbol ${(cost * rate).toStringAsFixed(2)}',
          'saved': '$currencySymbol ${(saved * rate).toStringAsFixed(2)}',
          'mode': item['transport_mode'] ?? 'Car',
          'is_favorite': item['is_favorite'] ?? false,
          'vehicle_name': item['vehicle_name'],
          'fuel_type': item['fuel_type'],
          'fuel_price': item['fuel_price'],
        });
      }

      recentRoutes.assignAll(routes);
      
      loadDashboardStats();
    } catch (e) {
      debugPrint('Error loading recent routes: $e');
    }
  }

  void _loadSmartSuggestions() {
    
    smartSuggestions.assignAll([
      {
        'title':
            'Use metro instead of car for trips to Downtown Cairo to save up to 20 per trip',
        'color': 0xFFE3F2FD, 
        'textColor': 0xFF1565C0, 
        'icon': 'train',
      },
      {
        'title':
            'Combine your errands in New Cairo area to save 15 in fuel costs',
        'color': 0xFFE8F5E9, 
        'textColor': 0xFF2E7D32, 
        'icon': 'eco',
      },
      {
        'title':
            'Consider using microbus for medium distance trips (10-20km) for best value',
        'color': 0xFFFFF3E0, 
        'textColor': 0xFFEF6C00, 
        'icon': 'directions_bus',
      },
    ]);
  }
}
