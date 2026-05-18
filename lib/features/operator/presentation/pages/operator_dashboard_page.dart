import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/auth/auth_storage.dart';
import '../../../../core/auth/token_manager.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../../../core/auth/user_role.dart';
import '../../../alerts/presentation/pages/alerts_hub_page.dart';
import '../../../devices/presentation/pages/devices_hub_page.dart';

class OperatorDashboardPage extends StatelessWidget {
  const OperatorDashboardPage({
    super.key,
    required this.role,
  });

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final roleLabel = role == UserRole.operator ? 'Operador' : 'Usuario';
    if (role != UserRole.operator) {
      // Si por alguna razón un viewer cae aquí, evitamos inconsistencia.
      return const Scaffold(
        body: Center(child: Text('Acceso restringido: este dashboard es solo para Operador.')),
      );
    }

    return Scaffold(
      drawer: _buildOperatorDrawer(context, roleLabel),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text('IoT Monitoring', style: DashboardTextStyles.appBarTitle),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                roleLabel,
                style: DashboardTextStyles.appBarRoleChip,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.devices_outlined),
              title: const Text('Mis dispositivos'),
              subtitle: const Text('Ver solo los dispositivos asignados.'),
              onTap: () => _comingSoon(context, 'Mis dispositivos'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: const Text('Alertas en tiempo real'),
              subtitle: const Text('Alertas según límites que te afecten.'),
              onTap: () => _comingSoon(context, 'Alertas en tiempo real'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_remote_outlined),
              title: const Text('Comandos remotos (limitados)'),
              subtitle: const Text('Ejecutar comandos permitidos según permisos.'),
              onTap: () => _comingSoon(context, 'Comandos remotos'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.query_stats_outlined),
              title: const Text('Históricos simples'),
              subtitle: const Text('Consulta básica de métricas por rango de fechas.'),
              onTap: () => _comingSoon(context, 'Históricos simples'),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildOperatorDrawer(BuildContext context, String roleLabel) {
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
                decoration: const BoxDecoration(
                  color: Color(0xFF020617),
                ),
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
                          const Text(
                            'IoT Monitoring',
                            style: DashboardTextStyles.drawerHeaderTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            roleLabel,
                            style: DashboardTextStyles.drawerHeaderSubtitle,
                          ),
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
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.devices_outlined),
                      title: const Text('Dispositivos'),
                      subtitle: const Text('Mis dispositivos + comandos.'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DevicesHubPage(role: role),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.warning_amber_outlined),
                      title: const Text('Alertas'),
                      subtitle: const Text('Alertas + reportes.'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AlertsHubPage(role: role),
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
                      onTap: () {
                        Navigator.pop(context);
                        _showUserInfoDialog(context, roleLabel);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text('Cerrar sesión'),
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        Navigator.pop(context);
                        ApiClient.authToken = null;
                        await AuthStorage().clearSession();
                        TokenManager().stopMonitoring();
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
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

  Future<void> _showUserInfoDialog(BuildContext context, String roleLabel) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: DashboardColors.cardBackground,
          title: const Text(
            'Usuario actual',
            style: DashboardTextStyles.sectionHeader,
          ),
          content: Text(
            'Rol: $roleLabel\n\nEn futuras versiones se puede mostrar más información del perfil aquí.',
            style: DashboardTextStyles.sensorMeta,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _comingSoon(BuildContext context, String feature) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(feature),
          content: const Text('Sección en construcción (próximamente).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
