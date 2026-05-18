import 'package:flutter/material.dart';

import '../../../monitoring/presentation/styles/dashboard_styles.dart';

/// Widgets helper para el formulario de login
class LoginFormWidgets {
  /// Construye label de campo
  static Widget buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: DashboardColors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Construye textfield moderno
  static Widget buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: DashboardColors.white54, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: DashboardColors.white54, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: DashboardColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DashboardColors.white10, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DashboardColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DashboardColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DashboardColors.error, width: 1.5),
        ),
        errorStyle: TextStyle(color: DashboardColors.error, fontSize: 12),
      ),
    );
  }

  /// Construye widget de mensaje de error
  static Widget buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.redAccent15,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: DashboardColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: DashboardColors.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: DashboardTextStyles.error,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye checkbox de recordar sesión
  static Widget buildRememberMeCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: DashboardColors.primary,
            side: BorderSide(
              color: DashboardColors.white54,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Mantener sesión iniciada',
          style: DashboardTextStyles.sensorMeta,
        ),
      ],
    );
  }

  /// Construye botón de login
  static Widget buildLoginButton({
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: DashboardColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DashboardColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Ingresar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
