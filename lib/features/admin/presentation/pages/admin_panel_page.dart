import 'package:flutter/material.dart';
import '../../../../core/auth/user_role.dart';
import '../../users/presentation/pages/admin_users_page.dart';
import '../../../metrics/presentation/pages/server_metrics_page.dart';
import '../../../../../core/theme/design_colors.dart';
import '../../../../../core/theme/design_spacing.dart';
import '../../../../../core/theme/design_text_styles.dart';


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
              child: Text('Cerrar', style: TextStyle(color: DesignColors.cyan)),
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
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(DesignSpacing.lg),
          children: [
          // Header
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
                  child: Icon(Icons.tune_rounded, color: DesignColors.textPrimary, size: 28),
                ),
                SizedBox(width: DesignSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Panel de Administración', style: DesignTextStyles.screenTitle),
                      SizedBox(height: DesignSpacing.xs),
                      Text(
                        'Gestiona usuarios y configuraciones',
                        style: TextStyle(color: DesignColors.textPrimary.withValues(alpha: 0.8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: DesignSpacing.xl),
          
          // Sección Gestión
          _sectionTitle('Gestión'),
          SizedBox(height: DesignSpacing.md),
          
          _modernSettingsTile(
            icon: Icons.group_rounded,
            iconColor: DesignColors.cyan,
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
          SizedBox(height: DesignSpacing.md),
          
          _modernSettingsTile(
            icon: Icons.settings_rounded,
            iconColor: DesignColors.cyanDim,
            title: 'Preferencias del sistema',
            subtitle: 'Ajustes generales de la plataforma',
            enabled: isAdmin,
            isComingSoon: true,
            onTap: () => _comingSoon(context, 'Preferencias del sistema'),
          ),
          
          SizedBox(height: DesignSpacing.xl),
          _sectionTitle('Observabilidad'),
          SizedBox(height: DesignSpacing.md),
          
          _modernSettingsTile(
            icon: Icons.analytics_rounded,
            iconColor: DesignColors.green,
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
    ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: DesignSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: DesignTextStyles.timestamp.copyWith(
          color: DesignColors.textDim,
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
                            Text(title, style: DesignTextStyles.cardTitle),
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
