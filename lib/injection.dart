import 'data/local/preferences_service.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/providers/dns_provider.dart';
import 'presentation/providers/session_provider.dart';
import 'presentation/providers/premium_provider.dart';
import 'services/dns_service.dart';
import 'services/session_service.dart';
import 'services/notification_service.dart';
import 'services/monetization_service.dart';

class Injection {
  static Injection? _instance;
  static Injection get instance => _instance!;

  late final PreferencesService preferencesService;
  late final DnsService dnsService;
  late final SessionService sessionService;
  late final NotificationService notificationService;
  late final MonetizationService monetizationService;

  // Providers
  late final AppProvider appProvider;
  late final DnsProvider dnsProvider;
  late final SessionProvider sessionProvider;
  late final PremiumProvider premiumProvider;

  Injection._();

  static Future<void> initialize() async {
    if (_instance != null) return;

    _instance = Injection._();

    // Services (independent)
    _instance!.preferencesService = await PreferencesService.getInstance();
    _instance!.dnsService = DnsService();
    _instance!.notificationService = NotificationService();
    await _instance!.notificationService.initialize();
    _instance!.monetizationService = MonetizationService();

    // Services with dependencies
    _instance!.sessionService = SessionService(
      _instance!.preferencesService,
      _instance!.notificationService,
    );

    // Providers
    _instance!.appProvider = AppProvider(_instance!.preferencesService);
    _instance!.sessionProvider = SessionProvider(_instance!.preferencesService);
    _instance!.premiumProvider = PremiumProvider(_instance!.preferencesService);
    _instance!.dnsProvider = DnsProvider(
      _instance!.preferencesService,
      _instance!.dnsService,
      _instance!.sessionService,
      _instance!.notificationService,
    );

    // Initialize monetization based on premium status
    await _instance!.monetizationService.initialize(
      isPremium: _instance!.preferencesService.isPremium,
    );
  }
}
