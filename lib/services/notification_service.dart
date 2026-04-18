import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../core/constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    await _createChannels();

    _initialized = true;
  }

  Future<void> _createChannels() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.sessionExpiredChannelId,
        AppConstants.sessionExpiredChannelName,
        description: 'Notifies when your ad protection session expires',
        importance: Importance.high,
        enableVibration: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.dnsAutoOffChannelId,
        AppConstants.dnsAutoOffChannelName,
        description: 'Notifies when DNS protection is automatically disabled',
        importance: Importance.low,
        enableVibration: false,
        playSound: false,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.toolReminderChannelId,
        AppConstants.toolReminderChannelName,
        description: 'Reminders for your content creation tools',
        importance: Importance.defaultImportance,
      ),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to appropriate screen
    final payload = response.payload;
    if (payload == 'session_expired') {
      // Navigate to reactivation screen
    }
  }

  /// Show session expired notification
  Future<void> showSessionExpiredNotification() async {
    await _notifications.show(
      1001,
      'Session Ended',
      'Your protection session has expired. Open ShieldX to reactivate.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.sessionExpiredChannelId,
          AppConstants.sessionExpiredChannelName,
          channelDescription:
              'Notifies when your ShieldX session expires',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Session expired',
          autoCancel: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'session_expired',
    );
  }

  /// Show DNS auto-off notification
  Future<void> showDnsAutoOffNotification() async {
    await _notifications.show(
      1002,
      'Protection Disabled',
      'Ad protection was automatically turned off after session expiry.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.dnsAutoOffChannelId,
          AppConstants.dnsAutoOffChannelName,
          channelDescription:
              'Notifies when DNS protection is automatically disabled',
          importance: Importance.low,
          priority: Priority.low,
          autoCancel: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
      payload: 'dns_auto_off',
    );
  }

  /// Schedule session expiry notification
  Future<void> scheduleSessionExpiryNotification(DateTime expiryTime) async {
    await _notifications.zonedSchedule(
      2001,
      'Session Ended',
      'Your ShieldX protection session has expired.',
      tz.TZDateTime.from(expiryTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.sessionExpiredChannelId,
          AppConstants.sessionExpiredChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'session_expired',
    );
  }

  /// Show tool reminder notification (public cover)
  Future<void> showToolReminderNotification(String title, String body) async {
    await _notifications.show(
      3001,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.toolReminderChannelId,
          AppConstants.toolReminderChannelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: 'tool_reminder',
    );
  }

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final result = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    return true;
  }
}
