import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/dns_providers.dart';
import '../../core/services/providers.dart';
import '../../shared/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider);
    final selectedDns = ref.watch(selectedDnsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700),
        ),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // DNS Section
          _SectionHeader(title: 'DNS Provider'),
          ...DnsProviders.all.map((provider) => _DnsTile(
                provider: provider,
                selected: provider.id == selectedDns.id,
                onTap: () =>
                    ref.read(selectedDnsProvider.notifier).select(provider),
              )),

          const SizedBox(height: 24),
          _SectionHeader(title: 'Appearance'),
          _SettingsTile(
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            title: 'Dark Mode',
            trailing: Switch(
              value: isDark,
              onChanged: (_) =>
                  ref.read(themeModeProvider.notifier).toggle(),
              activeColor: AppTheme.brandCyan,
            ),
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: 'DNSGuard v$_version',
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () =>
                launchUrl(Uri.parse('https://dnsguard.app/privacy')),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () =>
                launchUrl(Uri.parse('https://dnsguard.app/terms')),
          ),
          _SettingsTile(
            icon: Icons.mail_outline,
            title: 'Contact Support',
            onTap: () =>
                launchUrl(Uri.parse('mailto:support@dnsguard.app')),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'DNSGuard — Ad Protection, Simplified\nBlocks most ads. Some apps may require ads to function.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    height: 1.6,
                  ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 11,
              color: AppTheme.brandCyan,
              letterSpacing: 1.5,
            ),
      ),
    );
  }
}

class _DnsTile extends StatelessWidget {
  final DnsProvider provider;
  final bool selected;
  final VoidCallback onTap;

  const _DnsTile({
    required this.provider,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.brandCyan.withOpacity(0.08)
              : AppTheme.brandCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                selected ? AppTheme.brandCyan.withOpacity(0.4) : AppTheme.brandBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(provider.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    provider.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.brandCyan, size: 22),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.brandCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.brandBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white54, size: 22),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: subtitle != null
            ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
            : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right, color: Colors.white24)
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
