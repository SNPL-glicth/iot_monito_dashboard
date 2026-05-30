import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../../core/theme/design_spacing.dart';

/// Icono de campana de notificaciones con soporte para animación.
class NotificationBellIcon extends StatelessWidget {
  const NotificationBellIcon({
    super.key,
    this.animation,
    required this.unreadCount,
    required this.badgeColor,
    required this.onTap,
  });

  final Animation<double>? animation;
  final int unreadCount;
  final Color badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Si la animación aún no está inicializada, mostrar icono estático
    if (animation == null) {
      return _buildStaticBell();
    }

    return AnimatedBuilder(
      animation: animation!,
      builder: (context, _) {
        final t = animation!.value;
        final scale = 1.0 + (0.10 * t);
        final rot = 0.05 * math.sin(t * math.pi * 2);
        final glow = 0.20 * t;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (unreadCount > 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: glow),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            Transform.rotate(
              angle: rot,
              child: Transform.scale(
                scale: scale,
                child: IconButton(
                  onPressed: onTap,
                  icon: Icon(
                    unreadCount > 0
                        ? Icons.notifications_active
                        : Icons.notifications_none_rounded,
                    color: unreadCount > 0 ? badgeColor : null,
                  ),
                  tooltip: 'Notificaciones',
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStaticBell() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(
            unreadCount > 0
                ? Icons.notifications_active
                : Icons.notifications_none_rounded,
            color: unreadCount > 0 ? badgeColor : null,
          ),
          tooltip: 'Notificaciones',
        ),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              constraints: const BoxConstraints(minWidth: 18),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
