import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../profile_controller.dart';
import '../../../core/theme/app_colors.dart';

class BadgesView extends GetView<ProfileController> {
  const BadgesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Achievements',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Obx(() {
                  final earnedCount = controller.badges
                      .where((b) => b['isEarned'] == true)
                      .length;
                  return _buildHeaderStat(
                    earnedCount.toString(),
                    'Earned',
                    Icons.emoji_events,
                  );
                }),
                Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.3)),
                Obx(() => _buildHeaderStat(
                      controller.badges.length.toString(),
                      'Total',
                      Icons.military_tech,
                    )),
                Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.3)),
                Obx(() => _buildHeaderStat(
                      '${controller.currentXp.value}',
                      'XP',
                      Icons.star,
                    )),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.2, end: 0),

          
          Expanded(
            child: Obx(() {
              if (controller.badges.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              
              final sortedBadges =
                  List<Map<String, dynamic>>.from(controller.badges);
              sortedBadges.sort((a, b) {
                if (a['isEarned'] == b['isEarned']) {
                  return (b['xp_reward'] as int)
                      .compareTo(a['xp_reward'] as int);
                }
                return a['isEarned'] ? -1 : 1;
              });

              return GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: sortedBadges.length,
                itemBuilder: (context, index) {
                  final badge = sortedBadges[index];
                  return _buildBadgeItem(context, badge, index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(
      BuildContext context, Map<String, dynamic> badge, int index) {
    final isEarned = badge['isEarned'] == true;

    return GestureDetector(
      onTap: () => _showBadgeDetails(context, badge),
      child: Container(
        decoration: BoxDecoration(
          color: isEarned ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
          border: Border.all(
            color: isEarned
                ? Colors.amber.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEarned
                    ? Colors.amber.withValues(alpha: 0.1)
                    : Colors.grey.shade300, 
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(badge['icon']),
                color: isEarned
                    ? Colors.amber.shade700
                    : Colors.grey.shade600, 
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                badge['name'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                  color: isEarned ? Colors.black87 : Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.2, end: 0);
  }

  void _showBadgeDetails(BuildContext context, Map<String, dynamic> badge) {
    final isEarned = badge['isEarned'] == true;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isEarned
                      ? Colors.amber.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(badge['icon']),
                  color: isEarned ? Colors.amber.shade700 : Colors.grey,
                  size: 48,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
              Text(
                badge['name'],
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${badge['xp_reward']} XP',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                badge['description'],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              const SizedBox(height: 24),
              if (isEarned)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Unlocked',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline,
                          color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Locked',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    
    
    switch (iconName) {
      case 'directions_walk':
        return Icons.directions_walk;
      case 'commute':
        return Icons.commute;
      case 'speed':
        return Icons.speed;
      case 'forest':
        return Icons.forest;
      case 'savings':
        return Icons.savings;
      case 'nightlight_round':
        return Icons.nightlight_round;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'map':
        return Icons.map;
      case 'share':
        return Icons.share;
      case 'military_tech':
        return Icons.military_tech;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'airport_shuttle':
        return Icons.airport_shuttle;
      case 'flight':
        return Icons.flight;
      case 'location_on':
        return Icons.location_on;
      case 'directions_run':
        return Icons.directions_run;
      case 'add_road':
        return Icons.add_road;
      case 'public':
        return Icons.public;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'attach_money':
        return Icons.attach_money;
      case 'currency_exchange':
        return Icons.currency_exchange;
      case 'diamond':
        return Icons.diamond;
      case 'eco':
        return Icons.eco;
      case 'recycling':
        return Icons.recycling;
      case 'calendar_view_week':
        return Icons.calendar_view_week;
      case 'repeat':
        return Icons.repeat;
      case 'event_available':
        return Icons.event_available;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'wb_twilight':
        return Icons.wb_twilight;
      case 'nights_stay':
        return Icons.nights_stay;
      case 'restaurant':
        return Icons.restaurant;
      case 'train':
        return Icons.train;
      case 'bookmark':
        return Icons.bookmark;
      case 'explore':
        return Icons.explore;
      case 'star':
        return Icons.star;
      case 'stars':
        return Icons.stars;
      case 'casino':
        return Icons.casino;
      case 'monetization_on':
        return Icons.monetization_on;
      case 'satellite_alt':
        return Icons.satellite_alt;
      case 'shield':
        return Icons.shield;
      case 'infinity':
        return Icons.all_inclusive;
      case 'footprint':
        return Icons.directions_walk;
      case 'money':
        return Icons.money;
      case 'layers':
        return Icons.layers;
      case 'timer':
        return Icons.timer;
      case 'timelapse':
        return Icons.timelapse;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'alt_route':
        return Icons.alt_route;
      case 'feedback':
        return Icons.feedback;
      case 'info':
        return Icons.info;
      default:
        return Icons.help_outline;
    }
  }
}
