import 'package:flutter_test/flutter_test.dart';
import 'package:dnsguard/core/constants/dns_providers.dart';
import 'package:dnsguard/core/services/dns_service.dart';

void main() {
  group('DNS Providers', () {
    test('All providers have valid hostnames', () {
      for (final provider in DnsProviders.all) {
        expect(provider.hostname, isNotEmpty);
        expect(provider.dohUrl, startsWith('https://'));
        expect(provider.id, isNotEmpty);
      }
    });

    test('Fallback order contains all providers', () {
      expect(DnsProviders.fallbackOrder.length, equals(DnsProviders.all.length));
    });

    test('AdGuard is balanced mode', () {
      expect(DnsProviders.balanced.strength, equals(DnsStrength.balanced));
      expect(DnsProviders.balanced.hostname, equals('dns.adguard-dns.com'));
    });

    test('NextDNS is strong mode', () {
      expect(DnsProviders.strong.strength, equals(DnsStrength.strong));
      expect(DnsProviders.strong.hostname, equals('dns.nextdns.io'));
    });

    test('Control D is smart mode', () {
      expect(DnsProviders.smart.strength, equals(DnsStrength.smart));
      expect(DnsProviders.smart.hostname, equals('freedns.controld.com'));
    });

    test('Alternate DNS is lite mode', () {
      expect(DnsProviders.lite.strength, equals(DnsStrength.lite));
      expect(DnsProviders.lite.hostname, equals('dns.alternate-dns.com'));
    });
  });

  group('DnsSession', () {
    test('Session progress is 0 at start', () {
      final session = DnsSession(
        startTime: DateTime.now(),
        provider: DnsProviders.balanced,
        isActive: true,
      );
      expect(session.progressFraction, closeTo(0.0, 0.01));
    });

    test('Session is not expired at start', () {
      final session = DnsSession(
        startTime: DateTime.now(),
        provider: DnsProviders.balanced,
        isActive: true,
      );
      expect(session.isExpired, isFalse);
    });

    test('Session is expired after 6 hours', () {
      final session = DnsSession(
        startTime: DateTime.now().subtract(const Duration(hours: 6, minutes: 1)),
        provider: DnsProviders.balanced,
        isActive: true,
      );
      expect(session.isExpired, isTrue);
    });

    test('Remaining time formats correctly', () {
      final session = DnsSession(
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        provider: DnsProviders.balanced,
        isActive: true,
      );
      // Should show ~5:00:00
      expect(session.remainingFormatted, isNotEmpty);
      expect(session.remainingFormatted, contains(':'));
    });

    test('Progress fraction is between 0 and 1', () {
      final session = DnsSession(
        startTime: DateTime.now().subtract(const Duration(hours: 3)),
        provider: DnsProviders.balanced,
        isActive: true,
      );
      expect(session.progressFraction, greaterThanOrEqualTo(0.0));
      expect(session.progressFraction, lessThanOrEqualTo(1.0));
    });
  });

  group('SessionConfig', () {
    test('Session duration is exactly 6 hours', () {
      expect(SessionConfig.sessionDuration, equals(const Duration(hours: 6)));
    });

    test('Session duration hours is 6', () {
      expect(SessionConfig.sessionDurationHours, equals(6));
    });
  });
}
