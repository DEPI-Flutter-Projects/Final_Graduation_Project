import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Get.offAllNamed(Routes.main);
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }
}
