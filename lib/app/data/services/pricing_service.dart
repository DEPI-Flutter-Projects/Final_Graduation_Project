import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PricingService extends GetxService {
  final _supabase = Supabase.instance.client;
  late Box _pricingBox;

  // Reactive price variables with default fallbacks
  final RxDouble gasoline80 = 10.00.obs;
  final RxDouble gasoline92 = 13.75.obs;
  final RxDouble gasoline95 = 15.00.obs;
  final RxDouble diesel = 11.50.obs; // Sular
  final RxDouble cng = 7.00.obs; // Natural Gas (m3)

  // Aliases
  RxDouble get naturalGas => cng;

  // Metro tiers
  final RxDouble metroTier1 = 8.0.obs; // <= 9 stations
  final RxDouble metroTier2 = 10.0.obs; // <= 16 stations
  final RxDouble metroTier3 = 15.0.obs; // <= 23 stations
  final RxDouble metroTier4 = 20.0.obs; // > 23 stations

  // Aliases for Controller Compatibility
  RxDouble get metroTier1Price => metroTier1;
  RxDouble get metroTier2Price => metroTier2;
  RxDouble get metroTier3Price => metroTier3;
  RxDouble get metroTier4Price => metroTier4;

  // Metro Limits (Reactive in case they change)
  final RxInt metroTier1Limit = 9.obs;
  final RxInt metroTier2Limit = 16.obs;
  final RxInt metroTier3Limit = 23.obs;

  // Microbus base fares (estimated average)
  final RxDouble microbusShort = 5.0.obs;
  final RxDouble microbusMedium = 7.5.obs;
  final RxDouble microbusLong = 10.0.obs;

  // Constants
  double get microbusAvgConsumptionNaturalGas => 12.0;

  @override
  void onInit() {
    super.onInit();
    _initService();
  }

  Future<PricingService> init() async {
    await _initService();
    return this;
  }

  Future<void> _initService() async {
    await _initHive();
    _loadFromCache();
    // Fetch latest prices in background
    fetchLatestPrices();
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen('pricing')) {
      _pricingBox = await Hive.openBox('pricing');
    } else {
      _pricingBox = Hive.box('pricing');
    }
  }

  void _loadFromCache() {
    gasoline80.value = _pricingBox.get('gasoline80', defaultValue: 10.00);
    gasoline92.value = _pricingBox.get('gasoline92', defaultValue: 13.75);
    gasoline95.value = _pricingBox.get('gasoline95', defaultValue: 15.00);
    diesel.value = _pricingBox.get('diesel', defaultValue: 11.50);
    cng.value = _pricingBox.get('cng', defaultValue: 7.00);

    metroTier1.value = _pricingBox.get('metroTier1', defaultValue: 8.0);
    metroTier2.value = _pricingBox.get('metroTier2', defaultValue: 10.0);
    metroTier3.value = _pricingBox.get('metroTier3', defaultValue: 15.0);
    metroTier4.value = _pricingBox.get('metroTier4', defaultValue: 20.0);

    metroTier1Limit.value = _pricingBox.get('metroTier1Limit', defaultValue: 9);
    metroTier2Limit.value =
        _pricingBox.get('metroTier2Limit', defaultValue: 16);
    metroTier3Limit.value =
        _pricingBox.get('metroTier3Limit', defaultValue: 23);
  }

  Map<String, double> get allPrices => {
        'Petrol (80)': gasoline80.value,
        'Petrol (92)': gasoline92.value,
        'Petrol (95)': gasoline95.value,
        'Diesel': diesel.value,
        'Natural Gas': cng.value,
        'CNG': cng.value,
      };

  List<String> get supportedFuelTypes =>
      ['Petrol (80)', 'Petrol (92)', 'Petrol (95)', 'Diesel', 'Natural Gas'];

  Future<void> fetchLatestPrices() async {
    try {
      // Assuming a 'fuel_prices' table exists in Supabase
      // Structure: id, type (string), price (numeric)
      // types: 'gasoline_92', 'gasoline_95', 'diesel', 'cng'
      final fuelResponse = await _supabase.from('fuel_prices').select();

      for (var item in fuelResponse) {
        final type = item['type'] as String;
        final price = (item['price'] as num).toDouble();

        switch (type) {
          case 'gasoline_92':
            gasoline92.value = price;
            _pricingBox.put('gasoline92', price);
            break;
          case 'gasoline_95':
            gasoline95.value = price;
            _pricingBox.put('gasoline95', price);
            break;
          case 'diesel':
            diesel.value = price;
            _pricingBox.put('diesel', price);
            break;
          case 'cng':
            cng.value = price;
            _pricingBox.put('cng', price);
            break;
        }
      }
      // We could also have a 'metro_prices' table, but for now we'll stick to fuel
      // or assume they are in the same table with different types.
      // If user provided specific details, we would use them.
      // For now, this is a safe implementation that gracefully handles missing data.
    } catch (e) {
      // Log error instead of print
      // Get.log('Error fetching prices: $e');
    }
  }

  double getFuelPrice(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case '92':
      case 'gasoline 92':
        return gasoline92.value;
      case '95':
      case 'gasoline 95':
        return gasoline95.value;
      case 'diesel':
      case 'sular':
        return diesel.value;
      case 'natural gas':
      case 'cng':
        return cng.value;
      default:
        return gasoline92.value; // Default fallback
    }
  }

  // Helper for Route calculation
  double calculateFuelCost(
      double distanceKm, double efficiencyKmPerLiter, String fuelType) {
    final pricePerLiter = getFuelPrice(fuelType);
    final litersNeeded = distanceKm / efficiencyKmPerLiter;
    return litersNeeded * pricePerLiter;
  }
}
