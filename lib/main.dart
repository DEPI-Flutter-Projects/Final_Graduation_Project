import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/utils/constants.dart';
import 'app/bindings/initial_binding.dart';
import 'app/data/services/background_service.dart';
import 'app/data/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  await Hive.initFlutter();
  await Hive.openBox('profile');
  await Hive.openBox('settings');
  await Hive.openBox('route_optimizer');

  await BackgroundService.init();

  runApp(const ElMoshwarApp());
}

class ElMoshwarApp extends StatelessWidget {
  const ElMoshwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.put(ThemeService());

    return GetMaterialApp(
      title: 'El-Moshwar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
