import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../garage_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_snackbars.dart';
import '../../../data/services/vehicle_service.dart';
import '../../../routes/app_routes.dart';

class VehicleSelectorWidget extends GetView<VehicleService> {
  const VehicleSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleService = Get.find<VehicleService>();

    GarageController? garageController;
    try {
      if (Get.isRegistered<GarageController>()) {
        garageController = Get.find<GarageController>();
      }
    } catch (_) {}

    if (garageController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        garageController!.showSwipeHintIfNeeded(context);
      });
    }

    return Obx(() {
      final activeVehicle = vehicleService.activeVehicle.value;

      return GestureDetector(
        onTap: () => _showVehicleSelectionSheet(
            context, vehicleService, garageController),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.directions_car, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Vehicle',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeVehicle != null
                          ? '${activeVehicle['car_models']['car_brands']['name']} ${activeVehicle['car_models']['name']}'
                          : 'Select a Vehicle',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textTertiaryLight),
            ],
          ),
        ),
      );
    });
  }

  void _showVehicleSelectionSheet(BuildContext context, VehicleService service,
      GarageController? garageController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Vehicle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Obx(() => Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ...service.userVehicles.map((vehicle) {
                          final isSelected =
                              service.activeVehicle.value?['id'] ==
                                  vehicle['id'];
                          return _buildVehicleTile(
                              vehicle, isSelected, service, garageController);
                        }),
                        _buildAddVehicleTile(),
                      ],
                    )),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildVehicleTile(Map<String, dynamic> vehicle, bool isSelected,
      VehicleService service, GarageController? controller) {
    final brandName = vehicle['car_models']['car_brands']['name'];
    final modelName = vehicle['car_models']['name'];

    final color = _getVehicleColor(brandName);

    if (controller == null) {
      return GestureDetector(
        onTap: () {
          service.setActiveVehicle(vehicle);
          Get.back();
        },
        child: _buildVehicleCardContent(
            brandName, modelName, vehicle, color, isSelected),
      );
    }

    return Dismissible(
      key: Key(vehicle['id'].toString()),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.star, color: Colors.white, size: 30),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          controller.setDefault(vehicle['id']);
          Get.back();
          AppSnackbars.showSuccess('Success', 'Vehicle set as default');
          return false;
        } else {
          return await Get.dialog(
            AlertDialog(
              title: const Text('Delete Vehicle'),
              content:
                  const Text('Are you sure you want to delete this vehicle?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Get.back(result: true);
                    controller.deleteVehicle(vehicle['id']);
                  },
                  child:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          service.setActiveVehicle(vehicle);
          Get.back();
        },
        onLongPress: () {
          Get.back();
          controller.openEditVehicle(vehicle);
        },
        child: _buildVehicleCardContent(
            brandName, modelName, vehicle, color, isSelected),
      ),
    );
  }

  Widget _buildVehicleCardContent(String brandName, String modelName,
      Map<String, dynamic> vehicle, Color color, bool isSelected) {
    return Container(
      width: (Get.width - 48 - 12) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.directions_car_filled, color: color, size: 28),
              if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            brandName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            modelName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              vehicle['fuel_type'] ?? 'Petrol',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddVehicleTile() {
    return GestureDetector(
      onTap: () {
        Get.back();
        Get.toNamed(Routes.addVehicle);
      },
      child: Container(
        width: Get.width - 48,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add New Vehicle',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getVehicleColor(String brand) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[brand.hashCode % colors.length];
  }
}
