import 'package:flutter/material.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


/// Widgets helper para el formulario de login
class LoginFormWidgets {
  /// Construye label de campo
  static Widget buildInputLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: DesignColors.textPrimary,
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
        hintStyle: TextStyle(color: DesignColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: DesignColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: DesignColors.surface2,
        contentPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg, vertical: DesignSpacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.md),
          borderSide: BorderSide(color: DesignColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.md),
          borderSide: BorderSide(color: DesignColors.cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.md),
          borderSide: BorderSide(color: DesignColors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.md),
          borderSide: BorderSide(color: DesignColors.red, width: 1.5),
        ),
        errorStyle: TextStyle(color: DesignColors.red, fontSize: 12),
      ),
    );
  }

  /// Construye widget de mensaje de error
  static Widget buildErrorMessage(String message) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        border: Border.all(
          color: DesignColors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: DesignColors.red,
            size: 18,
          ),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: DesignTextStyles.bodyText,
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
            activeColor: DesignColors.cyan,
            side: BorderSide(
              color: DesignColors.textSecondary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: DesignSpacing.sm),
        Text(
          'Mantener sesión iniciada',
          style: DesignTextStyles.bodyText,
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
          backgroundColor: DesignColors.cyan,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DesignColors.cyan.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.md),
          ),
        ),
        child: isLoading
            ? SizedBox(
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
