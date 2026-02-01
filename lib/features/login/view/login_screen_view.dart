import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';
import '../controller/login_controller.dart';
import '../widget/input_field.dart';
import '../widget/social_button.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  LoginController get controller =>
      Get.isRegistered<LoginController>()
          ? Get.find<LoginController>()
          : Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              /// Icon
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: OrColors.primaryGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 60,
                  color: OrColors.primaryGreenDark,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: OrColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Login to your account",
                style: TextStyle(fontSize: 16, color: OrColors.textGrey),
              ),

              const SizedBox(height: 40),

              /// FORM
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    InputField(
                      hint: "Email",
                      icon: Icons.email_outlined,
                      controller: controller.emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        if (!value.contains('@')) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Obx(
                          () => InputField(
                        hint: "Password",
                        icon: Icons.lock_outline,
                        controller: controller.passwordController,
                        isPassword: controller.ispass.value,
                        onTogglePassword: controller.togglePasswordVisibility,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// Login Button
              Obx(
                    () => Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        OrColors.primaryGreen,
                        OrColors.primaryGreenDark
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed:
                    controller.isLoading.value ? null : controller.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "or continue with",
                      style: TextStyle(color: OrColors.textGrey),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  InkWell( onTap: (){
                    Get.snackbar(
                      'Message',
                      'This feature will be available in up coming update',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                  },  child:const SocialButton(icon: Icons.g_mobiledata))
                  
                ],
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don’t have an account? ",
                    style: TextStyle(color: OrColors.textGrey),
                  ),
                  InkWell(
                    onTap: (){
                      Get.toNamed(Routes.signup);
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: OrColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
