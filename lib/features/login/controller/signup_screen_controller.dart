import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/error/firebase_error.dart';
import '../../../core/services/local_storage_services/pref_service.dart';
import '../../../core/services/username_service.dart';
import '../../../data/repository/user_repository.dart';
import '../../../routes/app_routes.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers`
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // States
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // OPTIONAL: update display name
      await credential.user!.updateDisplayName(nameController.text.trim());

      // Username for Firestore task sync (immutable after signup)
      await UsernameService().setUsername(nameController.text.trim());
      await PrefService().setLoggedIn(true);

      // Save display name to Firestore for Home greeting (users/{uid}/name)
      final name = nameController.text.trim();
      if (name.isNotEmpty) {
        try {
          await UserRepository().saveCurrentUserName(name);
        } catch (_) {
          // Do not block signup; greeting will fallback to default
        }
      }

      debugPrint("User created: ${credential.user!.uid}");

      Get.offAllNamed(Routes.main);

    } on FirebaseAuthException catch (e) {
      final msg = getFirebaseAuthMessage(e.code);

      Get.snackbar(
        'Signup Error',
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

  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPassword() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
