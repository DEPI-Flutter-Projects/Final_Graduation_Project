import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisController extends GetxController {
  final selectedTimeRange = 'Last Month'.obs; 
  final selectedMetric = 'Money Saved'.obs; 
  final savingsTrendData = <FlSpot>[].obs;
  final transportModeData = <Map<String, dynamic>>[].obs;
  final touchedIndex = (-1).obs;

  void setTouchedIndex(int index) {
    touchedIndex.value = index;
  }

  
  final chartData = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final totalSaved = 0.0.obs;
  final totalTrips = 0.obs;
  final avgSaved = 0.0.obs;

  List<dynamic> _rawData = [];

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void setTimeRange(String range) {
    selectedTimeRange.value = range;
    fetchData();
  }

  void setMetric(String metric) {
    selectedMetric.value = metric;
    _updateBarChartData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final now = DateTime.now();
      DateTime startDate;

      switch (selectedTimeRange.value) {
        case 'Last Week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Last Month':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'All Time':
        default:
          startDate = DateTime(2020); 
          break;
      }

      final response = await Supabase.instance.client
          .from('user_routes')
          .select('saved_amount, created_at, estimated_cost, transport_mode')
          .eq('user_id', userId)
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: true);

      _rawData = response;
      _processAllData();
    } catch (e) {
      debugPrint('Error fetching analysis data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _processAllData() {
    double savedSum = 0;
    int tripsCount = 0;

    
    Map<String, int> modeCounts = {};

    
    List<FlSpot> trendSpots = [];
    double cumulativeSavings = 0;

    int index = 0;
    for (var item in _rawData) {
      final saved = (item['saved_amount'] ?? 0) as num;
      final mode = item['transport_mode'] ?? 'Unknown';

      savedSum += saved;
      tripsCount++;
      cumulativeSavings += saved;

      
      trendSpots.add(FlSpot(index.toDouble(), cumulativeSavings));
      index++;

      
      modeCounts[mode] = (modeCounts[mode] ?? 0) + 1;
    }

    totalSaved.value = savedSum;
    totalTrips.value = tripsCount;
    avgSaved.value = tripsCount > 0 ? savedSum / tripsCount : 0.0;

    
    savingsTrendData.assignAll(trendSpots);

    
    transportModeData.assignAll(modeCounts.entries
        .map((e) => {
              'mode': e.key,
              'count': e.value,
              'percentage': (e.value / tripsCount) * 100,
            })
        .toList());

    
    _updateBarChartData();
  }

  void _updateBarChartData() {
    Map<String, double> groupedData = {};

    for (var item in _rawData) {
      final createdAt = DateTime.parse(item['created_at']);
      final saved = (item['saved_amount'] ?? 0) as num;

      String key;
      if (selectedTimeRange.value == 'Last Week') {
        key = DateFormat('E').format(createdAt); 
      } else if (selectedTimeRange.value == 'Last Month') {
        key = DateFormat('d MMM').format(createdAt); 
      } else {
        key = DateFormat('MMM y').format(createdAt); 
      }

      double valueToAdd =
          selectedMetric.value == 'Money Saved' ? saved.toDouble() : 1.0;

      if (groupedData.containsKey(key)) {
        groupedData[key] = groupedData[key]! + valueToAdd;
      } else {
        groupedData[key] = valueToAdd;
      }
    }

    chartData.assignAll(groupedData.entries
        .map((e) => {
              'label': e.key,
              'value': e.value,
            })
        .toList());
  }
}
