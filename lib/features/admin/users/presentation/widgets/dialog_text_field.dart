import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


/// Campo de texto estilizado para diálogos de administración.
class DialogTextField extends StatelessWidget {
  const DialogTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: DesignColors.textPrimary),
        prefixIcon: Icon(icon, color: DesignColors.textSecondary, size: 20),
        filled: true,
        fillColor: DesignColors.surface2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.md), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.md), borderSide: BorderSide(color: DesignColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.md), borderSide: BorderSide(color: DesignColors.cyan, width: 1.5)),
      ),
    );
  }
}
