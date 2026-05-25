import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';
import '../../data/admin_users_repository.dart';
import '../../data/models/admin_user.dart';
import 'dialog_text_field.dart';

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
            backgroundColor: DashboardColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DashboardColors.primaryAccent10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(isEdit ? Icons.edit_rounded : Icons.person_add_rounded, color: DashboardColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(isEdit ? 'Editar usuario' : 'Crear usuario', style: DashboardTextStyles.deviceTitle),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DialogTextField(controller: usernameController, label: 'Usuario', icon: Icons.person_outline_rounded),
                  const SizedBox(height: 12),
                  DialogTextField(controller: emailController, label: 'Email', icon: Icons.email_outlined),
                  const SizedBox(height: 12),
                  DialogTextField(
                    controller: passwordController,
                    label: isEdit ? 'Nueva contraseña (opcional)' : 'Contraseña',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    dropdownColor: DashboardColors.surfaceElevated,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Rol',
                      labelStyle: TextStyle(color: DashboardColors.white70),
                      prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: DashboardColors.white54, size: 20),
                      filled: true,
                      fillColor: DashboardColors.surfaceElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: DashboardColors.white10)),
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
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v),
                    title: const Text('Activo', style: TextStyle(color: Colors.white)),
                    activeTrackColor: DashboardColors.success,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: DashboardColors.white70),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashboardColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        SnackBar(content: Text('Error: $e'), backgroundColor: DashboardColors.error),
      );
    }
    return false;
  }
}
