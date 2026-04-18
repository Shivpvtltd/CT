import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/preferences_service.dart';

class AppProvider extends ChangeNotifier {
  final PreferencesService _prefs;
  bool _isLoading = true;
  bool _isFirstLaunch = true;
  ThemeMode _themeMode = ThemeMode.system;
  int _selectedNavIndex = 0;

  AppProvider(this._prefs) {
    _loadAppState();
  }

  bool get isLoading => _isLoading;
  bool get isFirstLaunch => _isFirstLaunch;
  ThemeMode get themeMode => _themeMode;
  int get selectedNavIndex => _selectedNavIndex;

  Future<void> _loadAppState() async {
    _isFirstLaunch = _prefs.isFirstLaunch;
    _themeMode = _parseThemeMode(_prefs.themeMode);
    _isLoading = false;
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _prefs.setFirstLaunch(false);
    _isFirstLaunch = false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final modeString = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await _prefs.setThemeMode(modeString);
    notifyListeners();
  }

  void setSystemUIOverlay(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }
}
