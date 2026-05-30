import 'package:flutter/material.dart';
import '../../data/admin_users_repository.dart';
import '../../data/models/admin_user.dart';
import 'dialog_text_field.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Muestra diálogo para crear o editar un usuario.
Future<bool> showUserDialog({
  required BuildContext context,
  required AdminUsersRepository repository,
  required AdminUser? user,
}) async {
  final isEdit = user != null;
  final usernameController = TextEditingController(text: user?.username ?? '');
  final emailController = TextEditingController(text: user?.email ?? '');
  final passwordController = TextEditingController();
  String role = user?.role ?? 'viewer';
  bool isActive = user?.isActive ?? true;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: DesignColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.lg)),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(DesignSpacing.sm),
                  decoration: BoxDecoration(
                    color: DesignColors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                  child: Icon(isEdit ? Icons.edit_rounded : Icons.person_add_rounded, color: DesignColors.cyan, size: 20),
                ),
                SizedBox(width: DesignSpacing.md),
                Text(isEdit ? 'Editar usuario' : 'Crear usuario', style: DesignTextStyles.cardTitle),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DialogTextField(controller: usernameController, label: 'Usuario', icon: Icons.person_outline_rounded),
                  SizedBox(height: DesignSpacing.md),
                  DialogTextField(controller: emailController, label: 'Email', icon: Icons.email_outlined),
                  SizedBox(height: DesignSpacing.md),
                  DialogTextField(
                    controller: passwordController,
                    label: isEdit ? 'Nueva contraseña (opcional)' : 'Contraseña',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                  ),
                  SizedBox(height: DesignSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    dropdownColor: DesignColors.surface2,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Rol',
                      labelStyle: TextStyle(color: DesignColors.textPrimary),
                      prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: DesignColors.textSecondary, size: 20),
                      filled: true,
                      fillColor: DesignColors.surface2,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.md), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.md), borderSide: BorderSide(color: DesignColors.border)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                      DropdownMenuItem(value: 'viewer', child: Text('Supervisor')),
                      DropdownMenuItem(value: 'operator', child: Text('Operador')),
                    ],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => role = value);
                    },
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  SwitchListTile(
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v),
                    title: const Text('Activo', style: TextStyle(color: Colors.white)),
                    activeTrackColor: DesignColors.green,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: DesignColors.textPrimary),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.cyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.sm)),
                ),
                child: Text(isEdit ? 'Guardar' : 'Crear'),
              ),
            ],
          );
        },
      );
    },
  );

  if (result != true) return false;

  final username = usernameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text;

  if (username.isEmpty || email.isEmpty || (!isEdit && password.isEmpty)) {
    return false;
  }

  try {
    if (isEdit) {
      await repository.updateUser(
        id: user.id,
        username: username,
        email: email,
        password: password.isNotEmpty ? password : null,
        role: role,
        isActive: isActive,
      );
    } else {
      await repository.createUser(
        username: username,
        email: email,
        password: password,
        role: role,
        isActive: isActive,
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: DesignColors.red),
      );
    }
    return false;
  }
}
