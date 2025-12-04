import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'route_optimizer_controller.dart';

class RouteAnalysisView extends GetView<RouteOptimizerController> {
  const RouteAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Route Analysis',
            style: GoogleFonts.outfit(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
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
            return const Center(child: Text('Could not analyze routes.'));
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
                            const Icon(Icons.check_circle, color: Colors.green)
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(Icons.directions_car,
                              '${distance.toStringAsFixed(1)} km', 'Distance'),
                          _buildStat(Icons.access_time,
                              '${time.toStringAsFixed(0)} min', 'Est. Time'),
                          _buildStat(Icons.attach_money,
                              '\$${cost.toStringAsFixed(2)}', 'Est. Fuel'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            controller.optimizationCriteria.value = criteria;
                            controller
                                .optimizeRoute(); 
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSelected ? Colors.grey : AppColors.primary,
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

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style:
                GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label,
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
