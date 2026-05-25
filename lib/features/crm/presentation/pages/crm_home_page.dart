import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../core/auth/user_role.dart';
import '../../../monitoring/presentation/styles/dashboard_styles.dart';
import '../widgets/notification_bell_widget.dart';
import '../widgets/crm_dashboard_content.dart';
import '../widgets/crm_drawer.dart';

class CrmHomePage extends StatefulWidget {
  const CrmHomePage({
    super.key,
    required this.role,
  });

  final UserRole role;

  @override
  State<CrmHomePage> createState() => _CrmHomePageState();
}

class _CrmHomePageState extends State<CrmHomePage> {
  // FIX FASE 1: Usar GlobalKey para acceder al estado del dashboard sin rebuild completo
  final GlobalKey<CrmDashboardContentState> _dashboardKey = GlobalKey<CrmDashboardContentState>();

  // FIX FREEZE: Diferir construcción de widgets pesados
  bool _uiReady = false;

  String get _roleLabel {
    switch (widget.role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.operator:
        return 'Operador';
      case UserRole.viewer:
        return 'Supervisor';
    }
  }

  void refreshDashboard() {
    // FIX FASE 1: No usar UniqueKey - evita rebuild completo del árbol
    _dashboardKey.currentState?.refreshAll();
  }

  @override
  void initState() {
    super.initState();
    // Mostrar el dashboard inmediatamente; el skeleton interno de
    // CrmDashboardContent se encarga del estado de carga.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _uiReady = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CrmDrawer(role: widget.role, roleLabel: _roleLabel),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text('IoT System', style: DashboardTextStyles.appBarTitle),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _roleLabel,
                style: DashboardTextStyles.appBarRoleChip,
              ),
            ),
          ],
        ),
        actions: [
          // FIX FREEZE: Diferir campana hasta que UI esté lista
          if (_uiReady) const NotificationBellWidget(),
          const SizedBox(width: 8),
        ],
      ),
      // FIX FREEZE: Diferir dashboard hasta que UI esté lista
      body: _uiReady 
          ? CrmDashboardContent(
              key: _dashboardKey,
              role: widget.role,
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Iniciando...',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
    );
  }

}
