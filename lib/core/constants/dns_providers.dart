import 'package:flutter/material.dart';
import '../../data/models/dns_provider_model.dart';

class DnsProviders {
  DnsProviders._();

  static const List<DnsProviderModel> all = [
    DnsProviderModel(
      id: 'adguard',
      name: 'Balanced',
      description: 'Best balance of speed & blocking',
      dnsAddresses: ['94.140.14.14', '94.140.15.15'],
      iconName: 'shield',
      colorValue: 0xFF3B82F6,
      isPremiumOnly: false,
    ),
    DnsProviderModel(
      id: 'nextdns',
      name: 'Strong',
      description: 'Maximum ad & tracker blocking',
      dnsAddresses: ['45.90.28.0', '45.90.30.0'],
      iconName: 'lock',
      colorValue: 0xFFEF4444,
      isPremiumOnly: true,
    ),
    DnsProviderModel(
      id: 'controld',
      name: 'Smart',
      description: 'AI-optimized filtering',
      dnsAddresses: ['76.76.2.0', '76.76.10.0'],
      iconName: 'psychology',
      colorValue: 0xFF8B5CF6,
      isPremiumOnly: true,
    ),
    DnsProviderModel(
      id: 'alternate',
      name: 'Lite',
      description: 'Minimal performance impact',
      dnsAddresses: ['198.101.242.72', '23.253.163.53'],
      iconName: 'feather',
      colorValue: 0xFF10B981,
      isPremiumOnly: false,
    ),
  ];

  static DnsProviderModel getById(String id) {
    return all.firstWhere(
      (p) => p.id == id,
      orElse: () => all.first,
    );
  }

  static DnsProviderModel get defaultProvider => all.first;

  static List<DnsProviderModel> get freeProviders =>
      all.where((p) => !p.isPremiumOnly).toList();

  static List<DnsProviderModel> get premiumProviders =>
      all.where((p) => p.isPremiumOnly).toList();

  static List<String> get fallbackOrder =>
      all.map((p) => p.id).toList();
}
