import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  /// Waits for Firebase to restore session via authStateChanges (do not use currentUser at startup).
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = await _auth.authStateChanges().first;

    if (user != null) {
      Get.offAllNamed(Routes.main);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }
}

