import 'package:flutter/material.dart';
import 'profile_tile.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';


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
      decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
      child: Column(
        children: [
          ProfileTile(
            icon: Icons.person_rounded,
            iconColor: DesignColors.cyan,
            label: 'Usuario',
            value: username.isEmpty ? '-' : username,
          ),
          _buildDivider(),
          ProfileTile(
            icon: Icons.email_rounded,
            iconColor: DesignColors.cyanDim,
            label: 'Email',
            value: email.isEmpty ? '-' : email,
          ),
          _buildDivider(),
          ProfileTile(
            icon: Icons.verified_user_rounded,
            iconColor: DesignColors.green,
            label: 'Rol',
            value: roleLabel,
          ),
          if (userId.isNotEmpty) ...[
            _buildDivider(),
            ProfileTile(
              icon: Icons.fingerprint_rounded,
              iconColor: DesignColors.amber,
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
