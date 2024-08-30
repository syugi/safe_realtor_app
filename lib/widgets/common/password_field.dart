import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isPasswordVisible;
  final Function onToggleVisibility;
  final String labelText;

  const PasswordField({
    super.key,
    required this.controller,
    required this.isPasswordVisible,
    required this.onToggleVisibility,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => onToggleVisibility(),
        ),
      ),
    );
  }
}
