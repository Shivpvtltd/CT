import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/dns_providers.dart';
import '../../data/local/preferences_service.dart';
import '../../data/models/dns_provider_model.dart';
import '../../services/dns_service.dart';
import '../../services/session_service.dart';
import '../../services/notification_service.dart';

class DnsProvider extends ChangeNotifier {
  final PreferencesService _prefs;
  final DnsService _dnsService;
  final SessionService _sessionService;
  final NotificationService _notificationService;

  DnsProvider(this._prefs, this._dnsService, this._sessionService, this._notificationService) {
    _loadState();
  }

  // State
  DnsStatus _status = DnsStatus.off;
  String _selectedProviderId = 'adguard';
  bool _isSwitching = false;
  String? _lastError;
  Timer? _statusCheckTimer;

  DnsStatus get status => _status;
  String get selectedProviderId => _selectedProviderId;
  bool get isSwitching => _isSwitching;
  String? get lastError => _lastError;

  DnsProviderModel get selectedProvider =>
      DnsProviders.getById(_selectedProviderId);

  List<DnsProviderModel> get availableProviders => DnsProviders.all;

  bool get isProtected => _status == DnsStatus.on;
  bool get isExpired => _status == DnsStatus.disabled;

  void _loadState() {
    _selectedProviderId = _prefs.preferredDnsProvider;
    final dnsActive = _prefs.isDnsActive;
    final sessionActive = _prefs.isSessionActive;

    if (sessionActive && dnsActive) {
      _status = DnsStatus.on;
    } else if (!sessionActive && _prefs.getSession()?.isExpired == true) {
      _status = DnsStatus.disabled;
    } else {
      _status = DnsStatus.off;
    }

    _startStatusCheck();
  }

  void _startStatusCheck() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkAndUpdateStatus(),
    );
  }

  Future<void> _checkAndUpdateStatus() async {
    final session = _prefs.getSession();
    if (session != null && session.isExpired && _status == DnsStatus.on) {
      await _handleSessionExpired();
    }
  }

  Future<void> _handleSessionExpired() async {
    _status = DnsStatus.disabled;
    await _dnsService.stopDns();
    await _prefs.setDnsActive(false);
    await _prefs.setSessionActive(false);

    await _notificationService.showSessionExpiredNotification();

    notifyListeners();
  }

  Future<bool> toggleDns() async {
    HapticFeedback.mediumImpact();
    _lastError = null;

    switch (_status) {
      case DnsStatus.off:
        return await _activateDns();
      case DnsStatus.on:
        await _deactivateDns();
        return true;
      case DnsStatus.disabled:
        _lastError = 'Session expired. Reactivation required.';
        notifyListeners();
        return false;
    }
  }

  Future<bool> _activateDns() async {
    _isSwitching = true;
    notifyListeners();

    try {
      final provider = selectedProvider;
      final success = await _dnsService.startDns(provider);

      if (success) {
        _status = DnsStatus.on;
        await _prefs.setDnsActive(true);
        await _sessionService.startSession(provider.id);

        _isSwitching = false;
        notifyListeners();
        return true;
      } else {
        // Try fallback
        final fallbackSuccess = await _tryFallbackDns();
        if (fallbackSuccess) {
          _isSwitching = false;
          notifyListeners();
          return true;
        }

        _lastError = 'Failed to activate DNS. Please try again.';
        _status = DnsStatus.off;
        _isSwitching = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _lastError = 'Error: $e';
      _status = DnsStatus.off;
      _isSwitching = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _deactivateDns() async {
    _isSwitching = true;
    notifyListeners();

    try {
      await _dnsService.stopDns();
      _status = DnsStatus.off;
      await _prefs.setDnsActive(false);
      // Note: Session timer continues running in background
    } catch (e) {
      _lastError = 'Error stopping DNS: $e';
    }

    _isSwitching = false;
    notifyListeners();
  }

  Future<bool> _tryFallbackDns() async {
    final fallbackOrder = DnsProviders.fallbackOrder;
    final currentIndex = fallbackOrder.indexOf(_selectedProviderId);

    for (int i = currentIndex + 1; i < fallbackOrder.length; i++) {
      final fallbackId = fallbackOrder[i];
      final fallbackProvider = DnsProviders.getById(fallbackId);

      final success = await _dnsService.startDns(fallbackProvider);
      if (success) {
        _selectedProviderId = fallbackId;
        await _prefs.setPreferredDnsProvider(fallbackId);
        _status = DnsStatus.on;
        await _prefs.setDnsActive(true);
        return true;
      }
    }

    return false;
  }

  Future<void> selectProvider(String providerId) async {
    if (_selectedProviderId == providerId) return;

    _selectedProviderId = providerId;
    await _prefs.setPreferredDnsProvider(providerId);

    // If DNS is active, restart with new provider
    if (_status == DnsStatus.on) {
      await _dnsService.stopDns();
      final provider = DnsProviders.getById(providerId);
      await _dnsService.startDns(provider);
    }

    notifyListeners();
  }

  Future<void> forceStop() async {
    await _dnsService.stopDns();
    _status = DnsStatus.off;
    await _prefs.setDnsActive(false);
    await _prefs.setSessionActive(false);
    notifyListeners();
  }

  Future<void> reactivate() async {
    _status = DnsStatus.off;
    _lastError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }
}
