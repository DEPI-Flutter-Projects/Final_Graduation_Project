import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'route_optimizer_controller.dart';
import 'route_analysis_view.dart';

class RouteOptimizerView extends GetView<RouteOptimizerController> {
  const RouteOptimizerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Route Optimizer',
          style: GoogleFonts.outfit(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline,
                color: Theme.of(context).iconTheme.color),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Help',
          ),
          IconButton(
            icon: Icon(Icons.history, color: Theme.of(context).iconTheme.color),
            onPressed: () => _showHistoryDialog(context),
            tooltip: 'History',
          ),
          IconButton(
            icon: Icon(Icons.map_outlined,
                color: Theme.of(context).iconTheme.color),
            onPressed: controller.viewRouteOnMap,
            tooltip: 'View Route on Map',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Obx(() => Row(
                      children: controller.shortcuts
                          .map((s) => _buildShortcutChip(
                                icon: s['icon'],
                                label: s['name'],
                                color: s['color'],
                                onTap: () => controller.addShortcut(s),
                                onLongPress: () => _showEditShortcutDialog(s),
                              ))
                          .toList(),
                    )),
                _buildShortcutChip(
                  icon: Icons.add,
                  label: 'Add Shortcut',
                  color: Theme.of(context).disabledColor,
                  onTap: () => _showEditShortcutDialog(null),
                  isOutlined: true,
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.stops.isEmpty) {
                return GestureDetector(
                  onTap: controller.addStop,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_location_alt_outlined,
                              size: 48,
                              color: AppColors.primary.withValues(alpha: 0.5)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to add your first stop',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Or select a shortcut above',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ).animate().fadeIn().scale(),
                  ),
                );
              }
              return ReorderableListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: controller.stops.length,
                onReorder: controller.reorderStops,
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      return Material(
                        elevation: 12,
                        color: Colors.transparent,
                        shadowColor: Theme.of(context)
                            .shadowColor
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        child: child,
                      );
                    },
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final stop = controller.stops[index];
                  return _buildStopCard(context, stop, index);
                },
              );
            }),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).shadowColor.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCriteriaOption('Distance'),
                      const SizedBox(width: 16),
                      _buildCriteriaOption('Time'),
                      const SizedBox(width: 16),
                      _buildCriteriaOption('Fuel'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      final optimizeButton = ElevatedButton.icon(
                        onPressed: controller.isOptimizing.value
                            ? null
                            : controller.optimizeRoute,
                        icon: controller.isOptimizing.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.auto_awesome),
                        label: Text(controller.isOptimizing.value
                            ? 'Optimizing...'
                            : 'Optimize Route'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );

                      if (controller.stops.isNotEmpty) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: controller.addStop,
                                    icon: const Icon(Icons.add_location_alt),
                                    label: const Text('Add Stop'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: optimizeButton),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (controller.stops.length >= 3) ...[
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => Get.to(
                                          () => const RouteAnalysisView()),
                                      icon:
                                          const Icon(Icons.analytics_outlined),
                                      label: const Text('Analyze'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  flex: controller.stops.length >= 3 ? 1 : 2,
                                  child: ElevatedButton.icon(
                                    onPressed: controller.viewRouteOnMap,
                                    icon: const Icon(Icons.navigation),
                                    label: const Text('Preview'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (controller.isOptimized.value) ...[
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: controller.resetToOriginal,
                                icon: const Icon(Icons.restore,
                                    color: Colors.red),
                                label: const Text('Reset to Original',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ]
                          ],
                        );
                      }

                      return optimizeButton;
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutChip(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap,
      VoidCallback? onLongPress,
      bool isOutlined = false}) {
    final theme = Theme.of(Get.context!);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isOutlined ? theme.dividerColor : color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isOutlined
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                    : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isOutlined
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                    : color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 200.ms);
  }

  Widget _buildCriteriaOption(String label) {
    return Obx(() {
      final isSelected = controller.optimizationCriteria.value == label;
      final theme = Theme.of(Get.context!);
      const selectedColor = AppColors.accent;

      return GestureDetector(
        onTap: () => controller.optimizationCriteria.value = label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? selectedColor
                  : theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? selectedColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.9),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStopCard(BuildContext context, RouteStop stop, int index) {
    return Container(
      key: ValueKey(stop.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: stop.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: stop.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: GestureDetector(
              onTap: () => _showRenameDialog(context, stop),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      stop.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit,
                      size: 14,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withValues(alpha: 0.5)),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (stop.address != null && stop.address!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: InkWell(
                      onTap: () => controller.pickLocationForStop(stop.id),
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 12, color: Theme.of(context).disabledColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              stop.address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withValues(alpha: 0.7)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: InkWell(
                      onTap: () => controller.pickLocationForStop(stop.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_location_alt,
                                size: 16, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Text(
                              'Set Location',
                              style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      // Priority Button
                      InkWell(
                        onTap: () {
                          final currentIndex = stop.priority.index;
                          final nextIndex =
                              (currentIndex + 1) % StopPriority.values.length;
                          final nextPriority = StopPriority.values[nextIndex];
                          controller.updateStopDetails(stop.id,
                              priority: nextPriority);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(stop.priority)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _getPriorityColor(stop.priority),
                                width: 1),
                          ),
                          child: Text(
                            stop.priority.name.toUpperCase(),
                            style: TextStyle(
                              color: _getPriorityColor(stop.priority),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Time Button
                      InkWell(
                        onTap: () => _showTimePicker(context, stop),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .cardColor
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color),
                              const SizedBox(width: 4),
                              Text(
                                stop.timeConstraint?.format(context) ??
                                    'Set Time',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon:
                      Icon(Icons.close, color: Theme.of(context).disabledColor),
                  onPressed: () => controller.removeStop(stop.id),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(Icons.drag_indicator,
                      color: Theme.of(context).disabledColor),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(key: ValueKey(stop.id)).fadeIn(delay: (index * 50).ms).slideX();
  }

  Color _getPriorityColor(StopPriority priority) {
    switch (priority) {
      case StopPriority.high:
        return Colors.red;
      case StopPriority.medium:
        return Colors.orange;
      case StopPriority.low:
        return Colors.green;
    }
  }

  void _showHelpDialog(BuildContext context) {
    final pages = [
      {
        'title': 'Add Stops',
        'icon': Icons.add_location_alt,
        'color': Colors.blue,
        'desc':
            'Tap the "Add Stop" button or select a shortcut to add locations to your route.',
      },
      {
        'title': 'Set Priority',
        'icon': Icons.flag,
        'color': Colors.red,
        'desc':
            'Tap the "Priority" button on a stop to toggle between Low, Medium, and High priority. High priority stops are visited earlier.',
      },
      {
        'title': 'Optimize',
        'icon': Icons.auto_awesome,
        'color': Colors.purple,
        'desc':
            'Choose your criteria (Distance, Time, Fuel) and tap "Optimize Route" to find the best path.',
      },
      {
        'title': 'Shortcuts',
        'icon': Icons.bookmark,
        'color': Colors.orange,
        'desc':
            'Long press any shortcut to edit it. You can set a default location for quick access.',
      },
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: 450,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.help_outline,
                        color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'How to use',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: Theme.of(context).iconTheme.color),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: (page['color'] as Color)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              page['icon'] as IconData,
                              size: 48,
                              color: page['color'] as Color,
                            ).animate().scale(
                                duration: 600.ms, curve: Curves.elasticOut),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            page['title'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 16),
                          Text(
                            page['desc'] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              height: 1.5,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Future<void> _showTimePicker(BuildContext context, RouteStop stop) async {
    final time = await showTimePicker(
      context: context,
      initialTime: stop.timeConstraint ?? TimeOfDay.now(),
    );
    if (time != null) {
      controller.updateStopDetails(stop.id, time: time);
    }
  }

  void _showEditShortcutDialog(Map<String, dynamic>? shortcut) {
    final isEditing = shortcut != null;
    final nameController =
        TextEditingController(text: isEditing ? shortcut['name'] : '');
    final Rx<Color> selectedColor =
        (isEditing ? shortcut['color'] as Color : Colors.blue).obs;
    final Rx<IconData> selectedIcon =
        (isEditing ? shortcut['icon'] as IconData : Icons.star).obs;
    final RxString savedAddress =
        (isEditing ? (shortcut['address'] as String? ?? '') : '').obs;
    final Rx<double?> savedLat =
        (isEditing ? shortcut['lat'] as double? : null).obs;
    final Rx<double?> savedLng =
        (isEditing ? shortcut['lng'] as double? : null).obs;

    final List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo
    ];
    final List<IconData> icons = [
      Icons.home,
      Icons.work,
      Icons.fitness_center,
      Icons.shopping_cart,
      Icons.local_cafe,
      Icons.restaurant,
      Icons.school,
      Icons.local_hospital,
      Icons.park,
      Icons.store,
      Icons.star,
      Icons.favorite,
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEditing ? 'Edit Shortcut' : 'New Shortcut',
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Shortcut Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Icon',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: icons
                      .map((icon) => Obx(() => GestureDetector(
                            onTap: () => selectedIcon.value = icon,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: selectedIcon.value == icon
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.grey.shade100,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedIcon.value == icon
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Icon(icon,
                                  size: 20,
                                  color: selectedIcon.value == icon
                                      ? AppColors.primary
                                      : Colors.grey),
                            ),
                          )))
                      .toList(),
                ),
                const SizedBox(height: 24),
                Text('Color',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: colors
                      .map((color) => Obx(() => GestureDetector(
                            onTap: () => selectedColor.value = color,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor.value == color
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  if (selectedColor.value == color)
                                    BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4))
                                ],
                              ),
                              child: selectedColor.value == color
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 18)
                                  : null,
                            ),
                          )))
                      .toList(),
                ),
                const SizedBox(height: 24),
                Text('Default Location',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
                const SizedBox(height: 12),
                Obx(() => Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (savedAddress.value.isNotEmpty)
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: selectedColor.value
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.location_on,
                                    color: selectedColor.value),
                              ),
                              title: Text(savedAddress.value,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13)),
                              subtitle: Text(
                                  '${savedLat.value?.toStringAsFixed(4)}, ${savedLng.value?.toStringAsFixed(4)}',
                                  style: const TextStyle(fontSize: 11)),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  savedAddress.value = '';
                                  savedLat.value = null;
                                  savedLng.value = null;
                                },
                              ),
                            ),
                          ListTile(
                            onTap: () async {
                              final result =
                                  await controller.pickLocationForShortcut();
                              if (result != null) {
                                savedLat.value = result['coordinates'].latitude;
                                savedLng.value =
                                    result['coordinates'].longitude;
                                savedAddress.value = result['address'];
                              }
                            },
                            leading: Icon(
                                savedAddress.value.isEmpty
                                    ? Icons.add_location_alt
                                    : Icons.edit_location_alt,
                                color: AppColors.primary),
                            title: Text(
                                savedAddress.value.isEmpty
                                    ? 'Set Location'
                                    : 'Change Location',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isEmpty) {
                            Get.snackbar('Error', 'Please enter a name');
                            return;
                          }

                          final newData = {
                            'name': nameController.text,
                            'icon': selectedIcon.value,
                            'color': selectedColor.value,
                            'address': savedAddress.value,
                            'lat': savedLat.value,
                            'lng': savedLng.value,
                          };

                          if (isEditing) {
                            controller.updateShortcut(shortcut, newData);
                          } else {
                            controller.createShortcut(newData);
                          }
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                            isEditing ? 'Save Changes' : 'Create Shortcut'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, RouteStop stop) {
    final controllerText = TextEditingController(text: stop.name);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rename Stop',
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: controllerText,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Stop Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (controllerText.text.isNotEmpty) {
                        controller.updateStopDetails(stop.id,
                            name: controllerText.text);
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    final history = controller.getHistory();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: 500,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history,
                        color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Optimization History',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: Theme.of(context).disabledColor),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off,
                                size: 64,
                                color: Theme.of(context).disabledColor),
                            const SizedBox(height: 16),
                            Text(
                              'No history yet',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          final date = DateTime.parse(item['date']);
                          final stops = item['stops'] as List;
                          final criteria = item['criteria'];
                          final message = item['message'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Theme.of(context).dividerColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor
                                      .withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Row(
                                children: [
                                  Text(
                                    '${stops.length} Stops',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      criteria,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    message,
                                    style: const TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () =>
                                    controller.restoreFromHistory(item),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Restore'),
                              ),
                            ),
                          ).animate().fadeIn(delay: (index * 50).ms).slideX();
                        },
                      ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }
}
