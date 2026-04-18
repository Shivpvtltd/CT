import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/dns_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dns_provider_model.dart';
import '../../providers/dns_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/premium_provider.dart';
import 'dns_toggle_button.dart';
import 'dns_mode_selector.dart';
import 'session_timer.dart';

class DnsPanelScreen extends StatelessWidget {
  const DnsPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Expanded(
                      child: Text(
                        'ShieldX DNS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Premium badge
                    Consumer<PremiumProvider>(
                      builder: (context, premium, child) {
                        if (!premium.isPremium) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Status Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _StatusCard(),
              ),
            ),
            // Main Toggle
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: DnsToggleButton(
                    onTap: () => _handleToggleTap(context),
                  ),
                ),
              ),
            ),
            // Session Timer
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SessionTimer(),
              ),
            ),
            // DNS Mode Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'DNS Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: DnsModeSelector(),
              ),
            ),
            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _QuickActionsRow(),
              ),
            ),
            // Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                child: Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatsGrid(),
              ),
            ),
            // Disclaimer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Blocks most ads. Some apps may require ads to function. No traffic is intercepted beyond DNS resolution.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  void _handleToggleTap(BuildContext context) {
    final dnsProvider = context.read<DnsProvider>();
    final premiumProvider = context.read<PremiumProvider>();

    if (dnsProvider.status == DnsStatus.disabled) {
      Navigator.pushNamed(context, '/dns-reactivate');
      return;
    }

    if (dnsProvider.status == DnsStatus.off && !premiumProvider.isPremium) {
      // Free user needs to watch ad or upgrade
      _showMonetizationSheet(context);
      return;
    }

    dnsProvider.toggleDns();
  }

  void _showMonetizationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _MonetizationBottomSheet(),
    );
  }
}

class _StatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<DnsProvider>(
      builder: (context, dns, child) {
        final isProtected = dns.status == DnsStatus.on;
        final isExpired = dns.status == DnsStatus.disabled;

        final gradient = isProtected
            ? AppColors.successGradient
            : isExpired
                ? const LinearGradient(
                    colors: [AppColors.warning, Colors.orange])
                : isDark
                    ? LinearGradient(colors: [
                        Colors.grey.shade800,
                        Colors.grey.shade900
                      ])
                    : const LinearGradient(colors: [
                        Color(0xFFE5E7EB),
                        Color(0xFFD1D5DB)
                      ]);

        final iconColor = isProtected || isExpired ? Colors.white : Colors.grey;
        final textColor = isProtected || isExpired
            ? Colors.white
            : isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                isProtected
                    ? Icons.shield
                    : isExpired
                        ? Icons.timer_off
                        : Icons.shield_outlined,
                size: 48,
                color: iconColor,
              ),
              const SizedBox(height: 12),
              Text(
                isProtected
                    ? 'Protected'
                    : isExpired
                        ? 'Session Expired'
                        : 'Not Protected',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isProtected
                    ? '${DnsProviders.getById(dns.selectedProviderId).name} DNS Active'
                    : isExpired
                        ? 'Reactivation required'
                        : 'No DNS configured',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withAlpha(204),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(icon: Icons.refresh, label: 'Refresh', onTap: () {}),
      _QuickAction(icon: Icons.list_alt, label: 'DNS Log', onTap: () {}),
      _QuickAction(icon: Icons.schedule, label: 'Auto', onTap: () {}),
      _QuickAction(icon: Icons.help_outline, label: 'Help', onTap: () {}),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((a) => _QuickActionButton(action: a)).toList(),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _QuickAction({required this.icon, required this.label, required this.onTap});
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Icon(
              action.icon,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stats = [
      _Stat(label: 'Ads Blocked', value: '2.4K', icon: Icons.block),
      _Stat(label: 'DNS Uptime', value: '99.9%', icon: Icons.timer),
      _Stat(label: 'Threats', value: '127', icon: Icons.security),
      _Stat(label: 'Data Saved', value: '156MB', icon: Icons.data_saver_on),
    ];

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      physics: const NeverScrollableScrollPhysics(),
      children: stats
          .map((s) => _StatCard(stat: s, isDark: isDark))
          .toList(),
    );
  }
}

class _Stat {
  final String label;
  final String value;
  final IconData icon;

  _Stat({required this.label, required this.value, required this.icon});
}

class _StatCard extends StatelessWidget {
  final _Stat stat;
  final bool isDark;

  const _StatCard({required this.stat, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            stat.icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonetizationBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black.withOpacity(0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.lock_outline,
              size: 48,
              color: AppColors.accent,
            ),
            const SizedBox(height: 16),
            Text(
              'Activate Ad Protection',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get 6 hours of ad-free browsing',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Show ad then activate
                  context.read<DnsProvider>().toggleDns();
                },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Watch Ad \u0026 Protect (6H)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/premium');
                },
                icon: const Icon(Icons.star_outline),
                label: const Text('Upgrade to Premium'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      ),
    );
  }
}
