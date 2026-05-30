import 'package:flutter/material.dart';

import '../../../../../core/auth/user_role.dart';
import '../../data/admin_users_repository.dart';
import '../../data/models/admin_user.dart';
import '../../../../../core/theme/design_spacing.dart';

class AdminUserEditPage extends StatefulWidget {
  const AdminUserEditPage({
    super.key,
    required this.user,
    required this.currentRole,
  });

  final AdminUser user;
  final UserRole currentRole;

  @override
  State<AdminUserEditPage> createState() => _AdminUserEditPageState();
}

class _AdminUserEditPageState extends State<AdminUserEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final AdminUsersRepository _repository;

  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  late String _role;
  late bool _isActive;
  bool _changePassword = false;
  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _repository = AdminUsersRepository();

    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _role = widget.user.role;
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.currentRole != UserRole.admin) return;
    if (_isSaving) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _isSaving = true);

    try {
      final updated = await _repository.updateUser(
        id: widget.user.id,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        role: _role,
        isActive: _isActive,
        password: _changePassword ? _passwordController.text : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados')),
      );
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.currentRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar: ${widget.user.username}'),
        actions: [
          TextButton(
            onPressed: canEdit ? _save : null,
            child: _isSaving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(DesignSpacing.lg),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(DesignSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Datos del usuario',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _usernameController,
                      enabled: canEdit,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Usuario requerido';
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      enabled: canEdit,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email requerido';
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _role,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                        DropdownMenuItem(value: 'viewer', child: Text('Supervisor')),
                        DropdownMenuItem(value: 'operator', child: Text('Operador')),
                      ],
                      onChanged: !canEdit
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _role = value);
                            },
                    ),
                    SizedBox(height: 8),
                    SwitchListTile(
                      value: _isActive,
                      onChanged: !canEdit ? null : (v) => setState(() => _isActive = v),
                      title: const Text('Activo'),
                      secondary: const Icon(Icons.verified_user_outlined),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Card(
              child: Padding(
                padding: EdgeInsets.all(DesignSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seguridad',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    SwitchListTile(
                      value: _changePassword,
                      onChanged: !canEdit ? null : (v) => setState(() => _changePassword = v),
                      title: const Text('Cambiar contraseña'),
                      subtitle: const Text('Solo se actualiza si activas esta opción.'),
                      secondary: const Icon(Icons.lock_outline),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_changePassword) ...[
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        enabled: canEdit,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Nueva contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: (v) {
                          if (!_changePassword) return null;
                          if (v == null || v.isEmpty) return 'Contraseña requerida';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        enabled: canEdit,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmar contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword,
                            ),
                            icon:
                                Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: (v) {
                          if (!_changePassword) return null;
                          if (v == null || v.isEmpty) return 'Confirma la contraseña';
                          if (v != _passwordController.text) return 'No coincide';
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            if (!canEdit)
              const Text('Acceso de solo lectura para tu rol.'),
            if (canEdit)
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar cambios'),
              ),
          ],
        ),
      ),
    );
  }
}
