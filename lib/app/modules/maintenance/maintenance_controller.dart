import 'package:get/get.dart';
import '../../core/utils/app_snackbars.dart';

class MaintenanceController extends GetxController {
  final RxList<Map<String, dynamic>> upcomingServices = <Map<String, dynamic>>[
    {
      'title': 'Oil Change',
      'date': '2023-12-01',
      'cost': '1200',
    },
    {
      'title': 'Tire Rotation',
      'date': '2023-12-15',
      'cost': '400',
    },
    {
      'title': 'Brake Inspection',
      'date': '2024-01-10',
      'cost': '300',
    },
  ].obs;

  void addService() {
    AppSnackbars.showInfo(
        'Coming Soon', 'Add Service feature is under development');
  }

  void onFeatureTap(String featureName) {
    AppSnackbars.showInfo(
        'Coming Soon', '$featureName feature is under development');
  }
}
