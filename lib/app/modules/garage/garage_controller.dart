import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/app_snackbars.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/vehicle_service.dart';
import 'add_vehicle_view.dart';

class GarageController extends GetxController {
  final VehicleService _vehicleService = Get.find<VehicleService>();

  
  RxList<Map<String, dynamic>> get userVehicles => _vehicleService.userVehicles;
  RxBool get isLoading => _vehicleService.isLoading;

  
  
  final RxInt currentStep = 0.obs;
  PageController pageController = PageController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxList<Map<String, dynamic>> allBrands = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredBrands =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingBrands = false.obs;
  final Rxn<Map<String, dynamic>> selectedBrand = Rxn<Map<String, dynamic>>();

  final RxList<Map<String, dynamic>> allModels = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredModels =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingModels = false.obs;
  final Rxn<Map<String, dynamic>> selectedModel = Rxn<Map<String, dynamic>>();

  final RxList<int> availableYears = <int>[].obs;
  final RxnInt selectedYear = RxnInt();

  final RxString vehicleLabel = 'Personal'.obs;
  final TextEditingController customLabelController = TextEditingController();
  final RxBool isDefault = false.obs;
  final RxBool isSaving = false.obs;

  
  final RxBool showValidationErrors = false.obs;
  final RxInt shakeErrorTrigger = 0.obs;

  final RxnString selectedFuelType = RxnString();
  List<String> get fuelTypes => _vehicleService.fuelTypes;
  Map<String, double> get fuelPrices => _vehicleService.fuelPrices;

  
  final RxnString editingVehicleId = RxnString();
  bool get isEditing => editingVehicleId.value != null;

  @override
  void onInit() {
    super.onInit();
    
    if (userVehicles.isEmpty) {
      _vehicleService.fetchUserVehicles();
    }
  }

  @override
  void onClose() {
    _removeHint();
    super.onClose();
  }

  void _removeHint() {
    _hintTimer?.cancel();
    _hintOverlay?.remove();
    _hintOverlay = null;
  }

  

  Future<void> fetchBrands() async {
    try {
      isLoadingBrands.value = true;
      final response = await Supabase.instance.client
          .from('car_brands')
          .select()
          .order('name', ascending: true);

      allBrands.value = List<Map<String, dynamic>>.from(response);
      filteredBrands.value = allBrands;
    } catch (e) {
      debugPrint('Error fetching brands: $e');
    } finally {
      isLoadingBrands.value = false;
    }
  }

