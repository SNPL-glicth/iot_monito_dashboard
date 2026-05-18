import 'package:flutter/material.dart';

import '../../../../../features/monitoring/presentation/styles/dashboard_styles.dart';
import 'profile_tile.dart';

/// Card con información del perfil de usuario.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.username,
    required this.email,
    required this.roleLabel,
    required this.userId,
  });

  final String username;
  final String email;
  final String roleLabel;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ModernCardDecoration.elevated(),
      child: Column(
        children: [
          ProfileTile(
            icon: Icons.person_rounded,
            iconColor: DashboardColors.primary,
            label: 'Usuario',
            value: username.isEmpty ? '-' : username,
          ),
          _buildDivider(),
          ProfileTile(
            icon: Icons.email_rounded,
            iconColor: DashboardColors.secondary,
            label: 'Email',
            value: email.isEmpty ? '-' : email,
          ),
          _buildDivider(),
          ProfileTile(
            icon: Icons.verified_user_rounded,
            iconColor: DashboardColors.accent,
            label: 'Rol',
            value: roleLabel,
          ),
          if (userId.isNotEmpty) ...[
            _buildDivider(),
            ProfileTile(
              icon: Icons.fingerprint_rounded,
              iconColor: DashboardColors.warning,
              label: 'ID',
              value: userId,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withValues(alpha: 0.1),
      indent: 16,
      endIndent: 16,
    );
  }
}
