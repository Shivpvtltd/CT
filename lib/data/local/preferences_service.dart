import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/session_model.dart';
import '../models/user_model.dart';

class PreferencesService {
  static PreferencesService? _instance;
  late SharedPreferences _prefs;

  PreferencesService._();

  static Future<PreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = PreferencesService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // First Launch
  bool get isFirstLaunch =>
      _prefs.getBool(AppConstants.prefFirstLaunch) ?? true;

  Future<void> setFirstLaunch(bool value) async {
    await _prefs.setBool(AppConstants.prefFirstLaunch, value);
  }

  // Theme
  String get themeMode =>
      _prefs.getString(AppConstants.prefTheme) ?? 'system';

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(AppConstants.prefTheme, mode);
  }

  // Premium
  bool get isPremium =>
      _prefs.getBool(AppConstants.prefIsPremium) ?? false;

  Future<void> setPremium(bool value) async {
    await _prefs.setBool(AppConstants.prefIsPremium, value);
  }

  DateTime? get premiumExpiry {
    final str = _prefs.getString(AppConstants.prefPremiumExpiry);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  Future<void> setPremiumExpiry(DateTime? date) async {
    if (date == null) {
      await _prefs.remove(AppConstants.prefPremiumExpiry);
    } else {
      await _prefs.setString(
        AppConstants.prefPremiumExpiry,
        date.toIso8601String(),
      );
    }
  }

  // Sessions
  int get sessionsToday =>
      _prefs.getInt(AppConstants.prefSessionsToday) ?? 0;

  Future<void> setSessionsToday(int count) async {
    await _prefs.setInt(AppConstants.prefSessionsToday, count);
  }

  DateTime? get lastSessionDate {
    final str = _prefs.getString(AppConstants.prefLastSessionDate);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  Future<void> setLastSessionDate(DateTime? date) async {
    if (date == null) {
      await _prefs.remove(AppConstants.prefLastSessionDate);
    } else {
      await _prefs.setString(
        AppConstants.prefLastSessionDate,
        date.toIso8601String(),
      );
    }
  }

  // DNS
  String get preferredDnsProvider =>
      _prefs.getString(AppConstants.prefDnsProvider) ?? 'adguard';

  Future<void> setPreferredDnsProvider(String providerId) async {
    await _prefs.setString(AppConstants.prefDnsProvider, providerId);
  }

  // Session State
  bool get isSessionActive =>
      _prefs.getBool(AppConstants.prefSessionActive) ?? false;

  Future<void> setSessionActive(bool active) async {
    await _prefs.setBool(AppConstants.prefSessionActive, active);
  }

  DateTime? get sessionStartTime {
    final str = _prefs.getString(AppConstants.prefSessionStartTime);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  Future<void> setSessionStartTime(DateTime? time) async {
    if (time == null) {
      await _prefs.remove(AppConstants.prefSessionStartTime);
    } else {
      await _prefs.setString(
        AppConstants.prefSessionStartTime,
        time.toIso8601String(),
      );
    }
  }

  bool get isDnsActive =>
      _prefs.getBool(AppConstants.prefDnsActive) ?? false;

  Future<void> setDnsActive(bool active) async {
    await _prefs.setBool(AppConstants.prefDnsActive, active);
  }

  // Accent Color
  String get accentColor =>
      _prefs.getString(AppConstants.prefAccentColor) ?? 'indigo';

  Future<void> setAccentColor(String color) async {
    await _prefs.setString(AppConstants.prefAccentColor, color);
  }

  // User Model (convenience)
  UserModel? getUser() {
    try {
      final json = _prefs.getString('user_data');
      if (json == null) return null;
      return UserModel.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    await _prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  // Session Model (convenience)
  SessionModel? getSession() {
    try {
      final json = _prefs.getString('session_data');
      if (json == null) return null;
      return SessionModel.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession(SessionModel? session) async {
    if (session == null) {
      await _prefs.remove('session_data');
    } else {
      await _prefs.setString('session_data', jsonEncode(session.toJson()));
    }
  }

  // Reset All
  Future<void> resetAll() async {
    await _prefs.clear();
  }
}
