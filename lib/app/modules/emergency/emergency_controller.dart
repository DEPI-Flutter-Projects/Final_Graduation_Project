import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyController extends GetxController {
  void callEmergency(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
