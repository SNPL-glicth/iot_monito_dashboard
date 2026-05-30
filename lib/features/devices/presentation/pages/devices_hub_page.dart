import 'package:flutter/material.dart';
import '../../../../core/auth/user_role.dart';
import 'devices_categories_page.dart';
import 'devices_clean_readings_page.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


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
        backgroundColor: DesignColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.lg)),
        title: Text(feature, style: DesignTextStyles.screenTitle),
        content: Text(
          'Sección en construcción (próximamente).',
          style: DesignTextStyles.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(color: DesignColors.textPrimary)),
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
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(DesignSpacing.lg),
          children: [
          // Header con gradiente
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [DesignColors.cyan, DesignColors.cyanDim]), borderRadius: BorderRadius.circular(DesignRadius.lg)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(DesignSpacing.md),
                  decoration: BoxDecoration(
                    color: DesignColors.textPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                  child: Icon(Icons.devices_rounded, color: DesignColors.textPrimary, size: 28),
                ),
                SizedBox(width: DesignSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Centro de Dispositivos', style: DesignTextStyles.screenTitle),
                      SizedBox(height: DesignSpacing.xs),
                      Text(
                        'Gestión y monitoreo de equipos IoT',
                        style: TextStyle(color: DesignColors.textPrimary.withValues(alpha: 0.8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: DesignSpacing.xl),
          
          // Opciones
          _modernDeviceTile(
            icon: Icons.category_rounded,
            iconColor: DesignColors.cyan,
            title: isAdmin ? 'Dispositivos y sensores' : 'Mis dispositivos',
            subtitle: isAdmin
                ? 'Ver por categoría: electricidad, ambientales, temperatura'
                : 'Ver dispositivos por categoría',
            onTap: () => _openCategories(context),
          ),
          SizedBox(height: DesignSpacing.md),
          
          _modernDeviceTile(
            icon: Icons.settings_remote_rounded,
            iconColor: DesignColors.cyanDim,
            title: 'Comandos remotos',
            subtitle: 'Enviar acciones y órdenes a dispositivos IoT',
            enabled: isAdmin || role == UserRole.operator,
            isComingSoon: true,
            onTap: () => _comingSoon(context, 'Comandos remotos'),
          ),
          
          if (isAdmin) ...[
            SizedBox(height: DesignSpacing.md),
            _modernDeviceTile(
              icon: Icons.cleaning_services_rounded,
              iconColor: DesignColors.amber,
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
          
          SizedBox(height: DesignSpacing.lg),
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: DesignColors.border,
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: DesignColors.textSecondary, size: 18),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    'Esta sección centraliza la gestión de dispositivos',
                    style: DesignTextStyles.bodyText,
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
        decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(DesignSpacing.md),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(DesignRadius.md),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  SizedBox(width: DesignSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(title, style: DesignTextStyles.cardTitle),
                            ),
                            if (isComingSoon) ...[
                              SizedBox(width: DesignSpacing.sm),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
                                decoration: BoxDecoration(
                                  color: DesignColors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                                ),
                                child: Text(
                                  'Pronto',
                                  style: TextStyle(
                                    color: DesignColors.amber,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: DesignSpacing.xs),
                        Text(subtitle, style: DesignTextStyles.bodyText),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: DesignColors.textPrimary.withValues(alpha: 0.3),
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
