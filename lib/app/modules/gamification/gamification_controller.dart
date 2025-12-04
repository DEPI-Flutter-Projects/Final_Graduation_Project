import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GamificationController extends GetxController {
  final achievements = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAchievements();
  }

  void _loadAchievements() {
    achievements.assignAll([
      {
        'title': 'First Journey',
        'description': 'Completed your first calculated route',
        'date': 'Unlocked on January 1, 2024',
        'icon': Icons.map,
        'color': Colors.blue,
        'unlocked': true,
        'progress': 1.0,
      },
      {
        'title': 'Money Saver',
        'description': 'Saved over ₪100 in transportation costs',
        'date': 'Unlocked on January 15, 2024',
        'icon': Icons.savings,
        'color': Colors.orange,
        'unlocked': true,
        'progress': 1.0,
      },
      {
        'title': 'Eco Warrior',
        'description': 'Chose public transport 10 times',
        'date': 'Unlocked on January 20, 2024',
        'icon': Icons.eco,
        'color': Colors.green,
        'unlocked': true,
        'progress': 1.0,
      },
      {
        'title': 'Route Master',
        'description': 'Optimized 5 multi-stop routes',
        'date': null,
        'icon': Icons.alt_route,
        'color': Colors.grey,
        'unlocked': false,
        'progress': 0.6, 
        'progressText': '3/5',
      },
      {
        'title': 'Social Traveler',
        'description': 'Share 10 routes with friends',
        'date': null,
        'icon': Icons.people,
        'color': Colors.grey,
        'unlocked': false,
        'progress': 0.0, 
        'progressText': '0/10',
      },
      {
        'title': 'Weekly Planner',
        'description': 'Plan routes for 7 consecutive days',
        'date': null,
        'icon': Icons.calendar_today,
        'color': Colors.grey,
        'unlocked': false,
        'progress': 0.57, 
        'progressText': '4/7',
      },
    ]);
  }
}
