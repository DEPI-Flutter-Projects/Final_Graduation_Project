import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import 'maintenance_controller.dart';

class MaintenanceView extends GetView<MaintenanceController> {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Tracker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMaintenanceCard(context),
          const SizedBox(height: 24),
          const Text('Upcoming Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Obx(() => Column(
                children: controller.upcomingServices
                    .map((service) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.secondary,
                              child: Icon(Icons.build, color: Colors.white),
                            ),
                            title: Text(service['title']),
                            subtitle: Text(service['date']),
                            trailing: Text('${service['cost']} EGP',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ).animate().fadeIn().moveX(begin: 20, end: 0))
                    .toList(),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addService,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMaintenanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vehicle Health', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          const Text('Excellent',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.9,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          const Text('Next Service in 1,200 km',
              style: TextStyle(color: Colors.white70)),
        ],
      ),
    ).animate().scale();
  }
}
