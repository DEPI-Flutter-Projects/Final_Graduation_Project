import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:random_avatar/random_avatar.dart';

import 'profile_controller.dart';
import 'views/edit_profile_view.dart';
import 'views/badges_view.dart';
import 'views/spin_wheel_dialog.dart';
import '../../core/theme/app_colors.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded,
                color: AppColors.primary),
            onPressed: () {
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Gamification Guide 🎮',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(Icons.star, 'Earn XP',
                            'Complete daily challenges and trips to earn XP and level up!'),
                        const SizedBox(height: 12),
                        _buildInfoItem(Icons.military_tech, 'Collect Badges',
                            'Unlock unique badges by achieving milestones.'),
                        const SizedBox(height: 12),
                        _buildInfoItem(Icons.casino, 'Daily Spin',
                            'Spin the wheel every 24 hours for free rewards.'),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Got it!',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            
            _buildProfileHeader(context),

            const SizedBox(height: 24),

            
            _buildDailySpinCard(context),

            const SizedBox(height: 24),

            
            _buildQuickStats(context),

            const SizedBox(height: 24),

            
            _buildDailyChallengesSection(context),

            const SizedBox(height: 24),

            
            _buildBadgesSection(context),

            const SizedBox(height: 24),

            
            _buildEnvironmentalImpact(context),

            const SizedBox(height: 24),

            
            _buildPersonalInfo(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            
            Obx(() {
              double percent = 0.0;
              if (controller.nextLevelXp.value > 0) {
                percent = (controller.currentXp.value % 500) / 500;
              }
              return CircularPercentIndicator(
                radius: 65.0,
                lineWidth: 8.0,
                percent: percent.clamp(0.0, 1.0),
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: Colors.grey.shade200,
                progressColor: AppColors.primary,
                animation: true,
                animationDuration: 1000,
              );
            }),

            
            Obx(() {
              final avatarUrl = controller.userAvatarUrl.value;
              if (avatarUrl.startsWith('seed:')) {
                return RandomAvatar(
                  avatarUrl.substring(5),
                  height: 110,
                  width: 110,
                );
              }
              return CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    avatarUrl.isNotEmpty && !avatarUrl.startsWith('seed:')
                        ? NetworkImage(avatarUrl)
                        : null,
                child: avatarUrl.isEmpty
                    ? Text(
                        controller.userName.value.isNotEmpty
                            ? controller.userName.value[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      )
                    : null,
              );
            }),

            
            Positioned(
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() => Text(
                      'Lvl ${controller.level.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )),
              ),
            ),
          ],
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Obx(() => Text(
              controller.userName.value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )).animate().fadeIn().slideY(begin: 0.2, end: 0),
        Obx(() => Text(
              controller.levelName.value,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            )).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Obx(() => Text(
              '${controller.currentXp.value} XP Total',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            controller.initEditProfile();
            Get.to(() => const EditProfileView());
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimaryLight,
            side: BorderSide(color: Colors.grey.shade300),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDailySpinCard(BuildContext context) {
    return Obx(() {
      final canSpin = controller.canSpinWheel;
      return GestureDetector(
        onTap: () {
          if (canSpin) {
            Get.dialog(const SpinWheelDialog());
          } else {
            Get.snackbar('Come back tomorrow!',
                'You have already spun the wheel today.');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: canSpin
                  ? [Colors.purple.shade700, Colors.purple.shade400]
                  : [Colors.grey.shade400, Colors.grey.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (canSpin ? Colors.purple : Colors.grey)
                    .withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.casino, color: Colors.white, size: 32),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1000.ms),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Spin & Win',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      canSpin
                          ? 'Spin now to win free XP!'
                          : 'Come back tomorrow',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (canSpin)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'READY',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildQuickStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Stats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            Obx(() => _buildStatBox(Icons.alt_route, '${controller.totalTrips}',
                'Total Trips', Colors.blue)),
            Obx(() => _buildStatBox(
                Icons.trending_up,
                'EGP ${controller.totalSavings.toStringAsFixed(0)}',
                'Money Saved',
                Colors.green)),
            Obx(() => _buildStatBox(Icons.location_on_outlined,
                '${controller.kmTraveled}', 'KM Traveled', Colors.purple)),
            Obx(() => _buildStatBox(Icons.local_fire_department,
                '${controller.currentStreak}', 'Day Streak', Colors.orange)),
          ],
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Challenges',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.activeChallenges.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text('No active challenges today.')),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.activeChallenges.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final userChallenge = controller.activeChallenges[index];
              final challenge = userChallenge['challenge'];
              final isCompleted = userChallenge['is_completed'] == true;
              final progress = userChallenge['progress'] as int;
              final target = challenge['target_value'] as int;
              final percent = (progress / target).clamp(0.0, 1.0);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isCompleted
                      ? Border.all(color: Colors.green.withValues(alpha: 0.5))
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconData(challenge['icon'] ?? 'star'),
                        color: isCompleted ? Colors.green : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge['description'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted ? Colors.grey : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent,
                              backgroundColor: Colors.grey.shade200,
                              color: isCompleted
                                  ? Colors.green
                                  : AppColors.primary,
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$progress / $target',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12),
                              ),
                              Text(
                                '+${challenge['xp_reward']} XP',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(Icons.check_circle, color: Colors.green),
                      ),
                  ],
                ),
              );
            },
          );
        }).animate().fadeIn(delay: 450.ms),
      ],
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Badges',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Get.to(() => const BadgesView()),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: Obx(() {
            if (controller.badges.isEmpty) {
              return Center(
                child: Text(
                  'No badges yet. Start your journey!',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              );
            }

            
            final sortedBadges =
                List<Map<String, dynamic>>.from(controller.badges);
            sortedBadges.sort((a, b) {
              if (a['isEarned'] == b['isEarned']) return 0;
              return a['isEarned'] ? -1 : 1;
            });

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sortedBadges.take(5).length,
              itemBuilder: (context, index) {
                final badge = sortedBadges[index];
                final isEarned = badge['isEarned'] == true;
                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isEarned ? Colors.white : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isEarned
                          ? Colors.amber.withValues(alpha: 0.5)
                          : Colors.transparent,
                      width: 1,
                    ),
                    boxShadow: isEarned
                        ? [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEarned
                              ? Colors.amber.withValues(alpha: 0.1)
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconData(badge['icon']),
                          color: isEarned ? Colors.amber.shade700 : Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          badge['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isEarned ? FontWeight.bold : FontWeight.normal,
                            color: isEarned ? Colors.black87 : Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildEnvironmentalImpact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco_rounded, color: Colors.green),
              SizedBox(width: 8),
              Text('Environmental Impact',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Your contribution to a greener Egypt',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildImpactItem(
                    Icons.forest,
                    '${controller.co2Saved.value.toStringAsFixed(1)} kg',
                    'CO₂ Reduced',
                    Colors.green)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => _buildImpactItem(
                    Icons.timer_outlined,
                    '${controller.timeSaved.value.toStringAsFixed(1)} hrs',
                    'Time Saved',
                    Colors.blue)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildImpactItem(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Obx(() => _buildInfoRow(Icons.email_outlined,
              controller.userEmail.value, 'Email Address')),
          const Divider(height: 32),
          Obx(() => _buildInfoRow(
              Icons.phone_outlined,
              controller.userPhone.value.isEmpty
                  ? 'Not provided'
                  : controller.userPhone.value,
              'Phone Number')),
          const Divider(height: 32),
          Obx(() => _buildInfoRow(
              Icons.location_on_outlined,
              controller.userLocation.value.isEmpty
                  ? 'Not provided'
                  : controller.userLocation.value,
              'Location')),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildInfoRow(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey.shade700, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
      ],
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
        return Icons.star;
    }
  }
}
