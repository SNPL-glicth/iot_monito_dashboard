import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Vista del formulario para crear un nuevo dispositivo.
class DeviceFormView extends StatelessWidget {
  const DeviceFormView({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.isLoading,
    required this.error,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final bool isLoading;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignSpacing.xl),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(DesignSpacing.xl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [DesignColors.cyan, DesignColors.cyanDim]),
                  borderRadius: BorderRadius.circular(DesignRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: DesignColors.cyan.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.devices_rounded, size: 48, color: Colors.white),
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Nuevo Dispositivo IoT',
              style: DesignTextStyles.screenTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Ingresa el nombre para identificar tu dispositivo',
              style: DesignTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(DesignSpacing.xl),
              decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre del dispositivo',
                    style: TextStyle(
                      color: DesignColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => onSubmit(),
                    decoration: InputDecoration(
                      hintText: 'Ej: Bodega Norte, Refrigerador #3',
                      hintStyle: TextStyle(color: DesignColors.textSecondary, fontSize: 14),
                      prefixIcon: Icon(Icons.label_outline_rounded, color: DesignColors.textSecondary, size: 20),
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
                      errorStyle: TextStyle(color: DesignColors.red, fontSize: 12),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresa un nombre para el dispositivo';
                      }
                      if (v.trim().length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: DesignSpacing.xl),
                  if (error != null)
                    Container(
                      padding: EdgeInsets.all(DesignSpacing.md),
                      margin: EdgeInsets.only(bottom: DesignSpacing.lg),
                      decoration: BoxDecoration(
                        color: DesignColors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                        border: Border.all(color: DesignColors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: DesignColors.red, size: 18),
                          SizedBox(width: DesignSpacing.sm),
                          Expanded(
                            child: Text(error!, style: DesignTextStyles.bodyText),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onSubmit,
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
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('Crear Dispositivo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
