import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigation is handled by `SplashController` (binding) so the view
    // should only present UI and not perform routing itself.

    return Scaffold(
      backgroundColor: OrColors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// App Icon Container
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                color: OrColors.primaryGreen.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                size: 72,
                color: OrColors.primaryGreenDark,
              ),
            ),

            const SizedBox(height: 24),

            /// App Name
            const Text(
              "Orginizo",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: OrColors.textDark,
              ),
            ),

            const SizedBox(height: 8),

            /// Tagline
            const Text(
              "Organize tasks. Never miss a moment.",
              style: TextStyle(
                fontSize: 16,
                color: OrColors.textGrey,
              ),
            ),

            const SizedBox(height: 40),

            /// Loading Indicator
            const CircularProgressIndicator(
              color: OrColors.primaryGreenDark,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
