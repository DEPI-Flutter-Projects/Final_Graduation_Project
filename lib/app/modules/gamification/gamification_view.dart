import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'gamification_controller.dart';

class GamificationView extends GetView<GamificationController> {
  const GamificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track your milestones and unlock new badges',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Obx(() => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.achievements.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = controller.achievements[index];
                    return _buildAchievementCard(context, item);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
      BuildContext context, Map<String, dynamic> item) {
    final bool unlocked = item['unlocked'] == true;
    final Color color = unlocked ? item['color'] as Color : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: unlocked ? Colors.yellow.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? Colors.yellow.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: unlocked ? Colors.white : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'] as IconData, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        if (unlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Unlocked',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'],
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                    if (item['date'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item['date'],
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!unlocked) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progress',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(item['progressText'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item['progress'],
                backgroundColor: Colors.grey.shade300,
                color: Colors.black,
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().moveX(begin: 20, end: 0);
  }
}
