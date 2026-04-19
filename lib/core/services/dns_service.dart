import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/dns_providers.dart';

enum DnsStatus { inactive, active, disabled, error }

class DnsSession {
  final DateTime startTime;
  final DnsProvider provider;
  final bool isActive;

  const DnsSession({
    required this.startTime,
    required this.provider,
    required this.isActive,
  });

  Duration get elapsed => DateTime.now().difference(startTime);
  Duration get remaining => SessionConfig.sessionDuration - elapsed;
  bool get isExpired => elapsed >= SessionConfig.sessionDuration;

  double get progressFraction {
    final total = SessionConfig.sessionDuration.inSeconds.toDouble();
    final elapsedSec = elapsed.inSeconds.toDouble();
    return (elapsedSec / total).clamp(0.0, 1.0);
  }

  String get remainingFormatted {
    final r = remaining;
    if (r.isNegative) return '0:00:00';
    final h = r.inHours;
    final m = r.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = r.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class DnsService {
  static const MethodChannel _channel =
      MethodChannel('com.dnsguard.app/dns');

  static final DnsService _instance = DnsService._();
  factory DnsService() => _instance;
  DnsService._();

  DnsSession? _session;
  Timer? _sessionTimer;
  Timer? _tickTimer;
  DnsProvider _selectedProvider = DnsProviders.balanced;

  final StreamController<DnsStatus> _statusController =
      StreamController<DnsStatus>.broadcast();
  final StreamController<DnsSession?> _sessionController =
      StreamController<DnsSession?>.broadcast();

  Stream<DnsStatus> get statusStream => _statusController.stream;
  Stream<DnsSession?> get sessionStream => _sessionController.stream;
  DnsSession? get currentSession => _session;
  DnsProvider get selectedProvider => _selectedProvider;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Restore selected provider
    final savedDnsId = prefs.getString(SessionConfig.prefsKeySelectedDns);
    if (savedDnsId != null) {
      _selectedProvider = DnsProviders.all.firstWhere(
        (p) => p.id == savedDnsId,
        orElse: () => DnsProviders.balanced,
      );
    }

    // Restore session if active
    final sessionActive = prefs.getBool(SessionConfig.prefsKeySessionActive) ?? false;
    final sessionStartMs = prefs.getInt(SessionConfig.prefsKeySessionStart);

    if (sessionActive && sessionStartMs != null) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(sessionStartMs);
      final session = DnsSession(
        startTime: startTime,
        provider: _selectedProvider,
        isActive: true,
      );
      if (!session.isExpired) {
        _session = session;
        _startSessionTimers();
        _statusController.add(DnsStatus.active);
        _sessionController.add(_session);
      } else {
        await _clearSession();
        _statusController.add(DnsStatus.disabled);
      }
    } else {
      _statusController.add(DnsStatus.inactive);
    }
  }

  Future<bool> activate() async {
    try {
      // Try to set Private DNS via Android system
      final success = await _setPlatformDns(_selectedProvider);
      if (!success) {
        // Fallback - try next provider
        for (final fallback in DnsProviders.fallbackOrder) {
          if (fallback.id != _selectedProvider.id) {
            final fallbackSuccess = await _setPlatformDns(fallback);
            if (fallbackSuccess) break;
          }
        }
      }

      final now = DateTime.now();
      _session = DnsSession(
        startTime: now,
        provider: _selectedProvider,
        isActive: true,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(SessionConfig.prefsKeySessionStart,
          now.millisecondsSinceEpoch);
      await prefs.setBool(SessionConfig.prefsKeySessionActive, true);
      await prefs.setBool(SessionConfig.prefsKeyDnsEnabled, true);

      _startSessionTimers();
      _statusController.add(DnsStatus.active);
      _sessionController.add(_session);
      return true;
    } catch (e) {
      _statusController.add(DnsStatus.error);
      return false;
    }
  }

  Future<void> deactivate() async {
    await _clearPlatformDns();
    _tickTimer?.cancel();

    // Keep session timer running, just mark DNS as off
    _statusController.add(DnsStatus.inactive);
    if (_session != null) {
      _sessionController.add(_session);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SessionConfig.prefsKeyDnsEnabled, false);
  }

  Future<void> selectProvider(DnsProvider provider) async {
    _selectedProvider = provider;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SessionConfig.prefsKeySelectedDns, provider.id);
  }

  void _startSessionTimers() {
    // Tick timer for UI countdown
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_session != null) {
        _sessionController.add(_session);
        if (_session!.isExpired) {
          _onSessionExpired();
        }
      }
    });

    // Precise expiry timer
    final remaining = _session?.remaining ?? Duration.zero;
    if (!remaining.isNegative) {
      _sessionTimer?.cancel();
      _sessionTimer = Timer(remaining, _onSessionExpired);
    }
  }

  Future<void> _onSessionExpired() async {
    _sessionTimer?.cancel();
    _tickTimer?.cancel();
    await _clearPlatformDns();
    await _clearSession();
    _statusController.add(DnsStatus.disabled);
    _sessionController.add(null);
  }

  Future<void> _clearSession() async {
    _session = null;
    _sessionTimer?.cancel();
    _tickTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SessionConfig.prefsKeySessionStart);
    await prefs.setBool(SessionConfig.prefsKeySessionActive, false);
    await prefs.setBool(SessionConfig.prefsKeyDnsEnabled, false);
  }

  Future<bool> _setPlatformDns(DnsProvider provider) async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod<bool>('setPrivateDns', {
          'hostname': provider.hostname,
        });
        return result ?? false;
      } else if (Platform.isIOS) {
        final result = await _channel.invokeMethod<bool>('setDnsOverHttps', {
          'dohUrl': provider.dohUrl,
          'hostname': provider.hostname,
        });
        return result ?? false;
      }
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> _clearPlatformDns() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('clearPrivateDns');
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('clearDns');
      }
    } on PlatformException {
      // ignore
    }
  }

  void dispose() {
    _statusController.close();
    _sessionController.close();
    _tickTimer?.cancel();
    _sessionTimer?.cancel();
  }
}
