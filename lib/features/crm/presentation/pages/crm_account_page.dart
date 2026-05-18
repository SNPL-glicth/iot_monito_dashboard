import 'package:flutter/material.dart';

import '../../../../core/auth/current_user.dart';
import '../../../../core/auth/user_role.dart';
import '../../../../core/network/api_client.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../widgets/account/account_header.dart';
import '../widgets/account/profile_card.dart';

class CrmAccountPage extends StatefulWidget {
  const CrmAccountPage({
    super.key,
    required this.role,
  });

  final UserRole role;

  @override
  State<CrmAccountPage> createState() => _CrmAccountPageState();
}

class _CrmAccountPageState extends State<CrmAccountPage> {
  final _api = ApiClient();

  bool _loading = false;
  String? _error;
  CurrentUser? _user;

  @override
  void initState() {
    super.initState();
    _user = CurrentUser.value;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Si ya tenemos user desde login-token, lo mostramos al tiro.
    // Si no, intentamos /auth/me (útil si se reabre app con token persistido en futuro).
    if (_user != null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final json = await _api.getJson('/auth/me');
      final raw = (json['user'] as Map?)?.cast<String, dynamic>();
      if (raw != null) {
        final u = CurrentUser.fromJson({
          'id': raw['userId'] ?? raw['sub'] ?? raw['id'],
          'username': raw['username'],
          'email': raw['email'],
          'role': raw['role'],
        });
        CurrentUser.value = u;
        _user = u;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;
    final username = (u?.username ?? '').trim();
    final rawEmail = (u?.email ?? '').trim();
    final email = (rawEmail.toLowerCase() == 'null') ? '' : rawEmail;

    final String roleLabel;
    switch (widget.role) {
      case UserRole.admin:
        roleLabel = 'Administrador';
        break;
      case UserRole.operator:
        roleLabel = 'Operador';
        break;
      case UserRole.viewer:
        roleLabel = 'Supervisor';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _user = null;
          });
          CurrentUser.clear();
          await _bootstrap();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            AccountHeader(user: _user, role: widget.role),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error cargando perfil: $_error', style: DashboardTextStyles.error),
              )
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: DashboardColors.primaryAccent10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: DashboardColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Información personal', style: DashboardTextStyles.sectionHeader),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ProfileCard(
                      username: username,
                      email: email,
                      roleLabel: roleLabel,
                      userId: u?.id ?? '',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DashboardColors.white05,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: DashboardColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Desliza hacia abajo para refrescar',
                              style: DashboardTextStyles.sensorMeta,
                            ),
                          ),
                        ],
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
