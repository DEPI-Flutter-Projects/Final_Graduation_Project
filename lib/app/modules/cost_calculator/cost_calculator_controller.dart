import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_snackbars.dart';
import '../../core/values/pricing_constants.dart';
import '../../data/services/vehicle_service.dart';

class CostCalculatorController extends GetxController {
  final distanceController = TextEditingController();

  final selectedVehicle = Rxn<Map<String, dynamic>>();
  final calculationResults = <Map<String, dynamic>>[].obs;
  final isLoadingVehicle = false.obs;

  final VehicleService _vehicleService = Get.find<VehicleService>();

  
  final double petrolPrice = 13.0; 
  final double dieselPrice = 11.5; 
  final double electricPrice = 2.0; 

  @override
  void onInit() {
    super.onInit();
    
    ever(_vehicleService.userVehicles, (_) => _updateSelectedVehicle());
    _updateSelectedVehicle();
  }

  void _updateSelectedVehicle() {
    final vehicles = _vehicleService.userVehicles;

    
    if (vehicles.isEmpty) {
      selectedVehicle.value = null;
      return;
    }

    
    if (selectedVehicle.value != null) {
      final currentId = selectedVehicle.value!['id'];
      
      
      if (currentId is int) {
        final exists = vehicles.any((v) => v['id'] == currentId);
        if (!exists) {
          
          _selectDefaultOrFirst();
        }
      }
      
      
    } else {
      
      _selectDefaultOrFirst();
    }
  }

  void _selectDefaultOrFirst() {
    final defaultVehicle = _vehicleService.getDefaultVehicle();
    if (defaultVehicle != null) {
      _setVehicleFromResponse(defaultVehicle);
    } else if (_vehicleService.userVehicles.isNotEmpty) {
      _setVehicleFromResponse(_vehicleService.userVehicles.first);
    } else {
      selectedVehicle.value = null;
    }
  }

  @override
  void onClose() {
    distanceController.dispose();
    super.onClose();
  }
  

  void _setVehicleFromResponse(Map<String, dynamic> data) {
    final model = data['car_models'];
    final brand = model['car_brands'];
    selectedVehicle.value = {
      'id': data['id'],
      'name': '${brand['name']} ${model['name']}',
      'efficiency': model['avg_fuel_consumption'] ?? 10.0, 
      'fuel': model['fuel_type'] ?? 'Petrol',
      'year': data['year'],
    };
  }

