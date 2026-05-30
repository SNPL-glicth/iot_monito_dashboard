import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/auth/auth_storage.dart';
import '../../../../core/auth/token_manager.dart';
import '../../../../core/auth/user_role.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/presentation/widgets/bottom_nav.dart';
import '../../../../core/presentation/widgets/sidebar.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';
import '../../../alerts/presentation/pages/alerts_hub_page.dart';
import '../../../devices/presentation/pages/devices_hub_page.dart';
import '../../../intelligence/presentation/pages/intelligence_predictions_page.dart';
import '../widgets/crm_dashboard_content.dart';
import 'crm_account_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../../core/theme/design_text_styles.dart';


class CrmHomePage extends StatefulWidget {
  const CrmHomePage({super.key, required this.role});

  final UserRole role;

  @override
  State<CrmHomePage> createState() => _CrmHomePageState();
}

class _CrmHomePageState extends State<CrmHomePage> {
  final GlobalKey<CrmDashboardContentState> _dashboardKey =
      GlobalKey<CrmDashboardContentState>();
  final _pageKeys = List.generate(4, (_) => GlobalKey());
  int _selectedIndex = 0;
  bool _uiReady = false;

  String get _roleLabel => switch (widget.role) {
        UserRole.admin => 'Administrador',
        UserRole.operator => 'Operador',
        UserRole.viewer => 'Supervisor',
      };

  void refreshDashboard() => _dashboardKey.currentState?.refreshAll();

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DesignColors.surface,
        title: Text('Cerrar sesión', style: DesignTextStyles.screenTitle),
        content: Text('¿Estás seguro de que deseas cerrar sesión?', style: DesignTextStyles.bodyText),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancelar', style: DesignTextStyles.bodyText)),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Cerrar sesión', style: DesignTextStyles.bodyText.copyWith(color: DesignColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await AuthStorage().clearSession();
      ApiClient.authToken = null;
      TokenManager().stopMonitoring();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed. Please try again.', style: DesignTextStyles.bodyText), backgroundColor: DesignColors.red),
        );
      }
      return;
    }
    if (mounted) {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false,
      );
    }
  }

  late final List<Widget> _destinations = [
    CrmDashboardContent(key: _dashboardKey, role: widget.role),
    DevicesHubPage(key: _pageKeys[0], role: widget.role),
    AlertsHubPage(key: _pageKeys[1], role: widget.role),
    IntelligencePredictionsPage(key: _pageKeys[2]),
    CrmAccountPage(key: _pageKeys[3], role: widget.role, onLogout: _handleLogout),
  ];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _uiReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = DesignLayout.isDesktop(context);

    if (!_uiReady) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: DesignColors.cyan),
              SizedBox(height: DesignSpacing.md),
              Text('Iniciando...', style: DesignTextStyles.bodyText),
            ],
          ),
        ),
      );
    }

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _destinations[_selectedIndex],
    );

    if (isDesktop) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                width: isDesktop ? DesignLayout.sidebarWidth : 0,
                child: isDesktop
                    ? Sidebar(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                        userName: 'Usuario',
                        userRole: widget.role,
                        onLogout: _handleLogout,
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(DesignSpacing.lg),
                  child: body,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          SizedBox(width: DesignSpacing.sm),
          Text('ZENIN', style: DesignTextStyles.screenTitle),
          SizedBox(width: DesignSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
            decoration: BoxDecoration(color: DesignColors.surface2, borderRadius: BorderRadius.circular(DesignRadius.md), border: Border.all(color: DesignColors.border, width: 0.5)),
            child: Text(_roleLabel, style: DesignTextStyles.badgeText()),
          ),
        ]),
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
