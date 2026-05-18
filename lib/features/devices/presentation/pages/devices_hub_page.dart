import 'package:flutter/material.dart';

import '../../../../core/auth/user_role.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import 'devices_categories_page.dart';
import 'devices_clean_readings_page.dart';

class DevicesHubPage extends StatelessWidget {
  const DevicesHubPage({
    super.key,
    required this.role,
  });

  final UserRole role;

  void _comingSoon(BuildContext context, String feature) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  void _openCategories(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DevicesCategoriesPage(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header con gradiente
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
                  child: const Icon(Icons.devices_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Centro de Dispositivos', style: DashboardTextStyles.sectionHeader),
                      const SizedBox(height: 4),
                      Text(
                        'Gestión y monitoreo de equipos IoT',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Opciones
          _modernDeviceTile(
            icon: Icons.category_rounded,
            iconColor: DashboardColors.primary,
            title: isAdmin ? 'Dispositivos y sensores' : 'Mis dispositivos',
            subtitle: isAdmin
                ? 'Ver por categoría: electricidad, ambientales, temperatura'
                : 'Ver dispositivos por categoría',
            onTap: () => _openCategories(context),
          ),
          const SizedBox(height: 12),
          
          _modernDeviceTile(
            icon: Icons.settings_remote_rounded,
            iconColor: DashboardColors.secondary,
            title: 'Comandos remotos',
            subtitle: 'Enviar acciones y órdenes a dispositivos IoT',
            enabled: isAdmin || role == UserRole.operator,
            isComingSoon: true,
            onTap: () => _comingSoon(context, 'Comandos remotos'),
          ),
          
          if (isAdmin) ...[
            const SizedBox(height: 12),
            _modernDeviceTile(
              icon: Icons.cleaning_services_rounded,
              iconColor: DashboardColors.warning,
              title: 'Limpiar lecturas',
              subtitle: 'Herramienta de mantenimiento para datos históricos',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DevicesCleanReadingsPage(),
                  ),
                );
              },
            ),
          ],
          
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DashboardColors.white05,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: DashboardColors.info, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Esta sección centraliza la gestión de dispositivos',
                    style: DashboardTextStyles.sensorMeta,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernDeviceTile({
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
                            Flexible(
                              child: Text(title, style: DashboardTextStyles.deviceTitle),
                            ),
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
