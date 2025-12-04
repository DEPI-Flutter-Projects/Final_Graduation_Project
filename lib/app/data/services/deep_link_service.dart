import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import '../../routes/app_routes.dart';

class DeepLinkService extends GetxService {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  Future<DeepLinkService> init() async {
    _appLinks = AppLinks();
    _initDeepLinkListener();
    return this;
  }

  void _initDeepLinkListener() {
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    }, onError: (err) {
      debugPrint('Deep Link Error: $err');
    });
  }

  void _handleUri(Uri uri) {
    if (uri.scheme == 'elmoshwar' && uri.host == 'share') {
      final from = uri.queryParameters['from'];
      final to = uri.queryParameters['to'];
      final mode = uri.queryParameters['mode'];

      if (from != null && to != null) {
        
        
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.toNamed(
            Routes.ROUTE_PLANNER,
            arguments: {
              'from': from,
              'to': to,
              'mode': mode ?? 'Car',
            },
          );
        });
      }
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
