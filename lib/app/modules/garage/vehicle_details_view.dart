import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'garage_controller.dart';

class VehicleDetailsView extends GetView<GarageController> {
  final Map<String, dynamic> vehicle;
  const VehicleDetailsView({super.key, required this.vehicle});

  @override
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      
      final updatedVehicle = controller.userVehicles.firstWhere(
        (v) => v['id'] == vehicle['id'],
        orElse: () => vehicle,
      );

      final model = updatedVehicle['car_models'] ?? {};
      final brand = model['car_brands'] ?? {};
      final isDefault = updatedVehicle['is_default'] == true;

      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text('${brand['name']} ${model['name']}'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => controller.openEditVehicle(updatedVehicle),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_car,
                          size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${brand['name']} ${model['name']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model['engine_capacity'] != null
                          ? '${updatedVehicle['year']} • ${model['engine_capacity']}cc'
                          : '${updatedVehicle['year']}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow('Efficiency',
                        '${model['avg_fuel_consumption']} L/100km'),
                    _buildInfoRow('Fuel Type',
                        '${updatedVehicle['fuel_type'] ?? model['fuel_type']}'),
                    _buildInfoRow(
                        'Label', '${updatedVehicle['label'] ?? 'Personal'}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              
              if (!isDefault)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.setDefault(updatedVehicle['id']);
                      Get.back();
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Set as Default Vehicle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success),
                      SizedBox(width: 8),
                      Text(
                        'Default Vehicle',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: AppColors.warning),
                        SizedBox(width: 8),
                        Text(
                          'Vehicle Tips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fuel Efficiency Tips:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint('Maintain proper tire pressure'),
                    _buildBulletPoint('Regular engine maintenance'),
                    _buildBulletPoint('Avoid aggressive driving'),
                    _buildBulletPoint('Remove excess weight'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondaryLight),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text(
            'Are you sure you want to delete this vehicle? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); 
              controller.deleteVehicle(vehicle['id']);
              Get.back(); 
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
