import 'package:flutter/material.dart';

import '../../../../../core/auth/user_role.dart';
import '../../data/admin_users_repository.dart';
import '../../data/models/admin_user.dart';
import '../widgets/delete_user_dialog.dart';
import 'admin_user_edit_page.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';

class AdminUserDetailsPage extends StatefulWidget {
  const AdminUserDetailsPage({
    super.key,
    required this.user,
    required this.currentRole,
  });

  final AdminUser user;
  final UserRole currentRole;

  @override
  State<AdminUserDetailsPage> createState() => _AdminUserDetailsPageState();
}

class _AdminUserDetailsPageState extends State<AdminUserDetailsPage> {
  late final AdminUsersRepository _repository;
  late AdminUser _user;

  @override
  void initState() {
    super.initState();
    _repository = AdminUsersRepository();
    _user = widget.user;
  }

  Future<void> _editUser() async {
    if (widget.currentRole != UserRole.admin) return;

    final updated = await Navigator.of(context).push<AdminUser>(
      MaterialPageRoute(
        builder: (_) => AdminUserEditPage(
          user: _user,
          currentRole: widget.currentRole,
        ),
      ),
    );

    if (updated == null) return;

    setState(() {
      _user = updated;
    });

    if (mounted) {
      Navigator.pop(context, true); // fuerza recarga en la lista al volver
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDeleteUserDialog(context: context, user: _user);
    if (ok != true) return;

    try {
      await _repository.deleteUser(_user.id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando usuario: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuario: ${_user.username}'),
      ),
      body: ListView(
        padding: EdgeInsets.all(DesignSpacing.lg),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('ID'),
              subtitle: Text(_user.id),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Usuario'),
              subtitle: Text(_user.username),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(_user.email),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Rol'),
              subtitle: Text(_user.role),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(
                _user.isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: _user.isActive ? Colors.green : Colors.red,
              ),
              title: const Text('Estado'),
              subtitle: Text(_user.isActive ? 'Activo' : 'Inactivo'),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.currentRole != UserRole.admin ? null : _editUser,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: widget.currentRole != UserRole.admin ? null : _confirmDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
