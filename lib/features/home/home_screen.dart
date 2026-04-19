import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/dns_providers.dart';
import '../../core/services/dns_service.dart';
import '../../core/services/providers.dart';
import '../../shared/theme/app_theme.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleToggle(DnsStatus status) async {
    HapticFeedback.mediumImpact();
    final service = ref.read(dnsServiceProvider);
    if (status == DnsStatus.active) {
      await service.deactivate();
    } else if (status == DnsStatus.inactive || status == DnsStatus.error) {
      await service.activate();
    }
    // disabled → do nothing (show reactivation dialog)
  }

  void _showReactivationSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.brandCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ReactivationSheet(
        onActivate: () async {
          Navigator.pop(context);
          final service = ref.read(dnsServiceProvider);
          await service.activate();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusAsync = ref.watch(dnsStatusProvider);
    final sessionAsync = ref.watch(sessionProvider);
    final selectedDns = ref.watch(selectedDnsProvider);

    final status = statusAsync.value ?? DnsStatus.inactive;
    final session = sessionAsync.value;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient background glow
          if (status == DnsStatus.active)
            Positioned(
              top: -150,
              left: -100,
              right: -100,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Container(
                  height: 500,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.brandCyan.withOpacity(
                          0.08 + _pulseController.value * 0.05,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                _AppBar(isDark: isDark),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Status label
                        _StatusLabel(status: status),
                        const SizedBox(height: 40),

                        // Main toggle
                        _MainToggle(
                          status: status,
                          pulseController: _pulseController,
                          onTap: () {
                            if (status == DnsStatus.disabled) {
                              _showReactivationSheet();
                            } else {
                              _handleToggle(status);
                            }
                          },
                        ),
                        const SizedBox(height: 40),

                        // Session timer card
                        if (session != null || status == DnsStatus.active)
                          _SessionCard(session: session),

                        const SizedBox(height: 20),

                        // DNS Selector
                        _DnsSelector(selected: selectedDns),

                        const Spacer(),

                        // Stats row
                        _StatsRow(status: status),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends ConsumerWidget {
  final bool isDark;
  const _AppBar({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppTheme.brandCyan, Color(0xFF0066FF)],
                ).createShader(bounds),
                child: const Text(
                  'DNSGuard',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Ad Protection',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const Spacer(),
          // Theme toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: Colors.white54,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white54),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final DnsStatus status;
  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      DnsStatus.active => ('Protected', AppTheme.brandGreen),
      DnsStatus.inactive => ('Not Protected', Colors.white38),
      DnsStatus.disabled => ('Session Expired', AppTheme.warningColor),
      DnsStatus.error => ('Connection Error', AppTheme.errorColor),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: status == DnsStatus.active
                ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8)]
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    ).animate().fade(duration: 300.ms);
  }
}

class _MainToggle extends StatelessWidget {
  final DnsStatus status;
  final AnimationController pulseController;
  final VoidCallback onTap;

  const _MainToggle({
    required this.status,
    required this.pulseController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == DnsStatus.active;
    final isDisabled = status == DnsStatus.disabled;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring (active only)
          if (isActive)
            AnimatedBuilder(
              animation: pulseController,
              builder: (_, __) => Container(
                width: 220 + pulseController.value * 20,
                height: 220 + pulseController.value * 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.brandCyan.withOpacity(
                      0.3 - pulseController.value * 0.2,
                    ),
                    width: 2,
                  ),
                ),
              ),
            ),

          // Middle ring
          if (isActive)
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.brandCyan.withOpacity(0.25),
                  width: 1,
                ),
              ),
            ),

          // Main button
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00E5FF), Color(0xFF0052CC)],
                    )
                  : isDisabled
                      ? LinearGradient(
                          colors: [
                            AppTheme.disabledColor,
                            AppTheme.disabledColor.withOpacity(0.7),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.brandCard,
                            AppTheme.brandSurface,
                          ],
                        ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.brandCyan.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
              border: Border.all(
                color: isActive
                    ? AppTheme.brandCyan.withOpacity(0.5)
                    : AppTheme.brandBorder,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive
                      ? Icons.shield_rounded
                      : isDisabled
                          ? Icons.lock_clock_outlined
                          : Icons.shield_outlined,
                  size: 48,
                  color: isActive
                      ? Colors.white
                      : isDisabled
                          ? Colors.white24
                          : Colors.white38,
                ),
                const SizedBox(height: 8),
                Text(
                  isActive ? 'ON' : isDisabled ? 'EXPIRED' : 'OFF',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? Colors.white
                        : isDisabled
                            ? Colors.white24
                            : Colors.white38,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }
}

class _SessionCard extends StatelessWidget {
  final DnsSession? session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.brandCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.brandBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Session Time Remaining',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                session!.remainingFormatted,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.brandCyan,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 1.0 - session!.progressFraction,
              backgroundColor: AppTheme.brandBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandCyan),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms);
  }
}

class _DnsSelector extends ConsumerWidget {
  final DnsProvider selected;
  const _DnsSelector({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'DNS Mode',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white54,
                ),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: DnsProviders.all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final provider = DnsProviders.all[i];
              final isSelected = provider.id == selected.id;
              return GestureDetector(
                onTap: () =>
                    ref.read(selectedDnsProvider.notifier).select(provider),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 110,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.brandCyan.withOpacity(0.12)
                        : AppTheme.brandCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.brandCyan.withOpacity(0.5)
                          : AppTheme.brandBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.icon,
                          style: const TextStyle(fontSize: 22)),
                      const Spacer(),
                      Text(
                        provider.subtitle,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontSize: 11,
                              color: isSelected
                                  ? AppTheme.brandCyan
                                  : Colors.white70,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        provider.name.split(' ')[0],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final DnsStatus status;
  const _StatsRow({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
          icon: Icons.access_time_rounded,
          label: '6 Hours',
          sublabel: 'Per Session',
          active: status == DnsStatus.active,
        ),
        const SizedBox(width: 12),
        _StatItem(
          icon: Icons.block_rounded,
          label: 'Most Ads',
          sublabel: 'Blocked',
          active: status == DnsStatus.active,
        ),
        const SizedBox(width: 12),
        _StatItem(
          icon: Icons.speed_rounded,
          label: '< 1 sec',
          sublabel: 'Switch Time',
          active: status == DnsStatus.active,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool active;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.brandCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.brandBorder),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? AppTheme.brandCyan : Colors.white24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    color: active ? Colors.white : Colors.white38,
                  ),
            ),
            Text(
              sublabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactivationSheet extends StatelessWidget {
  final VoidCallback onActivate;
  const _ReactivationSheet({required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text('⏱️', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 16),
          Text(
            'Session Expired',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your 6-hour protection session has ended.\nActivate a new session to continue.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Activate button
          GestureDetector(
            onTap: onActivate,
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppTheme.brandCyan, Color(0xFF0052CC)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.brandCyan.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Activate Ad Protection (6 Hours)',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
