import 'app_notification.dart';

/// Estado inmutable de notificaciones para UI reactiva.
class NotificationState {
  const NotificationState({
    required this.notifications,
    required this.isLoading,
    required this.lastFetchTime,
    this.error,
  });

  final List<AppNotification> notifications;
  final bool isLoading;
  final DateTime? lastFetchTime;
  final String? error;

  static const empty = NotificationState(
    notifications: [],
    isLoading: false,
    lastFetchTime: null,
  );

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  int get unreadAlertCount => notifications
      .where((n) => !n.isRead && n.source == NotificationSource.alert)
      .length;

  int get unreadMlCount => notifications
      .where((n) => !n.isRead && n.source == NotificationSource.mlEvent)
      .length;

  List<AppNotification> get unreadAlerts => notifications
      .where((n) => !n.isRead && n.source == NotificationSource.alert)
      .toList();

  List<AppNotification> get unreadMlEvents => notifications
      .where((n) => !n.isRead && n.source == NotificationSource.mlEvent)
      .toList();

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    DateTime? lastFetchTime,
    String? error,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      lastFetchTime: lastFetchTime ?? this.lastFetchTime,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
