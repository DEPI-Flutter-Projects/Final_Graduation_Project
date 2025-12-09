import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../routes/app_routes.dart';
import '../../core/utils/app_snackbars.dart';
import '../../data/services/notification_service.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  final userName = 'User'.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final userLocation = ''.obs;
  final userAvatarUrl = ''.obs;

  final totalTrips = 0.obs;
  final totalSavings = 0.0.obs;
  final kmTraveled = 0.obs;
  final avgRating = 5.0.obs;
  final co2Saved = 0.0.obs;
  final timeSaved = 0.0.obs;

  final level = 1.obs;
  final levelName = 'Beginner'.obs;
  final currentXp = 0.obs;
  final nextLevelXp = 500.obs;
  final lastSpinDate = Rxn<DateTime>();
  final currentStreak = 0.obs;

  final badges = <Map<String, dynamic>>[].obs;
  final activeChallenges = <Map<String, dynamic>>[].obs;

  final ImagePicker _picker = ImagePicker();
  late Box _profileBox;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final tempAvatarUrl = ''.obs;

  void initEditProfile() {
    nameController.text = userName.value;
    phoneController.text = userPhone.value;
    locationController.text = userLocation.value;
    tempAvatarUrl.value = userAvatarUrl.value;
  }

  @override
  void onInit() {
    super.onInit();
    _initHiveAndLoadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.onClose();
  }

  Future<void> _initHiveAndLoadProfile() async {
    _profileBox = await Hive.openBox('profile');
    _loadFromCache();
    await loadUserProfile();
  }

  void _loadFromCache() {
    if (_profileBox.isEmpty) return;

    userName.value = _profileBox.get('userName', defaultValue: 'User');
    userEmail.value = _profileBox.get('userEmail', defaultValue: '');
    userPhone.value = _profileBox.get('userPhone', defaultValue: '');
    userLocation.value = _profileBox.get('userLocation', defaultValue: '');
    userAvatarUrl.value = _profileBox.get('userAvatarUrl', defaultValue: '');

    totalTrips.value = _profileBox.get('totalTrips', defaultValue: 0);
    totalSavings.value = _profileBox.get('totalSavings', defaultValue: 0.0);
    kmTraveled.value = _profileBox.get('kmTraveled', defaultValue: 0);
    avgRating.value = _profileBox.get('avgRating', defaultValue: 5.0);
    co2Saved.value = _profileBox.get('co2Saved', defaultValue: 0.0);
    timeSaved.value = _profileBox.get('timeSaved', defaultValue: 0.0);

    level.value = _profileBox.get('level', defaultValue: 1);
    currentXp.value = _profileBox.get('currentXp', defaultValue: 0);
    currentStreak.value = _profileBox.get('currentStreak', defaultValue: 0);

    final lastSpin = _profileBox.get('lastSpinDate');
    if (lastSpin != null) {
      lastSpinDate.value = DateTime.parse(lastSpin);
    }

    _calculateLevelProgress();
    _updateTextControllers();
  }

  void _updateTextControllers() {
    nameController.text = userName.value;
    phoneController.text = userPhone.value;
    locationController.text = userLocation.value;
  }

  Future<void> _cacheProfileData() async {
    await _profileBox.putAll({
      'userName': userName.value,
      'userEmail': userEmail.value,
      'userPhone': userPhone.value,
      'userLocation': userLocation.value,
      'userAvatarUrl': userAvatarUrl.value,
      'totalTrips': totalTrips.value,
      'totalSavings': totalSavings.value,
      'kmTraveled': kmTraveled.value,
      'avgRating': avgRating.value,
      'co2Saved': co2Saved.value,
      'timeSaved': timeSaved.value,
      'level': level.value,
      'currentXp': currentXp.value,
      'currentStreak': currentStreak.value,
      'lastSpinDate': lastSpinDate.value?.toIso8601String(),
    });
  }

  Future<void> loadUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      userEmail.value = user.email ?? '';

      Map<String, dynamic>? data;
      try {
        data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
      } catch (e) {
        debugPrint('Profile not found in DB');
      }

      final meta = user.userMetadata;
      final metaName = meta?['full_name'] ?? meta?['name'] ?? 'User';
      final metaAvatar = meta?['avatar_url'] ?? meta?['picture'] ?? '';

      if (data == null) {
        userName.value = metaName;
        userAvatarUrl.value = metaAvatar;
        await _upsertProfile(user.id, metaName, metaAvatar);
      } else {
        userName.value = data['full_name'] ?? data['username'] ?? metaName;
        userPhone.value = data['phone_number'] ?? '';
        userLocation.value = data['location'] ?? '';
        userAvatarUrl.value = data['avatar_url'] ?? metaAvatar;

        if ((data['avatar_url'] == null ||
                data['avatar_url'].toString().isEmpty) &&
            metaAvatar.isNotEmpty) {
          userAvatarUrl.value = metaAvatar;
          await _upsertProfile(user.id, userName.value, metaAvatar);
        }

        totalTrips.value = data['total_trips'] ?? 0;
        totalSavings.value = (data['total_savings'] ?? 0.0).toDouble();
        kmTraveled.value = (data['km_traveled'] ?? 0).toInt();
        avgRating.value = (data['avg_rating'] ?? 5.0).toDouble();

        currentXp.value = data['xp'] ?? 0;
        currentStreak.value = data['current_streak'] ?? 0;
        if (data['last_spin_date'] != null) {
          lastSpinDate.value = DateTime.parse(data['last_spin_date']);
        }
      }

      _updateTextControllers();
      _calculateLevelProgress();
      await _loadBadges();
      await _checkAndUnlockBadges();
      await _loadDailyChallenges();
      await _calculateEnvironmentalImpact(user.id);
      await _cacheProfileData();

      _checkDailySpinNotification();
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _calculateEnvironmentalImpact(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('user_routes')
          .select('transport_mode, distance_km')
          .eq('user_id', userId);

      double totalCo2Saved = 0;

      for (var route in response) {
        final mode = route['transport_mode']?.toString().toLowerCase() ?? '';
        final distance = (route['distance_km'] ?? 0) as num;

        if (mode.contains('metro') || mode.contains('train')) {
          totalCo2Saved += distance * 0.09;
        } else if (mode.contains('bus') || mode.contains('microbus')) {
          totalCo2Saved += distance * 0.06;
        } else if (mode.contains('walk') || mode.contains('cycl')) {
          totalCo2Saved += distance * 0.12;
        }
      }

      co2Saved.value = totalCo2Saved;

      timeSaved.value = response
              .where(
                  (r) => r['transport_mode'].toString().toLowerCase() != 'car')
              .length *
          0.25;
    } catch (e) {
      debugPrint('Error calculating impact: $e');
    }
  }

  Future<void> _upsertProfile(String userId, String name, String avatar) async {
    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'full_name': name,
        'avatar_url': avatar,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Failed to upsert profile: $e');
    }
  }

  void _calculateLevelProgress() {
    int xp = currentXp.value;
    int lvl = 1;

    lvl = (xp ~/ 500) + 1;
    if (lvl > 50) lvl = 50;

    level.value = lvl;
    nextLevelXp.value = lvl * 500;
    levelName.value = _getLevelName(lvl);
  }

  String _getLevelName(int lvl) {
    if (lvl >= 50) return 'Legend';
    if (lvl >= 40) return 'Grandmaster';
    if (lvl >= 30) return 'Master';
    if (lvl >= 20) return 'Expert';
    if (lvl >= 15) return 'Pro';
    if (lvl >= 10) return 'Navigator';
    if (lvl >= 5) return 'Explorer';
    if (lvl >= 2) return 'Rookie';
    return 'Beginner';
  }

  Future<void> _loadBadges() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final allBadgesResponse = await Supabase.instance.client
          .from('badges')
          .select()
          .order('xp_reward');

      final userBadgesResponse = await Supabase.instance.client
          .from('user_badges')
          .select('badge_id')
          .eq('user_id', user.id);

      final earnedBadgeIds = (userBadgesResponse as List)
          .map((e) => e['badge_id'] as String)
          .toSet();

      final List<Map<String, dynamic>> processedBadges = [];

      for (var badge in allBadgesResponse) {
        processedBadges.add({
          ...badge,
          'isEarned': earnedBadgeIds.contains(badge['id']),
        });
      }

      badges.assignAll(processedBadges);
    } catch (e) {
      debugPrint('Error loading badges: $e');
    }
  }

  Future<void> _checkAndUnlockBadges() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final unearnedBadges = badges.where((b) => b['isEarned'] == false).toList();
    bool newBadgeUnlocked = false;

    for (var badge in unearnedBadges) {
      bool unlocked = false;
      int req = badge['requirement_value'];
      String category = badge['category'];

      switch (category) {
        case 'trips':
          if (totalTrips.value >= req) unlocked = true;
          break;
        case 'distance':
          if (kmTraveled.value >= req) unlocked = true;
          break;
        case 'savings':
          if (totalSavings.value >= req) unlocked = true;
          break;
        case 'eco':
          if (co2Saved.value >= req) unlocked = true;
          break;
      }

      if (unlocked) {
        try {
          await Supabase.instance.client.from('user_badges').insert({
            'user_id': user.id,
            'badge_id': badge['id'],
          });

          await addXp(badge['xp_reward'],
              reason: 'Badge Unlocked: ${badge['name']}');

          Get.find<NotificationService>().showNotification(
            title: 'New Badge Unlocked! 🏆',
            body: 'You earned the ${badge['name']} badge!',
            type: 'badge',
          );

          newBadgeUnlocked = true;
        } catch (e) {
          // Ignored
        }
      }
    }

    if (newBadgeUnlocked) {
      await _loadBadges();
    }
  }

  Future<void> _loadDailyChallenges() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final existingChallenges = await Supabase.instance.client
          .from('user_challenges')
          .select('*, challenge:challenges(*)')
          .eq('user_id', user.id)
          .eq('assigned_date', today);

      if (existingChallenges.isNotEmpty) {
        activeChallenges
            .assignAll(List<Map<String, dynamic>>.from(existingChallenges));
        return;
      }

      final allDailyChallenges = await Supabase.instance.client
          .from('challenges')
          .select()
          .eq('type', 'daily');

      if (allDailyChallenges.isEmpty) return;

      final random = Random();
      final selectedChallenges = <Map<String, dynamic>>[];
      final available = List<Map<String, dynamic>>.from(allDailyChallenges);

      for (int i = 0; i < 3 && available.isNotEmpty; i++) {
        final index = random.nextInt(available.length);
        selectedChallenges.add(available[index]);
        available.removeAt(index);
      }

      for (var challenge in selectedChallenges) {
        final res = await Supabase.instance.client
            .from('user_challenges')
            .insert({
              'user_id': user.id,
              'challenge_id': challenge['id'],
              'assigned_date': today,
              'progress': 0,
              'is_completed': false,
            })
            .select('*, challenge:challenges(*)')
            .single();

        activeChallenges.add(res);
      }
    } catch (e) {
      debugPrint('Error loading daily challenges: $e');
    }
  }

  Future<void> updateChallengeProgress(String metric, int amount) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    for (var userChallenge in activeChallenges) {
      if (userChallenge['is_completed'] == true) continue;

      final challenge = userChallenge['challenge'];
      if (challenge['metric'] == metric) {
        int currentProgress = userChallenge['progress'];
        int target = challenge['target_value'];
        int newProgress = currentProgress + amount;

        if (newProgress >= target) {
          newProgress = target;

          await Supabase.instance.client.from('user_challenges').update({
            'progress': newProgress,
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          }).eq('id', userChallenge['id']);

          await addXp(challenge['xp_reward'],
              reason: 'Challenge Completed: ${challenge['description']}');

          Get.find<NotificationService>().showNotification(
            title: 'Challenge Completed! 🎯',
            body: 'You completed: ${challenge['description']}',
            type: 'challenge',
          );
        } else {
          await Supabase.instance.client.from('user_challenges').update({
            'progress': newProgress,
          }).eq('id', userChallenge['id']);
        }
      }
    }

    await _loadDailyChallenges();
  }

  Future<void> addXp(int amount, {String? reason}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final oldLevel = level.value;
    currentXp.value += amount;

    await Supabase.instance.client.from('profiles').update({
      'xp': currentXp.value,
    }).eq('id', user.id);

    _calculateLevelProgress();

    if (level.value > oldLevel) {
      Get.dialog(Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              const Text('LEVEL UP!',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple)),
              const SizedBox(height: 8),
              Text('You are now Level ${level.value}',
                  style: const TextStyle(fontSize: 18)),
              Text(levelName.value,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber)),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () => Get.back(), child: const Text('Awesome!'))
            ],
          ),
        ),
      ));
    }
  }

  bool get canSpinWheel {
    if (lastSpinDate.value == null) return true;
    final now = DateTime.now();
    final last = lastSpinDate.value!;
    return now.day != last.day ||
        now.month != last.month ||
        now.year != last.year;
  }

  Future<int> spinWheel() async {
    if (!canSpinWheel) return 0;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return 0;

    final rand = Random();
    int reward = 0;
    int roll = rand.nextInt(100);

    if (roll < 50) {
      reward = 50;
    } else if (roll < 80) {
      reward = 100;
    } else if (roll < 95) {
      reward = 200;
    } else {
      reward = 500;
    }

    lastSpinDate.value = DateTime.now();

    await Supabase.instance.client.from('profiles').update({
      'last_spin_date': DateTime.now().toIso8601String(),
    }).eq('id', user.id);

    await addXp(reward, reason: 'Daily Spin');

    return reward;
  }

  void _checkDailySpinNotification() {
    if (canSpinWheel) {
      Get.find<NotificationService>().showNotification(
        title: 'Daily Spin Available! 🎰',
        body: 'Don\'t forget to spin the wheel for free XP!',
        type: 'spin',
      );
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    Get.offAllNamed(Routes.onboarding);
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        await _uploadAvatar(File(image.path));
      }
    } catch (e) {
      AppSnackbars.showError('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> _uploadAvatar(File imageFile) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await Supabase.instance.client.storage.from('avatars').upload(
          fileName, imageFile,
          fileOptions: const FileOptions(upsert: true));

      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      tempAvatarUrl.value = imageUrl;
      AppSnackbars.showSuccess(
          'Image Uploaded', 'Don\'t forget to save changes!');
    } catch (e) {
      AppSnackbars.showError('Upload Failed', 'Could not upload image: $e');
    }
  }

  void setRandomAvatar() {
    final random = Random();
    final seed = DateTime.now().millisecondsSinceEpoch.toString() +
        random.nextInt(1000).toString();
    tempAvatarUrl.value = 'seed:$seed';
  }

  void setAvatarSeed(String seed) {
    tempAvatarUrl.value = 'seed:$seed';
  }

  Future<void> saveProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      userName.value = nameController.text;
      userPhone.value = phoneController.text;
      userLocation.value = locationController.text;
      userAvatarUrl.value = tempAvatarUrl.value;

      await Supabase.instance.client.from('profiles').update({
        'full_name': nameController.text,
        'phone_number': phoneController.text,
        'location': locationController.text,
        'avatar_url': tempAvatarUrl.value,
      }).eq('id', user.id);

      await _cacheProfileData();
      Get.back();
      AppSnackbars.showSuccess('Success', 'Profile updated successfully');
    } catch (e) {
      AppSnackbars.showError('Error', 'Failed to update profile: $e');
    }
  }

  Future<void> updateStats({
    required double distanceKm,
    required double savings,
    required String transportMode,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    totalTrips.value++;
    kmTraveled.value += distanceKm.toInt();
    totalSavings.value += savings;

    await Supabase.instance.client.from('profiles').update({
      'total_trips': totalTrips.value,
      'km_traveled': kmTraveled.value,
      'total_savings': totalSavings.value,
    }).eq('id', user.id);

    if (savings > 0) {
      await addXp(savings.toInt(), reason: 'Savings: ${savings.toInt()} EGP');
    }

    await updateChallengeProgress('trips', 1);
    await updateChallengeProgress('distance', distanceKm.toInt());
    if (savings > 0) {
      await updateChallengeProgress('savings', savings.toInt());
    }

    await _checkAndUnlockBadges();

    await _calculateEnvironmentalImpact(user.id);
  }

  void clearProfile() {
    userName.value = 'User';
    userEmail.value = '';
    userPhone.value = '';
    userLocation.value = '';
    userAvatarUrl.value = '';
    totalTrips.value = 0;
    totalSavings.value = 0.0;
    kmTraveled.value = 0;
    avgRating.value = 5.0;
    co2Saved.value = 0.0;
    timeSaved.value = 0.0;
    level.value = 1;
    currentXp.value = 0;
    currentStreak.value = 0;
    lastSpinDate.value = null;
    badges.clear();
    activeChallenges.clear();
    _profileBox.clear();
  }
}
