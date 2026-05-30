import 'package:flutter/material.dart';
import '../../../../core/auth/current_user.dart';
import '../../../../core/auth/user_role.dart';
import '../../../../core/network/api_client.dart';
import '../widgets/account/account_header.dart';
import '../widgets/account/profile_card.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


class CrmAccountPage extends StatefulWidget {
  const CrmAccountPage({
    super.key,
    required this.role,
    this.onLogout,
  });

  final UserRole role;
  final VoidCallback? onLogout;

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

    final roleLabel = {UserRole.admin: 'Administrador', UserRole.operator: 'Operador', UserRole.viewer: 'Supervisor'}[widget.role]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async { setState(() => _user = null); CurrentUser.clear(); await _bootstrap(); },
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
                padding: EdgeInsets.all(DesignSpacing.lg),
                child: Text('Error cargando perfil: $_error', style: DesignTextStyles.bodyText),
              )
            else
              Padding(
                padding: EdgeInsets.all(DesignSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: EdgeInsets.all(DesignSpacing.sm),
                        decoration: BoxDecoration(color: DesignColors.cyan.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(DesignRadius.sm)),
                        child: Icon(Icons.info_outline_rounded, color: DesignColors.textSecondary, size: 20),
                      ),
                      SizedBox(width: DesignSpacing.md),
                      Text('Información personal', style: DesignTextStyles.screenTitle),
                    ]),
                    SizedBox(height: DesignSpacing.lg),
                    ProfileCard(username: username, email: email, roleLabel: roleLabel, userId: u?.id ?? ''),
                    SizedBox(height: DesignSpacing.lg),
                    Container(
                      padding: EdgeInsets.all(DesignSpacing.md),
                      decoration: BoxDecoration(color: DesignColors.border, borderRadius: BorderRadius.circular(DesignRadius.sm)),
                      child: Row(children: [
                        Icon(Icons.lightbulb_outline_rounded, color: DesignColors.amber, size: 18),
                        SizedBox(width: DesignSpacing.sm),
                        Expanded(child: Text('Desliza hacia abajo para refrescar', style: DesignTextStyles.bodyText)),
                      ]),
                    ),
                    SizedBox(height: DesignSpacing.xl),
                    if (widget.onLogout != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: widget.onLogout,
                          icon: Icon(Icons.logout_outlined, color: DesignColors.red),
                          label: Text('Cerrar sesión', style: DesignTextStyles.bodyText.copyWith(color: DesignColors.red)),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

}
