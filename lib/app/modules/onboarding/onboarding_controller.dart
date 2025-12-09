import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Plan Your Journey',
      description:
          'Estimate fuel costs and plan your trips efficiently with our smart calculator.',
      icon: Icons.map_outlined,
    ),
    OnboardingPage(
      title: 'Fuel Cost Calculator',
      description:
          'Calculate the exact fuel cost for your trip based on your car model and current fuel prices.',
      icon: Icons.local_gas_station_outlined,
    ),
    OnboardingPage(
      title: 'Car Maintenance (Coming Soon)',
      description:
          'Track your vehicle\'s health, schedule maintenance, and keep your car running smoothly.',
      icon: Icons.car_repair_outlined,
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAllNamed(Routes.auth);
    }
  }
}
