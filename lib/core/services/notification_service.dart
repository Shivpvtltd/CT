import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'dnsguard_channel';

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> showSessionExpiredNotification() async {
    const android = AndroidNotificationDetails(
      _channelId,
      'DNSGuard',
      channelDescription: 'Ad protection status updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF00E5FF),
    );
    const ios = DarwinNotificationDetails();
    await _plugin.show(
      1,
      'Protection Ended',
      'Your 6-hour ad protection session has expired. Tap to reactivate.',
      const NotificationDetails(android: android, iOS: ios),
    );
  }

  static Future<void> showDnsOffNotification() async {
    const android = AndroidNotificationDetails(
      _channelId,
      'DNSGuard',
      channelDescription: 'Ad protection status updates',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails();
    await _plugin.show(
      2,
      'Protection Paused',
      'Ad protection has been turned off.',
      const NotificationDetails(android: android, iOS: ios),
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

// ignore: avoid_classes_with_only_static_members
class Color {
  final int value;
  const Color(this.value);
}
