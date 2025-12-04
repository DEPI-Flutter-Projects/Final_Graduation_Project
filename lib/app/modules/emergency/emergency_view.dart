import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'emergency_controller.dart';

class EmergencyView extends GetView<EmergencyController> {
  const EmergencyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Hub (Ingedny)')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildEmergencyCard(
              context, 'Ambulance', '123', Icons.medical_services, Colors.red),
          _buildEmergencyCard(
              context, 'Police', '122', Icons.local_police, Colors.blue),
          _buildEmergencyCard(
              context, 'Fire Dept', '180', Icons.fire_truck, Colors.orange),
          _buildEmergencyCard(context, 'Roadside Assist', '12345',
              Icons.car_repair, Colors.green),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context, String title, String number,
      IconData icon, Color color) {
    return InkWell(
      onTap: () => controller.callEmergency(number),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ).animate().shimmer(
                duration: const Duration(seconds: 2),
                color: color.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(number,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      ),
    ).animate().scale();
  }
}
