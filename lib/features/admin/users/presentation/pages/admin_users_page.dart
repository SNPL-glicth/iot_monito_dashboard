import 'package:flutter/material.dart';
import '../../../../../core/auth/user_role.dart';
import '../../data/admin_users_repository.dart';
import '../../data/models/admin_user.dart';
import '../widgets/user_dialog.dart';
import '../widgets/delete_user_dialog.dart';
import 'admin_user_details_page.dart';
import 'admin_user_edit_page.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key, required this.currentRole});

  final UserRole currentRole;

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late final AdminUsersRepository _repository;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  final List<AdminUser> _users = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;
  static const _pageSize = 20;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _repository = AdminUsersRepository();
    _scrollController.addListener(_onScroll);
    _loadUsers(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || !_hasMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadUsers({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _users.clear();
        _currentPage = 1;
        _hasMore = true;
      });
    }
    try {
      final response = await _repository.fetchUsers(
        page: 1,
        pageSize: _pageSize,
        q: _searchQuery,
      );
      setState(() {
        _users.addAll(response.items);
        _hasMore = response.hasMore;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final response = await _repository.fetchUsers(
        page: nextPage,
        pageSize: _pageSize,
        q: _searchQuery,
      );
      setState(() {
        _users.addAll(response.items);
        _currentPage = nextPage;
        _hasMore = response.hasMore;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() => _loadingMore = false);
    }
  }

  void _onSearch(String value) {
    _searchQuery = value.trim();
    _loadUsers(reset: true);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = null;
    _loadUsers(reset: true);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? DesignColors.red : DesignColors.green,
      ),
    );
  }

  Future<void> _showUserDialog({AdminUser? user}) async {
    final saved = await showUserDialog(
      context: context,
      repository: _repository,
      user: user,
    );
    if (!mounted) return;
    if (saved) {
      _showSnack(user == null ? 'Usuario creado' : 'Cambios guardados');
      _loadUsers(reset: true);
    }
  }

  Future<void> _confirmDelete(AdminUser user) async {
    final confirmed = await showDeleteUserDialog(context: context, user: user);
    if (!confirmed || !mounted) return;
    try {
      await _repository.deleteUser(user.id);
      if (!mounted) return;
      _showSnack('Usuario eliminado');
      _removeUserFromList(user.id);
    } catch (e) {
      if (mounted) _showSnack('Error eliminando usuario: $e', isError: true);
    }
  }

  void _removeUserFromList(String id) {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      setState(() => _users.removeAt(idx));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de usuarios'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuario...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery != null && _searchQuery!.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
                    : null,
                filled: true,
                fillColor: DesignColors.surface2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignRadius.sm), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: _onSearch,
            ),
          ),
        ),
      ),
      body: _buildBody(isMobile),
      floatingActionButton: widget.currentRole != UserRole.admin
          ? null
          : FloatingActionButton(
              backgroundColor: DesignColors.cyan,
              onPressed: () => _showUserDialog(),
              child: const Icon(Icons.add_rounded),
            ),
    );
  }

  Widget _buildBody(bool isMobile) {
    if (_loading && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error', textAlign: TextAlign.center),
            SizedBox(height: DesignSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _loadUsers(reset: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (_users.isEmpty) {
      return const Center(child: Text('No hay usuarios registrados.'));
    }

    if (isMobile) {
      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(DesignSpacing.md),
        itemCount: _users.length + (_hasMore || _loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return _buildFooter();
          }
          final u = _users[index];
          return _UserCard(
            user: u,
            currentRole: widget.currentRole,
            onTap: () async {
              final changed = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => AdminUserDetailsPage(user: u, currentRole: widget.currentRole),
                ),
              );
              if (!mounted) return;
              if (changed == true) _loadUsers(reset: true);
            },
            onEdit: () async {
              final updated = await Navigator.of(context).push<AdminUser>(
                MaterialPageRoute(
                  builder: (_) => AdminUserEditPage(user: u, currentRole: widget.currentRole),
                ),
              );
              if (!mounted) return;
              if (updated != null) {
                _showSnack('Cambios guardados');
                _loadUsers(reset: true);
              }
            },
            onDelete: () => _confirmDelete(u),
          );
        },
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
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
        rows: _users.map((u) => DataRow(
          cells: [
            DataCell(Text(u.id)),
            DataCell(
              InkWell(
                onTap: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => AdminUserDetailsPage(user: u, currentRole: widget.currentRole),
                    ),
                  );
                  if (!mounted) return;
                  if (changed == true) _loadUsers(reset: true);
                },
                child: Text(u.username, style: const TextStyle(decoration: TextDecoration.underline)),
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
                              builder: (_) => AdminUserEditPage(user: u, currentRole: widget.currentRole),
                            ),
                          );
                          if (!mounted) return;
                          if (updated != null) {
                            _showSnack('Cambios guardados');
                            _loadUsers(reset: true);
                          }
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: widget.currentRole != UserRole.admin ? null : () => _confirmDelete(u),
                ),
              ],
            )),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    if (_loadingMore) {
      return Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Center(child: LinearProgressIndicator(minHeight: 2)),
      );
    }
    if (!_hasMore) {
      return Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Center(child: Text('Sin más usuarios', style: TextStyle(color: DesignColors.textSecondary, fontSize: 12))),
      );
    }
    return SizedBox.shrink();
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.currentRole,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminUser user;
  final UserRole currentRole;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          user.isActive ? Icons.check_circle : Icons.cancel,
          color: user.isActive ? Colors.green : Colors.red,
        ),
        title: Text(user.username),
        subtitle: Text('${user.email}\nrol: ${user.role}'),
        isThreeLine: true,
        onTap: onTap,
        trailing: currentRole != UserRole.admin
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
      ),
    );
  }
}
