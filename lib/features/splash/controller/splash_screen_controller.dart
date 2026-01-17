import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/local_storage_services/pref_service.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = await _auth.authStateChanges().first;
    final prefLoggedIn = await PrefService().isLoggedIn();

    if (user != null || prefLoggedIn) {
      Get.offAllNamed(Routes.schedule);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }
}

