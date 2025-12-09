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
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainLayoutView(),
      binding: MainLayoutBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.maintenance,
      page: () => const MaintenanceView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MaintenanceController());
      }),
    ),
    GetPage(
      name: Routes.emergency,
      page: () => const EmergencyView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EmergencyController());
      }),
    ),
    GetPage(
      name: Routes.gamification,
      page: () => const GamificationView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => GamificationController());
      }),
    ),
    GetPage(
      name: Routes.analytics,
      page: () => const AnalyticsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AnalyticsController());
      }),
    ),
    GetPage(
      name: Routes.routePlanner,
      page: () => const RoutePlannerView(),
      binding: RoutePlannerBinding(),
    ),
    GetPage(
      name: Routes.routeOptimizer,
      page: () => const RouteOptimizerView(),
      binding: RouteOptimizerBinding(),
    ),
    GetPage(
      name: Routes.costCalculator,
      page: () => const CostCalculatorView(),
      binding: CostCalculatorBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.garage,
      page: () => const GarageView(),
      binding: GarageBinding(),
    ),
    GetPage(
      name: Routes.mapView,
      page: () => const MapView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MapController());
      }),
    ),
    GetPage(
      name: Routes.locationPicker,
      page: () => const LocationPickerView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LocationPickerController());
      }),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileController());
      }),
    ),
    GetPage(
      name: Routes.recentRoutes,
      page: () => const RecentRoutesView(),
    ),
    GetPage(
      name: Routes.analysis,
      page: () => const AnalysisView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AnalysisController>(() => AnalysisController());
      }),
    ),
    GetPage(
      name: Routes.routeDetails,
      page: () => const RouteDetailsView(),
      binding: RouteDetailsBinding(),
    ),
    GetPage(
      name: Routes.favorites,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
    ),
    GetPage(
      name: Routes.addVehicle,
      page: () => const AddVehicleView(),
      binding: GarageBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordView(),
    ),
    GetPage(
      name: Routes.changePassword,
      page: () => const ChangePasswordView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
    ),
    GetPage(
      name: Routes.termsOfService,
      page: () => const TermsOfServiceView(),
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsView(),
      binding: BindingsBuilder(() {
        Get.put(NotificationsController());
      }),
    ),
  ];
}
