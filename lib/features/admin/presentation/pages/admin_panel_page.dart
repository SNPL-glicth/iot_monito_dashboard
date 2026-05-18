import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../../users/presentation/pages/admin_users_page.dart';
import '../../../metrics/presentation/pages/server_metrics_page.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({
    super.key,
    required this.currentRole,
  });

  final UserRole currentRole;

  void _comingSoon(BuildContext context, String feature) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: DashboardColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(feature, style: DashboardTextStyles.sectionHeader),
          content: const Text(
            'Sección en construcción (próximamente).',
            style: DashboardTextStyles.sensorMeta,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar', style: TextStyle(color: DashboardColors.primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = currentRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: ModernCardDecoration.gradient(DashboardColors.gradientPrimary),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Panel de Administración', style: DashboardTextStyles.sectionHeader),
                      const SizedBox(height: 4),
                      Text(
                        'Gestiona usuarios y configuraciones',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Sección Gestión
          _sectionTitle('Gestión'),
          const SizedBox(height: 12),
          
          _modernSettingsTile(
            icon: Icons.group_rounded,
            iconColor: DashboardColors.primary,
            title: 'Gestionar usuarios',
            subtitle: 'Crear, editar, desactivar usuarios y roles',
            enabled: isAdmin,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AdminUsersPage(currentRole: currentRole),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          
          _modernSettingsTile(
            icon: Icons.settings_rounded,
            iconColor: DashboardColors.secondary,
            title: 'Preferencias del sistema',
            subtitle: 'Ajustes generales de la plataforma',
            enabled: isAdmin,
            isComingSoon: true,
            onTap: () => _comingSoon(context, 'Preferencias del sistema'),
          ),
          
          const SizedBox(height: 24),
          _sectionTitle('Observabilidad'),
          const SizedBox(height: 12),
          
          _modernSettingsTile(
            icon: Icons.analytics_rounded,
            iconColor: DashboardColors.accent,
            title: 'Métricas del Servidor',
            subtitle: 'CPU, RAM, ingesta, BD - Solo lectura',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ServerMetricsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: DashboardTextStyles.smallLabel.copyWith(
          color: Colors.white38,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _modernSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool enabled = true,
    bool isComingSoon = false,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        decoration: ModernCardDecoration.elevated(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(title, style: DashboardTextStyles.deviceTitle),
                            if (isComingSoon) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: DashboardColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Pronto',
                                  style: TextStyle(
                                    color: DashboardColors.warning,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(subtitle, style: DashboardTextStyles.sensorMeta),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
