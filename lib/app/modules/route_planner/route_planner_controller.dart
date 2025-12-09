import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_snackbars.dart';
import '../../data/services/pricing_service.dart';
import '../../data/services/vehicle_service.dart';
import '../map/location_picker_view.dart';
import '../map/map_controller.dart';
import '../main_layout/main_layout_controller.dart';
import '../home/home_controller.dart';
import '../settings/settings_controller.dart';
import '../../data/services/share_service.dart';
import '../profile/profile_controller.dart';

class RoutePlannerController extends GetxController {
  final startLocationController = TextEditingController();
  final endLocationController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  final stops = <TextEditingController>[].obs;
  final stopCoordinates = <int, LatLng>{}.obs;

  final routeResult = Rxn<Map<String, dynamic>>();
  final isCalculating = false.obs;

  LatLng? startCoordinates;
  LatLng? endCoordinates;

  final RxString selectedTransportMode = 'Car'.obs;
  final selectedVehicle = Rxn<Map<String, dynamic>>();

  final VehicleService _vehicleService = Get.find<VehicleService>();
  final PricingService _pricingService = Get.find<PricingService>();
  RxList<Map<String, dynamic>> get userVehicles => _vehicleService.userVehicles;

  final RxString metroPreference = 'Fastest'.obs;

  final ShareService _shareService = Get.put(ShareService());

