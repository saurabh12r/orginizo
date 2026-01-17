import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/error/firebase_error.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/local_storage_services/pref_service.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Loading state
  final isLoading = false.obs;
  final ispass = true.obs;


  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      debugPrint("User ID: ${credential.user!.uid}");

      // Persist a lightweight flag so app can avoid asking to login again
      await PrefService().setLoggedIn(true);

      // Navigate to home
      Get.offAllNamed(Routes.schedule);

    } on FirebaseAuthException catch (e) {
      final msg = AuthErrorMessages.getMessage(e.code);

      Get.snackbar(
        'Authentication Error',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    ispass.value = !ispass.value;
  }



  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
