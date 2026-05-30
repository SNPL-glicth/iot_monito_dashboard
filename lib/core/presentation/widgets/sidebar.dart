import 'package:flutter/material.dart';
import '../../auth/user_role.dart';
import '../../theme/design_colors.dart';
import '../../theme/design_spacing.dart';
import '../../theme/design_text_styles.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.userName,
    required this.userRole,
    this.deviceCount = 0,
    this.mqttConnected = false,
    this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final String userName;
  final UserRole userRole;
  final int deviceCount;
  final bool mqttConnected;
  final VoidCallback? onLogout;

  static const _destinations = [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(icon: Icons.devices_outlined, label: 'Devices'),
    _NavItem(icon: Icons.notifications_outlined, label: 'Alerts'),
    _NavItem(icon: Icons.auto_graph_outlined, label: 'Intelligence'),
    _NavItem(icon: Icons.person_outline, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DesignLayout.sidebarWidth,
      decoration: BoxDecoration(
        color: DesignColors.surface,
        border: Border(right: BorderSide(color: DesignColors.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ZENIN', style: DesignTextStyles.screenTitle.copyWith(color: DesignColors.cyan)),
                  SizedBox(height: DesignSpacing.xs),
                  Text('IOT MONITORING', style: DesignTextStyles.badgeText()),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _destinations.length,
                itemBuilder: (context, index) {
                  final item = _destinations[index];
                  final isSelected = index == selectedIndex;
                  return _NavTile(
                    icon: item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    onTap: () => onDestinationSelected(index),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            if (deviceCount > 0)
              Padding(
                padding: EdgeInsets.all(DesignSpacing.lg),
                child: Row(
                  children: [
                    Text('DEVICES', style: DesignTextStyles.sectionTitle),
                    SizedBox(width: DesignSpacing.sm),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.xs, vertical: DesignSpacing.xs),
                      decoration: BoxDecoration(
                        color: DesignColors.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                      ),
                      child: Text('$deviceCount',
                          style: DesignTextStyles.badgeText(color: DesignColors.cyan)),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: mqttConnected ? DesignColors.green : DesignColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.xs),
                  Text(
                    mqttConnected ? 'CONNECTED' : 'OFFLINE',
                    style: DesignTextStyles.badgeText(
                      color: mqttConnected ? DesignColors.green : DesignColors.red,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            InkWell(
              onTap: () => onDestinationSelected(_destinations.length - 1),
              child: Padding(
                padding: EdgeInsets.all(DesignSpacing.lg),
                child: Row(
                  children: [
                    Icon(Icons.account_circle_outlined, size: 20, color: DesignColors.textPrimary),
                    SizedBox(width: DesignSpacing.sm),
                    Expanded(child: Text(userName, style: DesignTextStyles.bodyText)),
                    Icon(Icons.chevron_right_rounded, size: 16, color: DesignColors.textDim),
                  ],
                ),
              ),
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.logout_outlined, size: 20, color: DesignColors.red),
              title: Text('Logout', style: DesignTextStyles.bodyText.copyWith(color: DesignColors.red)),
              onTap: onLogout,
            ),
            SizedBox(height: DesignSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.label, required this.isSelected, required this.onTap});
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg, vertical: DesignSpacing.md),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: isSelected ? DesignColors.cyan : Colors.transparent, width: 2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? DesignColors.cyan : DesignColors.textSecondary),
            SizedBox(width: DesignSpacing.sm),
            Text(label, style: DesignTextStyles.bodyText.copyWith(
              color: isSelected ? DesignColors.textPrimary : DesignColors.textSecondary,
            )),
          ],
        ),
      ),
    );
  }
}
