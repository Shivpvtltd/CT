import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/preferences_service.dart';
import '../../data/models/session_model.dart';

class SessionProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  SessionProvider(this._prefs) {
    _loadSession();
    _startTimer();
  }

  SessionModel? _currentSession;
  Duration _remainingTime = Duration.zero;
  Timer? _countdownTimer;
  bool _isExpired = false;

  SessionModel? get currentSession => _currentSession;
  Duration get remainingTime => _remainingTime;
  bool get isExpired => _isExpired;
  bool get hasActiveSession => _currentSession != null && _currentSession!.isActive;

  String get formattedRemainingTime => _remainingTime.formatted;

  void _loadSession() {
    _currentSession = _prefs.getSession();
    if (_currentSession != null) {
      _updateRemainingTime();
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemainingTime(),
    );
  }

  void _updateRemainingTime() {
    if (_currentSession == null) {
      _remainingTime = Duration.zero;
      _isExpired = false;
      notifyListeners();
      return;
    }

    final remaining = _currentSession!.remainingTime;
    _remainingTime = remaining;
    _isExpired = _currentSession!.isExpired;

    if (_isExpired && _currentSession!.isActive) {
      // Session just expired
      _currentSession = _currentSession!.copyWith(isActive: false);
      _prefs.saveSession(_currentSession);
      _prefs.setSessionActive(false);
    }

    notifyListeners();
  }

  Future<void> startSession(String dnsProviderId, {bool isPremium = false}) async {
    final session = SessionModel.create(
      dnsProviderId: dnsProviderId,
      isPremium: isPremium,
    );

    _currentSession = session;
    _isExpired = false;
    await _prefs.saveSession(session);
    await _prefs.setSessionActive(true);
    await _prefs.setSessionStartTime(session.startTime);

    // Update daily session count for free users
    if (!isPremium) {
      final now = DateTime.now();
      final lastDate = _prefs.lastSessionDate;

      if (lastDate == null ||
          lastDate.year != now.year ||
          lastDate.month != now.month ||
          lastDate.day != now.day) {
        await _prefs.setSessionsToday(1);
      } else {
        await _prefs.setSessionsToday(_prefs.sessionsToday + 1);
      }
      await _prefs.setLastSessionDate(now);
    }

    notifyListeners();
  }

  Future<void> endSession() async {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(isActive: false);
      await _prefs.saveSession(_currentSession);
      await _prefs.setSessionActive(false);
    }
    _remainingTime = Duration.zero;
    notifyListeners();
  }

  Future<void> clearExpiredSession() async {
    _currentSession = null;
    _remainingTime = Duration.zero;
    _isExpired = false;
    await _prefs.saveSession(null);
    await _prefs.setSessionActive(false);
    await _prefs.setSessionStartTime(null);
    notifyListeners();
  }

  double get progressPercentage {
    if (_currentSession == null) return 0.0;
    return _currentSession!.progressPercentage;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

extension DurationFormatting on Duration {
  String get formatted {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
