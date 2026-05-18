import 'package:flutter/material.dart';

import '../../../../../core/notifications/notification_state_service.dart';
import 'notification_count_chip.dart';
import 'notification_tile.dart';

/// Diálogo de notificaciones - usa StreamBuilder para reactividad.
class NotificationsDialog extends StatelessWidget {
  const NotificationsDialog({
    super.key,
    required this.service,
    required this.onNotificationTap,
  });

  final NotificationStateService service;
  final Future<void> Function(AppNotification) onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NotificationState>(
      stream: service.stateStream,
      initialData: service.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? NotificationState.empty;
        final notifications = state.notifications;
        final unreadAlerts = state.unreadAlerts;
        final unreadMl = state.unreadMlEvents;

        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications, color: Colors.white70),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Notificaciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (state.unreadCount > 0)
                        TextButton(
                          onPressed: () async {
                            await service.markAllAsRead();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Marcar todas'),
                        ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                if (state.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                if (state.unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        if (unreadAlerts.isNotEmpty) ...[
                          NotificationCountChip(
                            count: unreadAlerts.length,
                            label: 'Alertas',
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (unreadMl.isNotEmpty)
                          NotificationCountChip(
                            count: unreadMl.length,
                            label: 'ML',
                            color: Colors.purpleAccent,
                          ),
                      ],
                    ),
                  ),
                Flexible(
                  child: notifications.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 48,
                                  color: Colors.white24,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Sin notificaciones',
                                  style: TextStyle(color: Colors.white38),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: notifications.length,
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.white12,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final n = notifications[index];
                            return NotificationTile(
                              notification: n,
                              onTap: () => onNotificationTap(n),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
