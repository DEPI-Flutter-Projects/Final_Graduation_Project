import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Favorites',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.favoriteRoutes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mark routes as favorite to see them here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.favoriteRoutes.length,
            itemBuilder: (context, index) {
              final route = controller.favoriteRoutes[index];
              return _buildFavoriteCard(route, index, theme);
            },
          );
        }),
      ),
    );
  }

  Widget _buildFavoriteCard(
      Map<String, dynamic> route, int index, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
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
          onTap: () => controller.openRouteDetails(route),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTransportBadge(route['mode'], theme),
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route['from'],
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Icon(Icons.arrow_downward,
                              size: 16, color: theme.disabledColor),
                          const SizedBox(height: 8),
                          Text(
                            route['to'],
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: theme.dividerColor),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      route['date'],
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      'Saved: ${route['saved']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // Keep green for success
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: (index * 50).ms);
  }

  Widget _buildTransportBadge(String mode, ThemeData theme) {
    Color color;
    IconData icon;

    // Use theme colors where appropriate, or stick to semantic colors if needed
    // Assuming AppColors is still useful for specific transport modes if not in theme
    // We can map them to theme extension or keep using AppColors if they are specific.
    // For now, I'll keep using AppColors for specific transport modes but ensure they are imported.
    // Or I can hardcode them if I want to remove dependency on AppColors, but importing is better.

    switch (mode.toLowerCase()) {
      case 'metro':
        color = const Color(0xFFE30613); // Metro Red
        icon = Icons.train;
        break;
      case 'car':
        color =
            const Color(0xFF1A1A1A); // Car Black - maybe issue in dark mode?
        // In dark mode, 'Car' being black is invisible.
        // I should check brightness.
        if (theme.brightness == Brightness.dark) {
          color = Colors.white;
        }
        icon = Icons.directions_car;
        break;
      case 'microbus':
        color = const Color(0xFF2196F3); // Microbus Blue
        icon = Icons.directions_bus;
        break;
      default:
        color = theme.iconTheme.color ?? Colors.grey;
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
}
