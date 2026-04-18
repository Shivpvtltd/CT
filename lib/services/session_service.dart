import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../data/local/preferences_service.dart';
import '../data/models/session_model.dart';
import 'notification_service.dart';

class SessionService {
  final PreferencesService _prefs;
  final NotificationService _notificationService;

  SessionService(this._prefs, this._notificationService);

  /// Start a new 6-hour session
  Future<SessionModel> startSession(String dnsProviderId, {bool isPremium = false}) async {
    final session = SessionModel.create(
      dnsProviderId: dnsProviderId,
      isPremium: isPremium,
    );

    await _prefs.saveSession(session);
    await _prefs.setSessionActive(true);
    await _prefs.setSessionStartTime(session.startTime);

    // Schedule expiry notification
    await _notificationService.scheduleSessionExpiryNotification(
      session.expiryTime,
    );

    return session;
  }

  /// End the current session immediately
  Future<void> endSession() async {
    final session = _prefs.getSession();
    if (session != null) {
      final updatedSession = session.copyWith(isActive: false);
      await _prefs.saveSession(updatedSession);
    }
    await _prefs.setSessionActive(false);
    await _prefs.setSessionStartTime(null);

    // Cancel scheduled notifications
    await _notificationService.cancelAllNotifications();
  }

  /// Check if current session is expired and handle accordingly
  Future<SessionCheckResult> checkSession() async {
    final session = _prefs.getSession();

    if (session == null) {
      return SessionCheckResult.noSession;
    }

    if (session.isExpired) {
      if (session.isActive) {
        // Auto-deactivate
        await endSession();
        await _notificationService.showSessionExpiredNotification();
      }
      return SessionCheckResult.expired;
    }

    if (!session.isActive) {
      return SessionCheckResult.inactive;
    }

    return SessionCheckResult.active;
  }

  /// Get remaining time for current session
  Duration getRemainingTime() {
    final session = _prefs.getSession();
    if (session == null) return Duration.zero;
    return session.remainingTime;
  }

  /// Reset daily session counter (call at midnight)
  Future<void> resetDailyCounter() async {
    await _prefs.setSessionsToday(0);
  }

  /// Force clear all session data
  Future<void> forceClear() async {
    await _prefs.saveSession(null);
    await _prefs.setSessionActive(false);
    await _prefs.setSessionStartTime(null);
    await _notificationService.cancelAllNotifications();
  }
}

enum SessionCheckResult {
  noSession,
  active,
  inactive,
  expired,
}
