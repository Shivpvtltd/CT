import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/preferences_service.dart';
import '../../data/models/user_model.dart';

class PremiumProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  PremiumProvider(this._prefs) {
    _loadUserData();
  }

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isPremium => _user?.isPremium ?? false;
  int get sessionsToday => _user?.sessionsToday ?? 0;
  int get remainingFreeSessions => _user?.remainingFreeSessions ?? 2;
  bool get canStartFreeSession => _user?.canStartFreeSession ?? true;

  void _loadUserData() {
    _user = _prefs.getUser() ?? const UserModel();
    notifyListeners();
  }

  Future<void> activatePremium({bool yearly = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call for purchase
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      final expiry = yearly
          ? now.add(const Duration(days: 365))
          : now.add(const Duration(days: 30));

      _user = (_user ?? const UserModel()).copyWith(
        isPremium: true,
        premiumExpiry: expiry,
      );

      await _prefs.setPremium(true);
      await _prefs.setPremiumExpiry(expiry);
      await _prefs.saveUser(_user!);

      _error = null;
    } catch (e) {
      _error = 'Failed to activate premium: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate restore API call
      await Future.delayed(const Duration(seconds: 1));

      // For demo: randomly decide if premium was found
      final hasPremium = _prefs.isPremium;

      if (hasPremium) {
        final expiry = _prefs.premiumExpiry;
        _user = (_user ?? const UserModel()).copyWith(
          isPremium: true,
          premiumExpiry: expiry,
        );
        await _prefs.saveUser(_user!);
        _error = null;
      } else {
        _error = 'No previous purchases found.';
      }
    } catch (e) {
      _error = 'Failed to restore purchases: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> recordFreeSession() async {
    if (_user == null) return;

    final now = DateTime.now();
    final lastDate = _user!.lastSessionDate;

    int newCount;
    if (lastDate == null ||
        lastDate.year != now.year ||
        lastDate.month != now.month ||
        lastDate.day != now.day) {
      newCount = 1;
    } else {
      newCount = _user!.sessionsToday + 1;
    }

    _user = _user!.copyWith(
      sessionsToday: newCount,
      lastSessionDate: now,
    );

    await _prefs.setSessionsToday(newCount);
    await _prefs.setLastSessionDate(now);
    await _prefs.saveUser(_user!);

    notifyListeners();
  }

  Future<void> resetDailySessions() async {
    if (_user == null) return;

    _user = _user!.copyWith(sessionsToday: 0);
    await _prefs.setSessionsToday(0);
    await _prefs.saveUser(_user!);

    notifyListeners();
  }

  Future<void> simulatePurchaseForTesting() async {
    await activatePremium(yearly: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
