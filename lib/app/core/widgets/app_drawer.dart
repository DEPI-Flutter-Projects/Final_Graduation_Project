import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:random_avatar/random_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/navigation_items.dart';
import '../../modules/profile/profile_controller.dart';
import '../../routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    
    
    final profileController = Get.find<ProfileController>();

    return Drawer(
      child: Column(
        children: [
          
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Obx(() => Text(
                  profileController.userName.value,
                  style: const TextStyle(color: Colors.white),
                )),
            accountEmail: Obx(() => Text(
                  profileController.userEmail.value,
                  style: const TextStyle(color: Colors.white70),
                )),
            currentAccountPicture: Obx(() {
              final avatarUrl = profileController.userAvatarUrl.value;
              if (avatarUrl.startsWith('seed:')) {
                return RandomAvatar(
                  avatarUrl.substring(5),
                  height: 72,
                  width: 72,
                );
              }
              return CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                    avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? Text(
                        profileController.userName.value.isNotEmpty
                            ? profileController.userName.value[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 24, color: AppColors.primary),
                      )
                    : null,
              );
            }),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...navigationItems.map((item) {
                  return ListTile(
                    leading: Icon(item.icon, color: AppColors.textPrimaryLight),
                    title: Text(item.title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Get.back(); 
                      Get.toNamed(item.route);
                    },
                  );
                }),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.favorite,
                  title: 'Favorites',
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.FAVORITES);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'Recent Routes',
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.RECENT_ROUTES);
                  },
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Sign Out',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              Get.offAllNamed(Routes.AUTH);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimaryLight),
      title: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
