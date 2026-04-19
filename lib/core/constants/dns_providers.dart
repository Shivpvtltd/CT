// DNS Providers Configuration
class DnsProvider {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String hostname; // For Private DNS (DoT)
  final String dohUrl;   // DNS over HTTPS fallback
  final String icon;
  final DnsStrength strength;

  const DnsProvider({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.hostname,
    required this.dohUrl,
    required this.icon,
    required this.strength,
  });
}

enum DnsStrength { lite, balanced, smart, strong }

class DnsProviders {
  static const balanced = DnsProvider(
    id: 'adguard',
    name: 'Balanced Mode',
    subtitle: 'AdGuard DNS',
    description: 'Blocks ads & trackers. Best for daily use.',
    hostname: 'dns.adguard-dns.com',
    dohUrl: 'https://dns.adguard-dns.com/dns-query',
    icon: '🛡️',
    strength: DnsStrength.balanced,
  );

  static const strong = DnsProvider(
    id: 'nextdns',
    name: 'Strong Mode',
    subtitle: 'NextDNS',
    description: 'Advanced filtering. Blocks ads, trackers & malware.',
    hostname: 'dns.nextdns.io',
    dohUrl: 'https://dns.nextdns.io/dns-query',
    icon: '⚡',
    strength: DnsStrength.strong,
  );

  static const smart = DnsProvider(
    id: 'controld',
    name: 'Smart Mode',
    subtitle: 'Control D',
    description: 'Smart filtering with category control.',
    hostname: 'freedns.controld.com',
    dohUrl: 'https://freedns.controld.com/p1',
    icon: '🧠',
    strength: DnsStrength.smart,
  );

  static const lite = DnsProvider(
    id: 'alternate',
    name: 'Lite Mode',
    subtitle: 'Alternate DNS',
    description: 'Light ad blocking. Minimal impact on speed.',
    hostname: 'dns.alternate-dns.com',
    dohUrl: 'https://dns.alternate-dns.com/dns-query',
    icon: '🌿',
    strength: DnsStrength.lite,
  );

  static const List<DnsProvider> all = [balanced, strong, smart, lite];

  // Fallback order
  static const List<DnsProvider> fallbackOrder = [balanced, smart, lite, strong];
}

// Session constants
class SessionConfig {
  static const int sessionDurationHours = 6;
  static const Duration sessionDuration = Duration(hours: 6);
  static const String prefsKeySessionStart = 'session_start_ms';
  static const String prefsKeyDnsEnabled = 'dns_enabled';
  static const String prefsKeySelectedDns = 'selected_dns_id';
  static const String prefsKeyThemeMode = 'theme_mode';
  static const String prefsKeyOnboardingDone = 'onboarding_done';
  static const String prefsKeySessionActive = 'session_active';
}

// App Info
class AppInfo {
  static const String appName = 'DNSGuard';
  static const String tagline = 'Ad Protection, Simplified';
  static const String version = '1.0.0';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.dnsguard.app';
}
