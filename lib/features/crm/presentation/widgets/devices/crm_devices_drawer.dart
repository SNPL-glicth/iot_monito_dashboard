import 'package:flutter/material.dart';

import '../../../../../core/auth/current_user.dart';
import '../../../../../core/auth/auth_storage.dart';
import '../../../../../core/auth/token_manager.dart';
import '../../../../../core/auth/user_role.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../admin/presentation/pages/admin_panel_page.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../pages/crm_account_page.dart';
import '../../pages/crm_home_page.dart';

/// Drawer de la página de dispositivos CRM.
class CrmDevicesDrawer extends StatelessWidget {
  const CrmDevicesDrawer({
    super.key,
    required this.role,
    required this.roleLabel,
  });

  final UserRole role;
  final String roleLabel;

  Future<void> _logout(BuildContext context) async {
    ApiClient.authToken = null;
    CurrentUser.clear();
    await AuthStorage().clearSession();
    TokenManager().stopMonitoring();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    return Drawer(
      backgroundColor: const Color(0xFF020617),
      child: Theme(
        data: baseTheme.copyWith(
          listTileTheme: const ListTileThemeData(
            iconColor: Colors.white70,
            textColor: Colors.white,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFF020617)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.sensors, color: Colors.tealAccent, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('IoT System', style: DashboardTextStyles.drawerHeaderTitle),
                          const SizedBox(height: 4),
                          Text(roleLabel, style: DashboardTextStyles.drawerHeaderSubtitle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dashboard_outlined),
                      title: const Text('Dashboard'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => CrmHomePage(role: role),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.devices_outlined),
                      title: const Text('Dispositivos'),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.warning_amber_outlined),
                      title: const Text('Alertas'),
                      subtitle: const Text('Histórico + acciones (según rol).'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alertas (próximamente)')),
                        );
                      },
                    ),
                    if (role == UserRole.admin)
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Configuraciones'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AdminPanelPage(currentRole: role),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_circle_outlined),
                      title: Text('Cuenta ($roleLabel)'),
                      subtitle: const Text('Perfil e información de la sesión.'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CrmAccountPage(role: role),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text('Cerrar sesión'),
                      onTap: () {
                        Navigator.pop(context);
                        _logout(context);
                      },
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
