import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';

class InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final VoidCallback? onTogglePassword;

  const InputField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: OrColors.textGrey),
          hintText: hint,
          hintStyle: const TextStyle(color: OrColors.textGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),

          /// 👁️ Toggle Icon
          suffixIcon: onTogglePassword != null
              ? IconButton(
            icon: Icon(
              isPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: OrColors.textGrey,
            ),
            onPressed: onTogglePassword,
          )
              : null,
        ),
      ),
    );
  }
}
