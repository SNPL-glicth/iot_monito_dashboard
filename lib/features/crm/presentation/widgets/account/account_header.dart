import 'package:flutter/material.dart';
import '../../../../../core/auth/current_user.dart';
import '../../../../../core/auth/user_role.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Header de la página de cuenta con avatar, nombre, email y rol.
class AccountHeader extends StatelessWidget {
  const AccountHeader({
    super.key,
    required this.user,
    required this.role,
  });

  final CurrentUser? user;
  final UserRole role;

  String get _roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.operator:
        return 'Operador';
      case UserRole.viewer:
        return 'Supervisor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;

    final username = (user?.username ?? '').trim();
    final rawEmail = (user?.email ?? '').trim();
    final email = (rawEmail.toLowerCase() == 'null') ? '' : rawEmail;
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Container(
      padding: EdgeInsets.fromLTRB(20, isMobile ? 24 : 28, 20, isMobile ? 24 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignColors.cyan.withValues(alpha: 0.3),
            DesignColors.background,
          ],
        ),
      ),
      child: isMobile
          ? Column(
              children: [
                Container(
                  padding: EdgeInsets.all(DesignSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [DesignColors.cyan, DesignColors.cyanDim]),
                    borderRadius: BorderRadius.circular(DesignRadius.xl),
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
                SizedBox(height: DesignSpacing.md),
                Text(
                  username.isEmpty ? 'Usuario' : username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  email.isEmpty ? '—' : email,
                  style: DesignTextStyles.bodyText,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cuenta (próximamente)')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    backgroundColor: Colors.white10,
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(Icons.manage_accounts_outlined, size: 18),
                  label: const Text('Administrar cuenta'),
                ),
                SizedBox(height: DesignSpacing.md),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: DesignColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignRadius.xl),
                  ),
                  child: Text(
                    _roleLabel,
                    style: DesignTextStyles.badgeText(color: DesignColors.cyan),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white10,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username.isEmpty ? 'Usuario' : username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: DesignSpacing.xs),
                      Text(
                        email.isEmpty ? '—' : email,
                        style: DesignTextStyles.bodyText,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: DesignSpacing.sm),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(_roleLabel, style: DesignTextStyles.badgeText()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