  @override
  void onInit() {
    super.onInit();

    if (Get.isRegistered<SettingsController>()) {
      selectedTransportMode.value =
          Get.find<SettingsController>().defaultTransportMode.value;
    }

    ever(_vehicleService.userVehicles, (_) => _updateSelectedVehicle());
    _updateSelectedVehicle();

    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('from') && args.containsKey('to')) {
        startLocationController.text = args['from'];
        endLocationController.text = args['to'];
        if (args.containsKey('mode')) {
          selectedTransportMode.value = args['mode'];
        }

        Future.delayed(const Duration(milliseconds: 300), () {
          _geocodeLocations();
        });
      }
    }
  }

  void setRouteArgs(Map<String, dynamic> args) {
    if (args.containsKey('from') && args.containsKey('to')) {
      startLocationController.text = args['from'];
      endLocationController.text = args['to'];
      if (args.containsKey('mode')) {
        selectedTransportMode.value = args['mode'];
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        _geocodeLocations();
      });
    }
  }

  void _updateSelectedVehicle() {
    if (selectedVehicle.value != null) {
      final exists = _vehicleService.userVehicles
          .any((v) => v['id'] == selectedVehicle.value!['id']);
      if (!exists) {
        _selectDefaultOrFirst();
      }
    } else {
      _selectDefaultOrFirst();
    }
  }

  void _selectDefaultOrFirst() {
    final defaultVehicle = _vehicleService.getDefaultVehicle();
    if (defaultVehicle != null) {
      debugPrint('Auto-selecting default vehicle: ${defaultVehicle['id']}');
      _setVehicleFromResponse(defaultVehicle);
    } else if (_vehicleService.userVehicles.isNotEmpty) {
      debugPrint(
          'Auto-selecting first vehicle: ${_vehicleService.userVehicles.first['id']}');
      _setVehicleFromResponse(_vehicleService.userVehicles.first);
    } else {
      debugPrint('No vehicles found to auto-select');
      selectedVehicle.value = null;
    }
  }

  void shareRoute() {
    if (routeResult.value == null) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share Route',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.image, color: AppColors.primary),
                title: const Text('Share as Image'),
                subtitle: const Text('Smart card with map & details'),
                onTap: () {
                  Get.back();
                  _shareAsImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.save_alt, color: AppColors.primary),
                title: const Text('Save to Gallery'),
                subtitle: const Text('Save high-quality image to photos'),
                onTap: () {
                  Get.back();
                  _saveToGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: AppColors.primary),
                title: const Text('Share as Link'),
                subtitle: const Text('Deep link for other users'),
                onTap: () {
                  Get.back();
                  _shareAsLink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareAsImage() async {
    await _generateAndProcessImage((args) => _shareService.shareRouteImage(
          startLocation: args['startLocation'],
          endLocation: args['endLocation'],
          distance: args['distance'],
          duration: args['duration'],
          cost: args['cost'],
          routePoints: args['routePoints'],
          userName: args['userName'],
          carModel: args['carModel'],
        ));
  }

  Future<void> _saveToGallery() async {
    await _generateAndProcessImage(
        (args) => _shareService.saveRouteImageToGallery(
              startLocation: args['startLocation'],
              endLocation: args['endLocation'],
              distance: args['distance'],
              duration: args['duration'],
              cost: args['cost'],
              routePoints: args['routePoints'],
              userName: args['userName'],
              carModel: args['carModel'],
            ));
  }

  Future<void> _generateAndProcessImage(
      Future<void> Function(Map<String, dynamic>) action) async {
    if (routeResult.value == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'El-Moshwar User';

    List<LatLng> points = [];
    if (routeResult.value!['points'] is List<LatLng>) {
      points = routeResult.value!['points'];
    } else {
      if (startCoordinates != null) points.add(startCoordinates!);
      if (endCoordinates != null) points.add(endCoordinates!);
    }

    String? carModel;
    if (selectedVehicle.value != null) {
      if (selectedVehicle.value!.containsKey('name')) {
        carModel = selectedVehicle.value!['name'];
      } else {
        final brand = selectedVehicle.value!['car_brands']?['name'] ?? '';
        final model = selectedVehicle.value!['car_models']?['name'] ?? '';
        final year = selectedVehicle.value!['year'] ?? '';
        if (brand.isNotEmpty || model.isNotEmpty) {
          carModel = '$brand $model $year'.trim();
        }
      }
    }

    await action({
      'startLocation': startLocationController.text,
      'endLocation': endLocationController.text,
      'distance': routeResult.value!['distance'],
      'duration': '${routeResult.value!['duration']} min',
      'cost': routeResult.value!['cost'],
      'routePoints': points,
      'userName': userName,
      'carModel': carModel,
    });
  }

  Future<void> _shareAsLink() async {
    await _shareService.shareRouteLink(
      startLocation: startLocationController.text,
      endLocation: endLocationController.text,
      mode: selectedTransportMode.value,
    );
  }

  void _setVehicleFromResponse(Map<String, dynamic> data) {
    if (data.containsKey('car_models')) {
      final model = data['car_models'];
      final brand = model['car_brands'];
      selectedVehicle.value = {
        'id': data['id'],
        'name': '${brand['name']} ${model['name']}',
        'efficiency': model['avg_fuel_consumption'] ?? 10.0,
        'fuel': model['fuel_type'] ?? 'Petrol',
        'year': data['year'],
      };
    } else {
      selectedVehicle.value = data;
    }
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

                        if (routeResult.value != null) calculateRoute();
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
        child: SafeArea(
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
                              fontSize: 12,
                              color: AppColors.textSecondaryLight),
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
        if (routeResult.value != null) calculateRoute();
      },
    );
  }

  Future<void> _geocodeLocations() async {
    try {
      if (startLocationController.text.isNotEmpty) {
        final startPlacemarks =
            await geo.locationFromAddress(startLocationController.text);
        if (startPlacemarks.isNotEmpty) {
          startCoordinates = LatLng(
              startPlacemarks.first.latitude, startPlacemarks.first.longitude);
        }
      }

      if (endLocationController.text.isNotEmpty) {
        final endPlacemarks =
            await geo.locationFromAddress(endLocationController.text);
        if (endPlacemarks.isNotEmpty) {
          endCoordinates = LatLng(
              endPlacemarks.first.latitude, endPlacemarks.first.longitude);
        }
      }

      if (startCoordinates != null && endCoordinates != null) {
        calculateRoute();
      }
    } catch (e) {
      debugPrint('Error geocoding locations from arguments: $e');
      AppSnackbars.showWarning(
          'Location', 'Could not auto-locate addresses. Please pick from map.');
    }
  }

  @override
  void onClose() {
    startLocationController.dispose();
    endLocationController.dispose();
    for (var stop in stops) {
      stop.dispose();
    }
    super.onClose();
  }

  void setTransportMode(String mode) {
    selectedTransportMode.value = mode;

    routeResult.value = null;
  }

  void addStop() {
    if (stops.length < 5) {
      stops.add(TextEditingController());
    }
  }

  void removeStop(int index) {
    if (index >= 0 && index < stops.length) {
      stops[index].dispose();
      stops.removeAt(index);
      stopCoordinates.remove(index);

      for (int i = index + 1; i <= stops.length; i++) {
        if (stopCoordinates.containsKey(i)) {
          stopCoordinates[i - 1] = stopCoordinates[i]!;
          stopCoordinates.remove(i);
        }
      }
    }
  }

  Future<void> pickLocation(bool isStart, {int? stopIndex}) async {
    LatLng? initialCoords;
    if (isStart) {
      initialCoords = startCoordinates;
    } else if (stopIndex != null) {
      initialCoords = stopCoordinates[stopIndex];
    } else {
      initialCoords = endCoordinates;
    }

    final result = await Get.to(() => const LocationPickerView(),
        arguments: initialCoords);

    if (result != null && result is Map) {
      final LatLng coords = result['coordinates'];
      final String address = result['address'];

      if (isStart) {
        startCoordinates = coords;
        startLocationController.text = address;
      } else if (stopIndex != null) {
        stopCoordinates[stopIndex] = coords;
        if (stopIndex < stops.length) {
          stops[stopIndex].text = address;
        }
      } else {
        endCoordinates = coords;
        endLocationController.text = address;
      }

      validateLocations();
    }
  }

  void validateLocations() {
    if (startCoordinates != null && endCoordinates != null) {
      final distance = const Distance()
          .as(LengthUnit.Meter, startCoordinates!, endCoordinates!);

      if (distance < 10) {
        AppSnackbars.showWarning(
            'Location Conflict', 'Start and End locations are too close.');
      }
    }
  }

  final isLocating = false.obs;
  DateTime? _lastLocationRequestTime;

  Future<void> useCurrentLocation() async {
    if (isLocating.value) return;
    if (_lastLocationRequestTime != null &&
        DateTime.now().difference(_lastLocationRequestTime!) <
            const Duration(seconds: 2)) {
      return;
    }

    _lastLocationRequestTime = DateTime.now();
    isLocating.value = true;

    try {
      final location = Location();
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      locationData = await location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        startCoordinates =
            LatLng(locationData.latitude!, locationData.longitude!);

        try {
          List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
            locationData.latitude!,
            locationData.longitude!,
          );

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            String address = '';
            if (place.street != null && place.street!.isNotEmpty) {
              address += '${place.street}, ';
            }
            if (place.subLocality != null && place.subLocality!.isNotEmpty) {
              address += '${place.subLocality}, ';
            }
            if (place.locality != null && place.locality!.isNotEmpty) {
              address += '${place.locality}';
            }

            if (address.isEmpty) {
              address =
                  '${locationData.latitude!.toStringAsFixed(4)}, ${locationData.longitude!.toStringAsFixed(4)}';
            }
            startLocationController.text = address;
          } else {
            startLocationController.text =
                '${locationData.latitude}, ${locationData.longitude}';
          }
        } catch (e) {
          startLocationController.text =
              '${locationData.latitude}, ${locationData.longitude}';
        }

        AppSnackbars.showSuccess('Location', 'Current location set');
        validateLocations();
      }
    } catch (e) {
      AppSnackbars.showError('Error', 'Could not get location');
    } finally {
      isLocating.value = false;
    }
  }

  String? _lastCalculatedRouteHash;

  String _generateRouteHash() {
    final stopsStr = stopCoordinates.entries
        .map((e) => '${e.key}:${e.value.latitude},${e.value.longitude}')
        .join('|');
    final vehicleId = selectedVehicle.value?['id'] ?? 'none';
    return '${startCoordinates.toString()}|${endCoordinates.toString()}|$stopsStr|${selectedTransportMode.value}|$vehicleId';
  }

  Future<void> calculateRoute() async {
    if (isCalculating.value) return;

    if (startLocationController.text.isEmpty ||
        endLocationController.text.isEmpty) {
      AppSnackbars.showError(
          'Error', 'Please enter both start and end locations');
      return;
    }

    if (startCoordinates == null || endCoordinates == null) {
      AppSnackbars.showError(
          'Error', 'Invalid coordinates. Please pick locations from map.');
      return;
    }

    final currentHash = _generateRouteHash();
    if (currentHash == _lastCalculatedRouteHash) {
      return;
    }

    isCalculating.value = true;

    try {
      double totalDistanceKm = 0;
      LatLng previousPoint = startCoordinates!;

      for (int i = 0; i < stops.length; i++) {
        if (stopCoordinates.containsKey(i)) {
          final stopPoint = stopCoordinates[i]!;
          totalDistanceKm +=
              const Distance().as(LengthUnit.Meter, previousPoint, stopPoint) /
                  1000;
          previousPoint = stopPoint;
        }
      }

      totalDistanceKm += const Distance()
              .as(LengthUnit.Meter, previousPoint, endCoordinates!) /
          1000;

      double durationMin = 0;
      double cost = 0;

      if (selectedTransportMode.value == 'Car') {
        durationMin = (totalDistanceKm / 40) * 60;

        if (selectedVehicle.value != null) {
          final efficiency =
              (selectedVehicle.value!['efficiency'] as num).toDouble();
          final fuelType = selectedVehicle.value!['fuel'].toString();

          double price = 0.0;
          final allPrices = _pricingService.allPrices;

          if (allPrices.containsKey(fuelType)) {
            price = allPrices[fuelType]!;
          } else {
            if (fuelType.contains('95')) {
              price = _pricingService.gasoline95.value;
            } else if (fuelType.contains('92')) {
              price = _pricingService.gasoline92.value;
            } else if (fuelType.contains('80')) {
              price = _pricingService.gasoline80.value;
            } else if (fuelType.contains('Diesel')) {
              price = _pricingService.diesel.value;
            } else if (fuelType.contains('Natural Gas') ||
                fuelType.contains('CNG')) {
              price = _pricingService.naturalGas.value;
            } else {
              price = _pricingService.gasoline92.value;
            }
          }

          cost = (totalDistanceKm / 100) * efficiency * price;
        } else {
          cost =
              (totalDistanceKm / 100) * 10.0 * _pricingService.gasoline92.value;
        }
      } else if (selectedTransportMode.value == 'Metro') {
        durationMin = (totalDistanceKm * 3) + 7;

        int stations = (totalDistanceKm / 1.5).ceil();
        if (metroPreference.value == 'Least Stations') {
          stations = (stations * 0.8).ceil();
          durationMin *= 0.9;
        }

        if (totalDistanceKm > 0 && stations < 1) stations = 1;

        if (stations <= _pricingService.metroTier1Limit.value) {
          cost = _pricingService.metroTier1Price.value.toDouble();
        } else if (stations <= _pricingService.metroTier2Limit.value) {
          cost = _pricingService.metroTier2Price.value.toDouble();
        } else if (stations <= _pricingService.metroTier3Limit.value) {
          cost = _pricingService.metroTier3Price.value.toDouble();
        } else {
          cost = _pricingService.metroTier4Price.value.toDouble();
        }
      } else {
        durationMin = (totalDistanceKm / 30) * 60;

        double totalTripCost = (totalDistanceKm / 100) *
            _pricingService.microbusAvgConsumptionNaturalGas *
            _pricingService.naturalGas.value;

        cost = totalTripCost / 2;

        if (cost < 1.0) cost = 1.0;
      }

      double savings = 0;
      if (selectedTransportMode.value != 'Car') {
        double carCost =
            (totalDistanceKm / 100) * 10.0 * _pricingService.gasoline92.value;
        if (cost < carCost) {
          savings = carCost - cost;
        }
      }

      final settings = Get.find<SettingsController>();

      String distanceStr;
      double displayDistance = totalDistanceKm;
      if (settings.distanceUnit.value == 'Miles') {
        displayDistance = totalDistanceKm * 0.621371;
        distanceStr = '${displayDistance.toStringAsFixed(1)} mi';
      } else {
        distanceStr = '${totalDistanceKm.toStringAsFixed(1)} km';
      }

      String costStr;
      String savedStr;
      double displayCost = cost;
      double displaySaved = savings;
      String currencySymbol = settings.currency.value;
      double rate = settings.exchangeRate.value;

      displayCost = cost * rate;
      displaySaved = savings * rate;

      costStr = '$currencySymbol ${displayCost.toStringAsFixed(2)}';
      savedStr = '$currencySymbol ${displaySaved.toStringAsFixed(2)}';

      routeResult.value = {
        'distance': distanceStr,
        'duration': durationMin.round().toString(),
        'cost': costStr,
        'mode': selectedTransportMode.value,
        'saved': savedStr,
        'raw_cost': cost,
        'raw_saved': savings,
        'raw_distance': totalDistanceKm,
        'raw_duration': durationMin,
      };

      if (Get.isRegistered<MapController>()) {
        final mapController = Get.find<MapController>();
        mapController.setRoute(startCoordinates!, endCoordinates!);
      }

      if (selectedVehicle.value == null &&
          selectedTransportMode.value == 'Car') {
        _selectDefaultOrFirst();
      }

      String? vehicleName;
      String? fuelType;
      double? fuelPrice;

      if (selectedVehicle.value != null) {
        vehicleName = selectedVehicle.value!['name'];
        fuelType = selectedVehicle.value!['fuel'];
      } else if (selectedTransportMode.value == 'Car') {
        vehicleName = 'Standard Car';
        fuelType = 'Petrol (92)';
      }

      await _saveRouteToHistory(
        startAddress: startLocationController.text,
        endAddress: endLocationController.text,
        distance: totalDistanceKm,
        duration: durationMin,
        cost: cost,
        savedAmount: savings,
        mode: selectedTransportMode.value,
        vehicleName: vehicleName,
        fuelType: fuelType,
        fuelPrice: fuelPrice,
      );

      _lastCalculatedRouteHash = currentHash;
    } finally {
      isCalculating.value = false;
    }
  }

  Future<void> startNavigation() async {
    if (routeResult.value == null) return;

    if (Get.isRegistered<MainLayoutController>()) {
      Get.find<MainLayoutController>().changePage(2);
    } else {
      Get.toNamed('/map_view');
    }
  }

  Future<void> _saveRouteToHistory({
    required String startAddress,
    required String endAddress,
    required double distance,
    required double duration,
    required double cost,
    required double savedAmount,
    required String mode,
    String? vehicleName,
    String? fuelType,
    double? fuelPrice,
  }) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client.from('user_routes').insert({
        'user_id': userId,
        'from_location': startAddress,
        'to_location': endAddress,
        'distance_km': distance,
        'transport_mode': mode,
        'cost': cost,
        'duration_minutes': duration.round(),
        'start_address': startAddress,
        'end_address': endAddress,
        'total_distance_km': distance,
        'total_duration_min': duration.round(),
        'estimated_cost': cost,
        'saved_amount': savedAmount,
        'vehicle_name': vehicleName,
        'fuel_type': fuelType,
        'fuel_price': fuelPrice,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadRecentRoutes();
      }

      if (Get.isRegistered<ProfileController>()) {
        final profile = Get.find<ProfileController>();
        await profile.updateStats(
          distanceKm: distance,
          savings: savedAmount,
          transportMode: mode,
        );
      }
    } catch (e) {
      debugPrint('Error saving route history: $e');
    }
  }
}
