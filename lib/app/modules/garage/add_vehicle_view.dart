import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import 'garage_controller.dart';

class AddVehicleView extends GetView<GarageController> {
  const AddVehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GarageController>(
      initState: (_) => controller.fetchBrands(),
      builder: (_) {
        final theme = Get.theme;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Obx(() => Text(
                  controller.isEditing ? 'Edit Vehicle' : 'Add New Vehicle',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                )),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon:
                  Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
              onPressed: () {
                if (controller.currentStep.value > 0 && !controller.isEditing) {
                  controller.previousStep();
                } else {
                  Get.back();
                }
              },
            ),
          ),
          body: Column(
            children: [
              _buildCustomStepper(theme),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: controller.pageController,
                  children: [
                    _buildBrandStep(theme),
                    _buildModelStep(theme),
                    _buildDetailsStep(theme),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(theme),
        );
      },
    );
  }

  Widget _buildCustomStepper(ThemeData theme) {
    if (controller.isEditing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Edit Vehicle Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        return Row(
          children: [
            _buildStepIndicator(0, 'Make', Icons.directions_car, theme),
            _buildStepConnector(0, theme),
            _buildStepIndicator(1, 'Model', Icons.tune, theme),
            _buildStepConnector(1, theme),
            _buildStepIndicator(2, 'Details', Icons.edit_note, theme),
          ],
        );
      }),
    );
  }

  Widget _buildStepIndicator(
      int step, String label, IconData icon, ThemeData theme) {
    final isActive = controller.currentStep.value >= step;
    final isCurrent = controller.currentStep.value == step;
    final color = isActive ? theme.colorScheme.primary : theme.disabledColor;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCurrent ? theme.colorScheme.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isCurrent
                  ? theme.colorScheme.onPrimary
                  : (isActive
                      ? theme.colorScheme.primary
                      : theme.disabledColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? theme.textTheme.bodyMedium?.color
                  : theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step, ThemeData theme) {
    final isActive = controller.currentStep.value > step;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? theme.colorScheme.primary : theme.dividerColor,
        margin: const EdgeInsets.only(bottom: 20),
      ),
    );
  }

  Widget _buildBrandStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Car Brand',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: controller.filterBrands,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search brands...',
              hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingBrands.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: controller.filteredBrands.length,
                itemBuilder: (context, index) {
                  final brand = controller.filteredBrands[index];
                  final isSelected =
                      controller.selectedBrand.value?['id'] == brand['id'];
                  return GestureDetector(
                    onTap: () => controller.selectBrand(brand),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (brand['logo_url'] != null)
                            CachedNetworkImage(
                              imageUrl: brand['logo_url'],
                              height: 56,
                              width: 56,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Icon(
                                Icons.directions_car_filled,
                                size: 32,
                                color: theme.disabledColor,
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.directions_car_filled,
                                size: 32,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.disabledColor,
                              ),
                            )
                          else
                            Icon(
                              Icons.directions_car_filled,
                              size: 32,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.disabledColor,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            brand['name'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildModelStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Model',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: controller.filterModels,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search models...',
              hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingModels.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.separated(
                itemCount: controller.filteredModels.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final model = controller.filteredModels[index];
                  final isSelected =
                      controller.selectedModel.value?['id'] == model['id'];
                  return GestureDetector(
                    onTap: () => controller.selectModel(model),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.disabledColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.disabledColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model['name'],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                if (model['year_start'] != null)
                                  Text(
                                    '${model['year_start']} - ${model['year_end'] ?? 'Present'}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.disabledColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle,
                                color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildDetailSection(
              'Model Year',
              Icons.calendar_today,
              Obx(() {
                final hasError = controller.showValidationErrors.value &&
                    controller.selectedYear.value == null;
                return ShakeWidget(
                  trigger: controller.shakeErrorTrigger.value,
                  shouldShake: hasError,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: controller.selectedYear.value,
                        decoration: _inputDecoration(),
                        items: controller.availableYears.map((year) {
                          return DropdownMenuItem(
                              value: year, child: Text(year.toString()));
                        }).toList(),
                        onChanged: (val) => controller.selectedYear.value = val,
                        validator: (value) => null,
                      ),
                      if (hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Text(
                            'Please select a model year',
                            style: TextStyle(
                              color: Theme.of(Get.context!).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            _buildDetailSection(
              'Fuel Type',
              Icons.local_gas_station,
              Obx(() {
                final hasError = controller.showValidationErrors.value &&
                    controller.selectedFuelType.value == null;
                return ShakeWidget(
                  trigger: controller.shakeErrorTrigger.value,
                  shouldShake: hasError,
                  child: _buildFuelTypeSelector(),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              'Label',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    ['Personal', 'Work', 'Family', 'Weekend'].map((label) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Obx(() {
                      final isSelected = controller.vehicleLabel.value == label;
                      return GestureDetector(
                        onTap: () => controller.vehicleLabel.value = label,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? theme.cardColor : theme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : theme.dividerColor,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : theme.textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.customLabelController,
              decoration: _inputDecoration(hint: 'Or enter custom label'),
              onChanged: (val) {
                if (val.isNotEmpty) controller.vehicleLabel.value = val;
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.star, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set as Default',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Use for calculations by default',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Obx(() => Switch(
                        value: controller.isDefault.value,
                        onChanged: (val) => controller.isDefault.value = val,
                        activeThumbColor: AppColors.primary,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelTypeSelector() {
    final theme = Get.theme;
    return Obx(() {
      final hasError = controller.showValidationErrors.value &&
          controller.selectedFuelType.value == null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.fuelTypes.map((type) {
              final isSelected = controller.selectedFuelType.value == type;
              final displayType = type == 'CNG' ? 'Natural Gas' : type;
              final price = controller.fuelPrices[type];

              Color typeColor;
              IconData typeIcon;
              if (type.contains('95')) {
                typeColor = Colors.red;
                typeIcon = Icons.local_fire_department;
              } else if (type.contains('92')) {
                typeColor = Colors.orange;
                typeIcon = Icons.local_gas_station;
              } else if (type.contains('80')) {
                typeColor = Colors.purple;
                typeIcon = Icons.opacity;
              } else if (type == 'Diesel') {
                typeColor = Colors.blueGrey;
                typeIcon = Icons.directions_bus;
              } else if (type == 'CNG') {
                typeColor = Colors.teal;
                typeIcon = Icons.eco;
              } else {
                typeColor = AppColors.primary;
                typeIcon = Icons.local_gas_station;
              }

              final itemWidth = (Get.width - 40 - 16) / 3;

              return GestureDetector(
                onTap: () => controller.selectedFuelType.value = type,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: itemWidth,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? typeColor : theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? typeColor
                          : (hasError
                              ? theme.colorScheme.error.withValues(alpha: 0.5)
                              : theme.dividerColor),
                      width: hasError ? 1.5 : (isSelected ? 1.5 : 1),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: typeColor.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            )
                          ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        typeIcon,
                        color: isSelected ? Colors.white : typeColor,
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayType,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price != null
                            ? '${price.toStringAsFixed(2)} EGP'
                            : 'N/A',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.9)
                              : theme.textTheme.bodySmall?.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                'Please select a fuel type',
                style: TextStyle(
                  color: Theme.of(Get.context!).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildDetailSection(String title, IconData icon, Widget content) {
    final theme = Get.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                size: 18, color: theme.iconTheme.color?.withValues(alpha: 0.6)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Get.theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(Get.context!).padding.bottom + 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final isLastStep = controller.currentStep.value == 2;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (isLastStep || controller.isEditing) {
                controller.saveVehicle();
              } else {
                controller.nextStep();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              isLastStep || controller.isEditing ? 'Save Vehicle' : 'Next Step',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final int trigger;
  final bool shouldShake;
  final Duration duration;
  final double deltaX;
  final Curve curve;

  const ShakeWidget({
    super.key,
    required this.child,
    required this.trigger,
    this.shouldShake = true,
    this.duration = const Duration(milliseconds: 500),
    this.deltaX = 20,
    this.curve = Curves.bounceOut,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> offsetAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    offsetAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: widget.curve))
        .animate(controller);
  }

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.shouldShake) {
      controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: offsetAnimation,
      builder: (context, child) {
        final sineValue = math.sin(offsetAnimation.value * 3 * math.pi) *
            (1 - offsetAnimation.value);
        return Transform.translate(
          offset: Offset(sineValue * widget.deltaX, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
