import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'ShieldX';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart DNS Protection';

  // Session
  static const int sessionDurationHours = 6;
  static const int maxFreeDailySessions = 2;

  // Premium Pricing
  static const double premiumMonthlyPrice = 2.99;
  static const double premiumYearlyPrice = 19.99;

  // Timing
  static const int splashDurationMs = 2500;
  static const int secretTapThreshold = 3;
  static const int secretTapWindowMs = 800;

  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration toggleAnimationDuration = Duration(milliseconds: 400);
  static const Duration bottomSheetDuration = Duration(milliseconds: 300);

  // DNS
  static const Duration dnsTimeout = Duration(seconds: 3);

  // Notifications
  static const String sessionExpiredChannelId = 'session_expired';
  static const String sessionExpiredChannelName = 'Session Expired';
  static const String dnsAutoOffChannelId = 'dns_auto_off';
  static const String dnsAutoOffChannelName = 'Protection Disabled';
  static const String toolReminderChannelId = 'tool_reminder';
  static const String toolReminderChannelName = 'Reminders';

  // SharedPreferences Keys
  static const String prefFirstLaunch = 'first_launch';
  static const String prefTheme = 'theme_mode';
  static const String prefIsPremium = 'is_premium';
  static const String prefPremiumExpiry = 'premium_expiry';
  static const String prefSessionsToday = 'sessions_today';
  static const String prefLastSessionDate = 'last_session_date';
  static const String prefDnsProvider = 'dns_provider';
  static const String prefSessionStartTime = 'session_start_time';
  static const String prefSessionActive = 'session_active';
  static const String prefDnsActive = 'dns_active';
  static const String prefAccentColor = 'accent_color';

  // Routes
  static const String routeHome = '/';
}

enum DnsStatus { off, on, disabled }
