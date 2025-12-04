import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:random_avatar/random_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../routes/app_routes.dart';
import '../main_layout/main_layout_controller.dart';
import 'home_controller.dart';
import '../settings/settings_controller.dart';
import '../../data/services/notification_service.dart';
import 'widgets/saved_details_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 20),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.favorite, color: Colors.white, size: 20),
                ),
                onPressed: () => Get.toNamed(Routes.FAVORITES),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 20),
                    ),
                    onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
                  ),
                  Obx(() {
                    final unreadCount =
                        Get.find<NotificationService>().unreadCount.value;
                    if (unreadCount > 0) {
                      return Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Stack(
                  children: [
                    
                    
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 70, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _getCurrentDate(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Obx(() => Text(
                                          'Good Morning,\n${controller.profileController.userName.value.split(' ').first}',
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )),
                                    const SizedBox(height: 8),
                                    Obx(() {
                                      final level = controller
                                          .profileController.level.value;
                                      final xp = controller
                                          .profileController.currentXp.value;
                                      final canSpin = controller
                                          .profileController.canSpinWheel;

                                      return Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.3)),
                                            ),
                                            child: Text(
                                              'Lvl $level',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$xp XP',
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.9),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (canSpin) ...[
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.casino,
                                                      size: 12,
                                                      color: Colors.black87),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'SPIN',
                                                    style: TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            )
                                                .animate(
                                                    onPlay: (c) =>
                                                        c.repeat(reverse: true))
                                                .scale(
                                                    begin: const Offset(1, 1),
                                                    end:
                                                        const Offset(1.1, 1.1)),
                                          ],
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => Get.toNamed(Routes.PROFILE),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.5),
                                        width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Obx(() {
                                      final avatarUrl = controller
                                          .profileController
                                          .userAvatarUrl
                                          .value;
                                      final name = controller
                                          .profileController.userName.value;

                                      if (avatarUrl.startsWith('seed:')) {
                                        return RandomAvatar(
                                          avatarUrl.substring(5),
                                          height: 60,
                                          width: 60,
                                        );
                                      }

                                      if (avatarUrl.isNotEmpty) {
                                        return Image.network(
                                          avatarUrl,
                                          fit: BoxFit.cover,
                                          width: 60,
                                          height: 60,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                              child: Text(
                                                name.isNotEmpty
                                                    ? name[0].toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }

                                      return Center(
                                        child: Text(
                                          name.isNotEmpty
                                              ? name[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  GestureDetector(
                    onTap: () {
                      Get.dialog(SavedDetailsDialog());
                    },
                    child: Obx(() {
                      final settings = Get.find<SettingsController>();
                      String currency = settings.currency.value;
                      double rate = settings.exchangeRate.value;

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            
                            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                          Icons.account_balance_wallet,
                                          color: AppColors.primary,
                                          size: 24),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: (controller
                                                    .moneySavedTrendPositive
                                                    .value
                                                ? AppColors.success
                                                : AppColors.error)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            controller.moneySavedTrendPositive
                                                    .value
                                                ? Icons.trending_up
                                                : Icons.trending_down,
                                            color: controller
                                                    .moneySavedTrendPositive
                                                    .value
                                                ? AppColors.success
                                                : AppColors.error,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            controller.moneySavedTrend.value,
                                            style: TextStyle(
                                              color: controller
                                                      .moneySavedTrendPositive
                                                      .value
                                                  ? AppColors.success
                                                  : AppColors.error,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Total Saved',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$currency ${(controller.totalMoneySaved.value * rate).toStringAsFixed(2)}',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textPrimaryLight,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap for details',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textTertiaryLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale();
                    }),
                  ),
                  const SizedBox(height: 32),

                  
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAction(
                        'Plan Trip',
                        Icons.map_outlined,
                        AppColors.primary,
                        () {
                          if (Get.isRegistered<MainLayoutController>()) {
                            Get.find<MainLayoutController>().changePage(1);
                          } else {
                            Get.toNamed(Routes.ROUTE_PLANNER);
                          }
                        },
                      ),
                      _buildQuickAction(
                        'Map',
                        Icons.location_on_outlined,
                        Colors.orange,
                        () {
                          if (Get.isRegistered<MainLayoutController>()) {
                            Get.find<MainLayoutController>().changePage(2);
                          } else {
                            Get.toNamed(Routes.MAP_VIEW);
                          }
                        },
                      ),
                      _buildQuickAction(
                        'Calculator',
                        Icons.calculate_outlined,
                        Colors.green,
                        () => Get.toNamed(Routes.COST_CALCULATOR),
                      ),
                      _buildQuickAction(
                        'Garage',
                        Icons.directions_car_outlined,
                        Colors.purple,
                        () => Get.toNamed(Routes.GARAGE),
                      ),
                      _buildQuickAction(
                        'Optimize',
                        Icons.timeline,
                        Colors.teal,
                        () => Get.toNamed(Routes.ROUTE_OPTIMIZER),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  
                  _buildSectionHeader(
                    'Recent Routes',
                    onViewAll: () {
                      Get.toNamed(Routes.RECENT_ROUTES);
                    },
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.recentRoutes.isEmpty) {
                      return _buildEmptyState(
                        'No recent routes',
                        'Your route history will appear here',
                      );
                    }
                    return Column(
                      children: controller.recentRoutes.take(3).map((route) {
                        final settings = Get.find<SettingsController>();
                        return _buildRouteCard(route, settings.currency.value,
                            settings.exchangeRate.value);
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 24),

                  
                  _buildSmartSuggestionsHeader(),
                  const SizedBox(height: 12),
                  Obx(() => Column(
                        children: controller.smartSuggestions
                            .map((suggestion) =>
                                _buildSuggestionCard(suggestion))
                            .toList(),
                      )),
                  const SizedBox(height: 80), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  Widget _buildQuickAction(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        if (onViewAll != null)
          TextButton.icon(
            onPressed: onViewAll,
            icon: const Icon(Icons.history, size: 16),
            label: const Text('View All', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
      ],
    );
  }

  Widget _buildRouteCard(
      Map<String, dynamic> route, String currency, double rate) {
    
    double cost = 0;
    double saved = 0;

    try {
      final costStr =
          route['cost'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
      cost = double.parse(costStr);

      final savedStr =
          route['saved'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
      saved = double.parse(savedStr);
    } catch (e) {
      
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.toNamed(Routes.ROUTE_DETAILS, arguments: route),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.circle,
                            size: 12, color: AppColors.primary),
                        Container(
                          width: 2,
                          height: 24,
                          color: AppColors.border,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                        ),
                        const Icon(Icons.location_on,
                            size: 12, color: AppColors.secondary),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            route['to'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      route['date'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTransportBadge(route['mode']),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Cost',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$currency ${(cost * rate).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Saved',
                                style: TextStyle(
                                  fontSize: 9,
                                  color:
                                      AppColors.success.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$currency ${(saved * rate).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
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
    ).animate().fadeIn().moveY(begin: 10, end: 0);
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
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

  Widget _buildSmartSuggestionsHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.bolt,
            color: AppColors.warning,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Smart tips to save more money',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    Color bgColor = Color(suggestion['color']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: Color(suggestion['textColor']),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              suggestion['title'],
              style: TextStyle(
                color: AppColors.textPrimaryLight.withValues(alpha: 0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildEmptyState(String title, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.route_outlined,
            size: 48,
            color: AppColors.textTertiaryLight,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textTertiaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