  void filterBrands(String query) {
    if (query.isEmpty) {
      filteredBrands.value = allBrands;
    } else {
      filteredBrands.value = allBrands
          .where((brand) => brand['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
  }

  void selectBrand(Map<String, dynamic> brand) {
    selectedBrand.value = brand;
    selectedModel.value = null;
    selectedYear.value = null;
    _fetchModels(brand['id']);
    nextStep();
  }

  Future<void> _fetchModels(String brandId) async {
    try {
      isLoadingModels.value = true;
      final response = await Supabase.instance.client
          .from('car_models')
          .select()
          .eq('brand_id', brandId)
          .order('name', ascending: true);

      allModels.value = List<Map<String, dynamic>>.from(response);
      filteredModels.value = allModels;
    } catch (e) {
      debugPrint('Error fetching models: $e');
    } finally {
      isLoadingModels.value = false;
    }
  }

  void filterModels(String query) {
    if (query.isEmpty) {
      filteredModels.value = allModels;
    } else {
      filteredModels.value = allModels
          .where((model) => model['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
  }

  void selectModel(Map<String, dynamic> model) {
    selectedModel.value = model;

    
    final int startYear = model['start_year'] ?? 1990;
    final int endYear = model['end_year'] ?? DateTime.now().year + 1;
    availableYears.value =
        List.generate(endYear - startYear + 1, (index) => endYear - index);

    nextStep();
  }

  

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
      if (pageController.hasClients) {
        pageController.jumpToPage(currentStep.value);
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      if (pageController.hasClients) {
        pageController.jumpToPage(currentStep.value);
      }
    }
  }

  void goToStep(int step) {
    currentStep.value = step;
    if (pageController.hasClients) {
      pageController.jumpToPage(step);
    }
  }

  

  void openAddVehicle() {
    resetForm();
    Get.to(
      () => const AddVehicleView(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    );
  }

  void openEditVehicle(Map<String, dynamic> vehicle) {
    resetForm(initialPage: 2);
    editingVehicleId.value = vehicle['id'];

    
    final model = vehicle['car_models'];
    final brand = model['car_brands'];

    selectedBrand.value = brand;
    selectedModel.value = model;
    selectedYear.value = vehicle['year'];
    selectedFuelType.value = vehicle['fuel_type'];
    vehicleLabel.value = vehicle['label'] ?? 'Personal';
    isDefault.value = vehicle['is_default'] ?? false;
    customLabelController.text = vehicleLabel.value;

    
    final int startYear = model['start_year'] ?? 1990;
    final int endYear = model['end_year'] ?? DateTime.now().year + 1;
    availableYears.value =
        List.generate(endYear - startYear + 1, (index) => endYear - index);

    currentStep.value = 2; 

    Get.to(
      () => const AddVehicleView(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    );
  }

  void resetForm({int initialPage = 0}) {
    _removeHint(); 
    currentStep.value = initialPage;
    if (pageController.hasClients) pageController.dispose();
    pageController = PageController(initialPage: initialPage);

    selectedBrand.value = null;
    selectedModel.value = null;
    selectedYear.value = null;
    selectedFuelType.value = null;
    vehicleLabel.value = 'Personal';
    customLabelController.clear();
    isDefault.value = false;
    editingVehicleId.value = null;
    showValidationErrors.value = false;
    shakeErrorTrigger.value = 0;

    if (allBrands.isEmpty) {
      fetchBrands();
    }
  }

  Future<void> saveVehicle() async {
    if (isSaving.value) return;
    isSaving.value = true;

    debugPrint('Attempting to save vehicle...');

    
    bool isValid = true;
    if (selectedModel.value == null) isValid = false;
    if (selectedYear.value == null) isValid = false;
    if (selectedFuelType.value == null) isValid = false;

    if (!isValid) {
      showValidationErrors.value = true;
      shakeErrorTrigger.value++; 
      isSaving.value = false; 
      AppSnackbars.showWarning(
          'Required', 'Please fill in all mandatory fields');
      return;
    }

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        AppSnackbars.showError(
            'Error', 'Unable to save vehicle. Please try again.');
        return;
      }

      debugPrint(
          'Saving vehicle for user: $userId, Model: ${selectedModel.value!['id']}, Year: ${selectedYear.value}');

      
      if (!isEditing) {
        final duplicate = userVehicles.firstWhereOrNull((v) =>
            v['model_id'] == selectedModel.value!['id'] &&
            v['year'] == selectedYear.value &&
            v['fuel_type'] == selectedFuelType.value);

        if (duplicate != null) {
          _showDuplicateDialog(duplicate);
          return;
        }
      }

      
      if (isDefault.value) {
        await Supabase.instance.client
            .from('user_vehicles')
            .update({'is_default': false}).eq('user_id', userId);
      }

      final vehicleData = {
        'user_id': userId,
        'model_id': selectedModel.value!['id'],
        'year': selectedYear.value,
        'label': vehicleLabel.value,
        'is_default': isDefault.value,
        'fuel_type': selectedFuelType.value,
      };

      if (isEditing) {
        await Supabase.instance.client
            .from('user_vehicles')
            .update(vehicleData)
            .eq('id', editingVehicleId.value!);
        await _vehicleService.fetchUserVehicles(); 
        AppSnackbars.showSuccess('Success', 'Vehicle updated successfully');
      } else {
        await Supabase.instance.client
            .from('user_vehicles')
            .insert(vehicleData);

        await _vehicleService.fetchUserVehicles(); 

        
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Vehicle Added!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          barrierDismissible: false,
        );

        
        await Future.delayed(const Duration(seconds: 2));

        if (Get.isDialogOpen == true) {
          Get.back(); 
        }

        Get.back(); 
      }

      debugPrint('Vehicle saved successfully');

      
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (e) {
      debugPrint('Error saving vehicle: $e');
      if (Get.isDialogOpen == true) Get.back(); 
      AppSnackbars.showError('Error', 'Failed to save vehicle: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> setDefault(String vehicleId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      
      await Supabase.instance.client
          .from('user_vehicles')
          .update({'is_default': false}).eq('user_id', userId);

      
      await Supabase.instance.client
          .from('user_vehicles')
          .update({'is_default': true}).eq('id', vehicleId);

      _vehicleService.fetchUserVehicles();
    } catch (e) {
      AppSnackbars.showError('Error', 'Failed to update default vehicle');
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await Supabase.instance.client
          .from('user_vehicles')
          .delete()
          .eq('id', vehicleId);
      _vehicleService.fetchUserVehicles();
    } catch (e) {
      AppSnackbars.showError('Error', 'Failed to delete vehicle');
    }
  }

  void _showDuplicateDialog(Map<String, dynamic> existingVehicle) {
    final isExistingDefault = existingVehicle['is_default'] == true;
    final brandName = existingVehicle['car_models']['car_brands']['name'];
    final modelName = existingVehicle['car_models']['name'];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded,
                    size: 48, color: Colors.orange.shade700),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vehicle Already Exists',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You already have a $brandName $modelName (${existingVehicle['year']}) in your garage.',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (!isExistingDefault)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      setDefault(existingVehicle['id']);
                      AppSnackbars.showSuccess(
                          'Success', 'Vehicle set as default');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1F36),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Set as Default'),
                  ),
                ),
              if (!isExistingDefault) const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                    openEditVehicle(existingVehicle);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF1A1F36)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Edit Existing Vehicle',
                      style: TextStyle(color: Color(0xFF1A1F36))),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel',
                    style: TextStyle(color: Colors.grey.shade600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  OverlayEntry? _hintOverlay;
  Timer? _hintTimer;
  

  Future<void> showSwipeHintIfNeeded(BuildContext context) async {
    
    if (userVehicles.isEmpty) return;

    try {
      _removeHint(); 

      _hintOverlay = OverlayEntry(
        builder: (context) => Positioned(
          bottom: 140,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF6C63FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.touch_app_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pro Tip!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Swipe items left to delete, or right to edit/default.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(_hintOverlay!);

      _hintTimer = Timer(const Duration(seconds: 6), () {
        _removeHint();
      });
    } catch (e) {
      debugPrint('Error showing hint: $e');
    }
  }
}
