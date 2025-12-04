import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../home_controller.dart';

class RecentRoutesView extends GetView<HomeController> {
  const RecentRoutesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Recent Routes',
          style: TextStyle(
            color: AppColors.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryLight),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search routes...',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textSecondaryLight),
                filled: true,
                fillColor: AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          
          Expanded(
            child: Obx(() {
              if (controller.recentRoutes.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history,
                          size: 64, color: AppColors.textTertiaryLight),
                      SizedBox(height: 16),
                      Text(
                        'No route history',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.recentRoutes.length,
                itemBuilder: (context, index) {
                  final route = controller.recentRoutes[index];
                  return _buildRouteCard(route, index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              onTap: () => Get.toNamed(Routes.ROUTE_DETAILS, arguments: route),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTransportBadge(route['mode']),
                        Text(
                          route['date'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.circle,
                                size: 12, color: AppColors.success),
                            Container(
                              height: 24,
                              width: 2,
                              color: AppColors.border,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                            const Icon(Icons.location_on,
                                size: 12, color: AppColors.error),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route['from'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                route['to'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Cost',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              route['cost'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'You Saved',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              route['saved'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Material(
            color: AppColors.backgroundLight,
            child: InkWell(
              onTap: () {
                Get.toNamed(Routes.ROUTE_PLANNER, arguments: {
                  'from': route['from'],
                  'to': route['to'],
                  'mode': route['mode'],
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Re-calculate',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (50 * index).ms).moveY(begin: 10, end: 0);
  }

  Widget _buildTransportBadge(String mode) {
    Color color;
    IconData icon;

    switch (mode.toLowerCase()) {
      case 'metro':
        color = AppColors.metroColor;
        icon = Icons.train;
        break;
      case 'car':
        color = AppColors.carColor;
        icon = Icons.directions_car;
        break;
      case 'microbus':
        color = AppColors.microbusColor;
        icon = Icons.directions_bus;
        break;
      default:
        color = AppColors.textSecondaryLight;
        icon = Icons.directions;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            mode,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
