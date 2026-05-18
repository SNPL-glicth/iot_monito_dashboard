import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../../core/auth/auth_storage.dart';
import '../../../../core/auth/token_manager.dart';
import '../../../../core/network/api_client.dart';
import '../../../admin/presentation/pages/admin_panel_page.dart';
import '../../../devices/presentation/pages/devices_hub_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../../intelligence/presentation/pages/intelligence_predictions_page.dart';
import '../../../intelligence/presentation/pages/intelligence_health_page.dart';
import '../../../intelligence/presentation/pages/intelligence_decisions_page.dart';
import '../pages/crm_devices_page.dart';
import '../pages/crm_account_page.dart';

/// Drawer del CRM con navegación y perfil de usuario.
class CrmDrawer extends StatelessWidget {
  const CrmDrawer({
    super.key,
    required this.role,
    required this.roleLabel,
  });

  final UserRole role;
  final String roleLabel;

  Future<void> _logout(BuildContext context) async {
    ApiClient.authToken = null;
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
    return Drawer(
      backgroundColor: DashboardColors.background,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _modernDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isSelected: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  _modernDrawerItem(
                    icon: Icons.devices_rounded,
                    title: 'Dispositivos',
                    subtitle: role == UserRole.admin
                        ? 'Gestión y configuración'
                        : 'Lista y perfiles',
                    onTap: () {
                      Navigator.pop(context);
                      if (role == UserRole.admin) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DevicesHubPage(role: role),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CrmDevicesPage(role: role),
                        ),
                      );
                    },
                  ),
                  if (role == UserRole.admin)
                    _modernDrawerItem(
                      icon: Icons.tune_rounded,
                      title: 'Configuraciones',
                      subtitle: 'Ajustes del sistema',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AdminPanelPage(currentRole: role),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  _drawerSectionTitle('Inteligencia'),
                  _modernDrawerItem(
                    icon: Icons.auto_awesome,
                    title: 'Análisis ML',
                    subtitle: 'Tendencias y proyecciones',
                    iconColor: DashboardColors.secondary,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const IntelligencePredictionsPage(),
                        ),
                      );
                    },
                  ),
                  _modernDrawerItem(
                    icon: Icons.insights_rounded,
                    title: 'Estado del modelo',
                    subtitle: 'Salud y actualizaciones',
                    iconColor: DashboardColors.accent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const IntelligenceHealthPage(),
                        ),
                      );
                    },
                  ),
                  _modernDrawerItem(
                    icon: Icons.task_alt_rounded,
                    title: 'Decisiones',
                    subtitle: 'Acciones recomendadas',
                    iconColor: Colors.teal,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const IntelligenceDecisionsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: Column(
                children: [
                  _modernDrawerItem(
                    icon: Icons.account_circle_rounded,
                    title: 'Mi cuenta',
                    subtitle: roleLabel,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CrmAccountPage(role: role),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _modernDrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'Cerrar sesión',
                    iconColor: DashboardColors.error,
                    isDestructive: true,
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashboardColors.primary.withValues(alpha: 0.3),
            DashboardColors.background,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: DashboardColors.gradientPrimary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.sensors, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('IoT System', style: DashboardTextStyles.drawerHeaderTitle),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DashboardColors.primaryAccent20,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    roleLabel,
                    style: DashboardTextStyles.smallLabel.copyWith(
                      color: DashboardColors.primaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: DashboardTextStyles.smallLabel.copyWith(
          color: Colors.white38,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _modernDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    bool isSelected = false,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final color = iconColor ?? DashboardColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected
            ? DashboardColors.primaryAccent10
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDestructive ? DashboardColors.error : color)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? DashboardColors.error : color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDestructive
                              ? DashboardColors.error
                              : Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: DashboardTextStyles.sensorMeta,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: DashboardColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
