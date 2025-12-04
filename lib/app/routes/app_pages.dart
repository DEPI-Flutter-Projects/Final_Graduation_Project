

import 'package:get/get.dart';
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/auth/auth_view.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/main_layout/main_layout_view.dart';
import '../modules/main_layout/main_layout_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/maintenance/maintenance_view.dart';
import '../modules/maintenance/maintenance_controller.dart';
import '../modules/emergency/emergency_view.dart';
import '../modules/emergency/emergency_controller.dart';
import '../modules/gamification/gamification_view.dart';
import '../modules/gamification/gamification_controller.dart';
import '../modules/analytics/analytics_view.dart';
import '../modules/analytics/analytics_controller.dart';
import '../modules/route_planner/route_planner_view.dart';
import '../modules/route_optimizer/route_optimizer_binding.dart';
import '../modules/route_optimizer/route_optimizer_view.dart';
import '../modules/route_planner/route_planner_binding.dart';
import '../modules/cost_calculator/cost_calculator_view.dart';
import '../modules/cost_calculator/cost_calculator_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/map/map_view.dart';
import '../modules/map/map_controller.dart';
import '../modules/map/location_picker_view.dart';
import '../modules/map/location_picker_controller.dart';
import '../modules/profile/profile_view.dart';
import '../modules/profile/profile_controller.dart';
import '../modules/home/views/recent_routes_view.dart';
import '../modules/garage/garage_view.dart';
import '../modules/garage/garage_binding.dart';
import '../modules/garage/add_vehicle_view.dart';
import '../modules/analysis/views/analysis_view.dart';
import '../modules/analysis/controllers/analysis_controller.dart';
import '../modules/route_details/route_details_view.dart';
import '../modules/route_details/route_details_binding.dart';
import '../modules/favorites/favorites_view.dart';
import '../modules/favorites/favorites_binding.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/reset_password_view.dart';
import '../modules/settings/views/change_password_view.dart';
import '../modules/settings/views/privacy_policy_view.dart';
import '../modules/settings/views/terms_of_service_view.dart';
import '../modules/notifications/notifications_view.dart';
import '../modules/notifications/notifications_controller.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const MainLayoutView(),
      binding: MainLayoutBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.MAINTENANCE,
      page: () => const MaintenanceView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MaintenanceController());
      }),
    ),
    GetPage(
      name: Routes.EMERGENCY,
      page: () => const EmergencyView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EmergencyController());
      }),
    ),
    GetPage(
      name: Routes.GAMIFICATION,
      page: () => const GamificationView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => GamificationController());
      }),
    ),
    GetPage(
      name: Routes.ANALYTICS,
      page: () => const AnalyticsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AnalyticsController());
      }),
    ),
    GetPage(
      name: Routes.ROUTE_PLANNER,
      page: () => const RoutePlannerView(),
      binding: RoutePlannerBinding(),
    ),
    GetPage(
      name: Routes.ROUTE_OPTIMIZER,
      page: () => const RouteOptimizerView(),
      binding: RouteOptimizerBinding(),
    ),
    GetPage(
      name: Routes.COST_CALCULATOR,
      page: () => const CostCalculatorView(),
      binding: CostCalculatorBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.GARAGE,
      page: () => const GarageView(),
      binding: GarageBinding(),
    ),
    GetPage(
      name: Routes.MAP_VIEW,
      page: () => const MapView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MapController());
      }),
    ),
    GetPage(
      name: Routes.LOCATION_PICKER,
      page: () => const LocationPickerView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LocationPickerController());
      }),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileController());
      }),
    ),
    GetPage(
      name: Routes.RECENT_ROUTES,
      page: () => const RecentRoutesView(),
    ),
    GetPage(
      name: Routes.ANALYSIS,
      page: () => const AnalysisView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AnalysisController>(() => AnalysisController());
      }),
    ),
    GetPage(
      name: Routes.ROUTE_DETAILS,
      page: () => const RouteDetailsView(),
      binding: RouteDetailsBinding(),
    ),
    GetPage(
      name: Routes.FAVORITES,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
    ),
    GetPage(
      name: Routes.ADD_VEHICLE,
      page: () => const AddVehicleView(),
      binding: GarageBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
    ),
    GetPage(
      name: Routes.TERMS_OF_SERVICE,
      page: () => const TermsOfServiceView(),
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: BindingsBuilder(() {
        Get.put(NotificationsController());
      }),
    ),
  ];
}