  void selectVehicle() {
    final vehicles = _vehicleService.userVehicles;

    if (vehicles.isEmpty) {
      _showSmartSuggestions();
      return;
    }

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Select Vehicle',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: vehicles.length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final v = vehicles[index];
                    final model = v['car_models'];
                    final brand = model['car_brands'];
                    final isSelected = selectedVehicle.value?['id'] == v['id'];

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.directions_car,
                            color: AppColors.primary),
                      ),
                      title: Text('${brand['name']} ${model['name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                          Text('${v['year']} • ${v['label'] ?? 'Personal'}'),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary)
                          : null,
                      onTap: () {
                        _setVehicleFromResponse(v);
                        Get.back();
                        if (distanceController.text.isNotEmpty) {
                          calculateCosts();
                        }
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.toNamed('/garage');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Vehicle'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showSmartSuggestions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: AppColors.warning, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Vehicles Found',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Add a vehicle or choose a smart suggestion',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  Get.toNamed('/garage');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Your Vehicle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Smart Suggestions',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 12),

            _buildSuggestionTile(
              name: 'Economic Sedan',
              desc: 'e.g., Nissan Sunny, Renault Logan',
              efficiency: 7.5,
              fuel: 'Petrol (92)',
              icon: Icons.savings_outlined,
            ),
            _buildSuggestionTile(
              name: 'Standard Sedan',
              desc: 'e.g., Toyota Corolla, Hyundai Elantra',
              efficiency: 8.5,
              fuel: 'Petrol (92)',
              icon: Icons.directions_car_outlined,
            ),
            _buildSuggestionTile(
              name: 'City SUV',
              desc: 'e.g., Kia Sportage, Hyundai Tucson',
              efficiency: 10.5,
              fuel: 'Petrol (92)',
              icon: Icons.airport_shuttle_outlined,
            ),
            _buildSuggestionTile(
              name: 'Budget / Older',
              desc: 'e.g., Hyundai Verna, Lanos',
              efficiency: 9.0,
              fuel: 'Petrol (80)',
              icon: Icons.history_outlined,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSuggestionTile({
    required String name,
    required String desc,
    required double efficiency,
    required String fuel,
    required IconData icon,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.textSecondaryLight),
      ),
      title: Text(name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('$efficiency L/100km',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Fuel',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primary),
            ],
          ),
        ],
      ),
      onTap: () {
        
        Get.dialog(
          AlertDialog(
            title: const Text('Select Fuel Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFuelOption(name, efficiency, 'Petrol (80)', '80 Octane'),
                _buildFuelOption(name, efficiency, 'Petrol (92)', '92 Octane'),
                _buildFuelOption(name, efficiency, 'Petrol (95)', '95 Octane'),
                _buildFuelOption(name, efficiency, 'Diesel', 'Diesel'),
                _buildFuelOption(
                    name, efficiency, 'Natural Gas', 'Natural Gas'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFuelOption(
      String carName, double efficiency, String fuelType, String label) {
    return ListTile(
      title: Text(label),
      onTap: () {
        selectedVehicle.value = {
          'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
          'name': carName,
          'efficiency': efficiency,
          'fuel': fuelType,
          'year': 'N/A',
        };
        Get.back(); 
        Get.back(); 
        if (distanceController.text.isNotEmpty) calculateCosts();
      },
    );
  }

  void setPresetDistance(int distance) {
    distanceController.text = distance.toString();
    calculateCosts();
  }

  void calculateCosts() {
    if (distanceController.text.isEmpty) {
      AppSnackbars.showError('Error', 'Please enter a distance');
      return;
    }

    final distance = double.tryParse(distanceController.text);
    if (distance == null || distance <= 0) {
      AppSnackbars.showError('Error', 'Please enter a valid distance');
      return;
    }

    

    
    double carCostVal = 0;
    String carDetails = 'Estimated (Generic Car)';
    if (selectedVehicle.value != null) {
      final efficiency =
          (selectedVehicle.value!['efficiency'] as num).toDouble(); 
      final fuelType = selectedVehicle.value!['fuel'].toString();

      double price = 0.0;
      if (fuelType.contains('95')) {
        price = PricingConstants.gasoline95;
      } else if (fuelType.contains('92')) {
        price = PricingConstants.gasoline92;
      } else if (fuelType.contains('80')) {
        price = PricingConstants.gasoline80;
      } else if (fuelType.contains('Diesel')) {
        price = PricingConstants.diesel;
      } else if (fuelType.contains('Natural Gas') || fuelType.contains('CNG')) {
        price = PricingConstants.naturalGas;
      } else {
        price = PricingConstants.gasoline92;
      }
      carCostVal = (distance / 100) * efficiency * price;
      carDetails = 'Based on your car';
    } else {
      carCostVal = (distance / 100) * 10.0 * PricingConstants.gasoline92;
    }
    final carDurationVal = (distance * 1.5).round(); 

    
    double metroCostVal = 0;
    int stations = (distance / 1.5).ceil();
    if (distance > 0 && stations < 1) stations = 1;
    if (stations <= PricingConstants.metroTier1Limit) {
      metroCostVal = PricingConstants.metroTier1Price.toDouble();
    } else if (stations <= PricingConstants.metroTier2Limit) {
      metroCostVal = PricingConstants.metroTier2Price.toDouble();
    } else if (stations <= PricingConstants.metroTier3Limit) {
      metroCostVal = PricingConstants.metroTier3Price.toDouble();
    } else {
      metroCostVal = PricingConstants.metroTier4Price.toDouble();
    }
    final metroDurationVal = ((distance * 2.0) + 5).round(); 

    
    double microbusCostVal = 0;
    double totalTripCost = (distance / 100) *
        PricingConstants.microbusAvgConsumptionNaturalGas *
        PricingConstants.naturalGas;
    microbusCostVal = totalTripCost / 2;
    if (microbusCostVal < 1.0) microbusCostVal = 1.0;
    final microbusDurationVal = (distance * 2.0).round(); 

    
    
    
    
    const double timeValuePerMin = 0.75;

    final carScore = carCostVal + (carDurationVal * timeValuePerMin);
    final metroScore = metroCostVal + (metroDurationVal * timeValuePerMin);
    final microbusScore =
        microbusCostVal + (microbusDurationVal * timeValuePerMin);

    
    final scores = {
      'Car': carScore,
      'Metro': metroScore,
      'Microbus': microbusScore
    };
    final costs = {
      'Car': carCostVal,
      'Metro': metroCostVal,
      'Microbus': microbusCostVal
    };
    final durations = {
      'Car': carDurationVal,
      'Metro': metroDurationVal,
      'Microbus': microbusDurationVal
    };

    final bestMode =
        scores.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    final cheapestMode =
        costs.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    final fastestMode =
        durations.entries.reduce((a, b) => a.value < b.value ? a : b).key;

    
    final List<Map<String, dynamic>> results = [
      {
        'mode': 'Car',
        'cost': 'EGP ${carCostVal.toStringAsFixed(1)}',
        'duration': '$carDurationVal min',
        'details': carDetails,
        'icon': Icons.directions_car,
        'color': 0xFF4285F4,
        'raw_cost': carCostVal,
        'raw_duration': carDurationVal,
        'score': carScore,
      },
      {
        'mode': 'Metro',
        'cost': 'EGP ${metroCostVal.toStringAsFixed(1)}',
        'duration': '$metroDurationVal min',
        'details': 'Ticket price',
        'icon': Icons.train,
        'color': 0xFF34A853,
        'raw_cost': metroCostVal,
        'raw_duration': metroDurationVal,
        'score': metroScore,
      },
      {
        'mode': 'Microbus',
        'cost': 'EGP ${microbusCostVal.toStringAsFixed(1)}',
        'duration': '$microbusDurationVal min',
        'details': 'Avg fare',
        'icon': Icons.directions_bus,
        'color': 0xFFFBBC04,
        'raw_cost': microbusCostVal,
        'raw_duration': microbusDurationVal,
        'score': microbusScore,
      },
    ];

    
    results
        .sort((a, b) => (a['score'] as double).compareTo(b['score'] as double));

    
    for (var result in results) {
      final mode = result['mode'];
      final List<String> badges = [];

      if (mode == bestMode) badges.add('BEST VALUE');
      if (mode == cheapestMode && mode != bestMode) badges.add('CHEAPEST');
      if (mode == fastestMode && mode != bestMode) badges.add('FASTEST');

      result['badges'] = badges;
    }

    calculationResults.assignAll(results);
  }
}
