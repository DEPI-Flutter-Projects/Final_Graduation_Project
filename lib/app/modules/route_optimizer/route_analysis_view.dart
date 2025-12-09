import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'route_optimizer_controller.dart';

class RouteAnalysisView extends GetView<RouteOptimizerController> {
  const RouteAnalysisView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Route Analysis',
            style: GoogleFonts.outfit(
                color: theme.textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.analyzeAllRoutes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
                child: Text('Could not analyze routes.',
                    style:
                        TextStyle(color: theme.textTheme.bodyMedium?.color)));
          }

          final results = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final criteria = result['criteria'] as String;
              final distance = result['distance'] as double;
              final time = result['time'] as double;
              final cost = result['cost'] as double;
              final isSelected =
                  controller.optimizationCriteria.value == criteria;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$criteria Optimization',
                            style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: AppColors.success)
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(
                              Icons.directions_car,
                              '${distance.toStringAsFixed(1)} km',
                              'Distance',
                              theme),
                          _buildStat(
                              Icons.access_time,
                              '${time.toStringAsFixed(0)} min',
                              'Est. Time',
                              theme),
                          _buildStat(
                              Icons.attach_money,
                              '\$${cost.toStringAsFixed(2)}',
                              'Est. Fuel',
                              theme),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.optimizationCriteria.value = criteria;
                            controller.optimizeRoute();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? theme.disabledColor
                                : AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                              isSelected
                                  ? 'Current Selection'
                                  : 'Select This Route',
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStat(
      IconData icon, String value, String label, ThemeData theme) {
    return Column(
      children: [
        Icon(icon,
            color: theme.iconTheme.color?.withValues(alpha: 0.7), size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color)),
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12, color: theme.textTheme.bodySmall?.color)),
      ],
    );
  }
}
