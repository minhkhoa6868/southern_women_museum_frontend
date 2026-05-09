import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool obscureText;
  final ThemeData theme;
  final Color textColor;
  final String? Function(String?)? validator;
  
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.icon,
    this.suffixIcon,
    this.obscureText = false,
    required this.theme,
    required this.textColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: theme.textTheme.headlineSmall,
      decoration: _buildDecoration(),
      validator: validator,
    );
  }

  InputDecoration _buildDecoration() {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      filled: true,
      fillColor: theme.colorScheme.surface.withValues(alpha: 0.7),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: textColor.withValues(alpha: 0.7),
        letterSpacing: 1,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textColor.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      hintStyle: theme.textTheme.bodyLarge?.copyWith(
        color: textColor.withValues(alpha: 0.4),
      ),
      prefixIcon: icon != null 
          ? Icon(icon, color: textColor.withValues(alpha: 0.6), size: 20)
          : null,
      suffixIcon: suffixIcon,
    );
  }
}