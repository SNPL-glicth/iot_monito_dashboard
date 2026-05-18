import 'package:flutter/material.dart';

import '../../../../../core/auth/user_role.dart';
import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../data/admin_users_repository.dart';
import '../widgets/user_dialog.dart';
import '../widgets/delete_user_dialog.dart';
import 'admin_user_details_page.dart';
import 'admin_user_edit_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({
    super.key,
    required this.currentRole,
  });

  final UserRole currentRole;

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late final AdminUsersRepository _repository;
  late Future<List<AdminUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _repository = AdminUsersRepository();
    _reload();
  }

  void _reload() {
    setState(() {
      _usersFuture = _repository.fetchUsers();
    });
  }

  Future<void> _showUserDialog({AdminUser? user}) async {
    final saved = await showUserDialog(
      context: context,
      repository: _repository,
      user: user,
    );
    if (saved && mounted) _reload();
  }

  Future<void> _confirmDelete(AdminUser user) async {
    final confirmed = await showDeleteUserDialog(context: context, user: user);
    if (confirmed) {
      await _repository.deleteUser(user.id);
      if (mounted) _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de usuarios'),
      ),
      body: FutureBuilder<List<AdminUser>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          // En móvil: lista vertical (sin scroll horizontal). Tap en usuario -> detalle.
          if (isMobile) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];

                return Card(
                  child: ListTile(
                    leading: Icon(
                      u.isActive ? Icons.check_circle : Icons.cancel,
                      color: u.isActive ? Colors.green : Colors.red,
                    ),
                    title: Text(u.username),
                    subtitle: Text('${u.email}\nrol: ${u.role}'),
                    isThreeLine: true,
                    onTap: () async {
                      final changed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => AdminUserDetailsPage(
                            user: u,
                            currentRole: widget.currentRole,
                          ),
                        ),
                      );
                      if (!mounted) return;

                      if (changed == true) {
                        _reload();
                      }
                    },
                    trailing: widget.currentRole != UserRole.admin
                        ? null
                        : PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final updated = await Navigator.of(context).push<AdminUser>(
                                  MaterialPageRoute(
                                    builder: (_) => AdminUserEditPage(
                                      user: u,
                                      currentRole: widget.currentRole,
                                    ),
                                  ),
                                );
                                if (!mounted) return;
                                if (updated != null) {
                                  _reload();
                                }
                              }
                              if (value == 'delete') {
                                await _confirmDelete(u);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Editar')),
                              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                            ],
                          ),
                  ),
                );
              },
            );
          }

          // En pantallas grandes: DataTable (útil para web/desktop).
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Usuario')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Rol')),
                DataColumn(label: Text('Activo')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: users
                  .map(
                    (u) => DataRow(
                      cells: [
                        DataCell(Text(u.id)),
                        DataCell(
                          InkWell(
                            onTap: () async {
                              final changed = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => AdminUserDetailsPage(
                                    user: u,
                                    currentRole: widget.currentRole,
                                  ),
                                ),
                              );
                              if (!mounted) return;
                              if (changed == true) {
                                _reload();
                              }
                            },
                            child: Text(
                              u.username,
                              style: const TextStyle(decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                        DataCell(Text(u.email)),
                        DataCell(Text(u.role)),
                        DataCell(Icon(
                          u.isActive ? Icons.check_circle : Icons.cancel,
                          color: u.isActive ? Colors.green : Colors.red,
                          size: 18,
                        )),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: widget.currentRole != UserRole.admin
                                  ? null
                                  : () async {
                                      final updated = await Navigator.of(context).push<AdminUser>(
                                        MaterialPageRoute(
                                          builder: (_) => AdminUserEditPage(
                                            user: u,
                                            currentRole: widget.currentRole,
                                          ),
                                        ),
                                      );
                                      if (!mounted) return;
                                      if (updated != null) {
                                        _reload();
                                      }
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              onPressed: widget.currentRole != UserRole.admin
                                  ? null
                                  : () => _confirmDelete(u),
                            ),
                          ],
                        )),
                      ],
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
      floatingActionButton: widget.currentRole != UserRole.admin
          ? null
          : FloatingActionButton(
              backgroundColor: DashboardColors.primary,
              onPressed: () => _showUserDialog(),
              child: const Icon(Icons.add_rounded),
            ),
    );
  }

}
