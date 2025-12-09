import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../modules/route_planner/widgets/route_share_card.dart';

import 'package:gal/gal.dart';

class ShareService extends GetxService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<Uint8List> _generateRouteImageBytes({
    required String startLocation,
    required String endLocation,
    required String distance,
    required String duration,
    required String cost,
    required List<LatLng> routePoints,
    required String userName,
    String? carModel,
  }) async {
    return await _screenshotController.captureFromWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          child: RouteShareCard(
            startLocation: startLocation,
            endLocation: endLocation,
            distance: distance,
            duration: duration,
            cost: cost,
            routePoints: routePoints,
            userName: userName,
            carModel: carModel,
          ),
        ),
      ),
      delay: const Duration(seconds: 2),
      pixelRatio: 1.0,
      targetSize: const Size(1080, 2400),
      context: Get.context,
    );
  }

  Future<void> shareRouteImage({
    required String startLocation,
    required String endLocation,
    required String distance,
    required String duration,
    required String cost,
    required List<LatLng> routePoints,
    required String userName,
    String? carModel,
  }) async {
    try {
      final imageBytes = await _generateRouteImageBytes(
        startLocation: startLocation,
        endLocation: endLocation,
        distance: distance,
        duration: duration,
        cost: cost,
        routePoints: routePoints,
        userName: userName,
        carModel: carModel,
      );

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'route_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(imageBytes);

      await SharePlus.instance.share(
        ShareParams(
          subject: 'Check out my route on El-Moshwar! 🚗💨',
          files: [XFile(file.path)],
        ),
      );
    } catch (e) {
      debugPrint('Error sharing route image: $e');
      Get.snackbar('Error', 'Failed to generate share image');
    }
  }

  Future<void> saveRouteImageToGallery({
    required String startLocation,
    required String endLocation,
    required String distance,
    required String duration,
    required String cost,
    required List<LatLng> routePoints,
    required String userName,
    String? carModel,
  }) async {
    try {
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();
      }

      final imageBytes = await _generateRouteImageBytes(
        startLocation: startLocation,
        endLocation: endLocation,
        distance: distance,
        duration: duration,
        cost: cost,
        routePoints: routePoints,
        userName: userName,
        carModel: carModel,
      );

      await Gal.putImageBytes(imageBytes,
          name: 'ElMoshwar_Route_${DateTime.now().millisecondsSinceEpoch}');
      Get.snackbar('Success', 'Image saved to gallery! 📸',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
      if (e is GalException) {
        Get.snackbar(
            'Permission Denied', 'Please allow photo access to save image.');
      } else {
        Get.snackbar('Error', 'Failed to save image');
      }
    }
  }

  Future<void> shareRouteLink({
    required String startLocation,
    required String endLocation,
    required String mode,
  }) async {
    try {
      final uri = Uri(
        scheme: 'elmoshwar',
        host: 'share',
        queryParameters: {
          'from': startLocation,
          'to': endLocation,
          'mode': mode,
        },
      );

      final link = uri.toString();

      await SharePlus.instance.share(
        ShareParams(
          text: 'Tap to view my route on El-Moshwar:\n$link',
          subject: 'El-Moshwar Route',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing route link: $e');
      Get.snackbar('Error', 'Failed to share link');
    }
  }
}
