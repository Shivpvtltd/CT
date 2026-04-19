import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dns_service.dart';
import '../constants/dns_providers.dart';

// DNS Service singleton provider
final dnsServiceProvider = Provider<DnsService>((ref) {
  final service = DnsService();
  ref.onDispose(() => service.dispose());
  return service;
});

// DNS Status stream
final dnsStatusProvider = StreamProvider<DnsStatus>((ref) {
  return ref.watch(dnsServiceProvider).statusStream;
});

// Session stream
final sessionProvider = StreamProvider<DnsSession?>((ref) {
  return ref.watch(dnsServiceProvider).sessionStream;
});

// Selected DNS provider
final selectedDnsProvider = StateNotifierProvider<SelectedDnsNotifier, DnsProvider>((ref) {
  return SelectedDnsNotifier(ref.watch(dnsServiceProvider));
});

class SelectedDnsNotifier extends StateNotifier<DnsProvider> {
  final DnsService _dnsService;

  SelectedDnsNotifier(this._dnsService) : super(_dnsService.selectedProvider);

  Future<void> select(DnsProvider provider) async {
    await _dnsService.selectProvider(provider);
    state = provider;
  }
}

// Theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<bool> {
  ThemeModeNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(SessionConfig.prefsKeyThemeMode) ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SessionConfig.prefsKeyThemeMode, state);
  }
}

// Onboarding done
final onboardingDoneProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(SessionConfig.prefsKeyOnboardingDone) ?? false;
  }

  Future<void> markDone() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SessionConfig.prefsKeyOnboardingDone, true);
  }
}
