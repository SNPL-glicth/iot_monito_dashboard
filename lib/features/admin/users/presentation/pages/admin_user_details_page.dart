import 'package:flutter/material.dart';

import '../../../../../core/auth/user_role.dart';
import '../../data/admin_users_repository.dart';
import 'admin_user_edit_page.dart';

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
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar usuario'),
          content: Text('¿Seguro que deseas eliminar a ${_user.username}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    await _repository.deleteUser(_user.id);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuario: ${_user.username}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.currentRole != UserRole.admin ? null : _editUser,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
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
