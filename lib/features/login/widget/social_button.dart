
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;

  const SocialButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(icon, size: 32),
    );
  }
}