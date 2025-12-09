import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../data/services/car_data_service.dart';
import '../data/services/vehicle_service.dart';
import '../data/services/deep_link_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/theme_service.dart';
import '../data/services/pricing_service.dart';

import '../modules/settings/settings_controller.dart';
import '../modules/profile/profile_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LocationController>(LocationController(), permanent: true);
    Get.putAsync(() => CarDataService().init());
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);
    Get.put<VehicleService>(VehicleService(), permanent: true);
    Get.put(ThemeService());
    Get.putAsync(() => NotificationService().init());
    Get.putAsync(() => PricingService().init());
    Get.putAsync(() => DeepLinkService().init());
  }
}
