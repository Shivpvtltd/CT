import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final metrics = [
      _Metric(
        label: 'Followers',
        value: '12.5K',
        change: '+5.2%',
        isPositive: true,
        icon: Icons.people_outline,
        color: Colors.blue,
      ),
      _Metric(
        label: 'Engagement',
        value: '8.4%',
        change: '+1.2%',
        isPositive: true,
        icon: Icons.favorite_outline,
        color: Colors.red,
      ),
      _Metric(
        label: 'Views',
        value: '45.2K',
        change: '+12.8%',
        isPositive: true,
        icon: Icons.visibility_outlined,
        color: Colors.green,
      ),
      _Metric(
        label: 'Likes',
        value: '3.8K',
        change: '-2.1%',
        isPositive: false,
        icon: Icons.thumb_up_outlined,
        color: Colors.orange,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metrics grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              physics: const NeverScrollableScrollPhysics(),
              children: metrics.map((m) => _MetricCard(metric: m)).toList(),
            ),
            const SizedBox(height: 32),
            // Performance chart placeholder
            Text(
              'Performance Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Connect your accounts to see analytics',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.link),
                    label: const Text('Connect Account'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Platform breakdown
            Text(
              'Platform Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _PlatformBreakdown(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _Metric {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  _Metric({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}

class _MetricCard extends StatelessWidget {
  final _Metric metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        children: [
          Row(
            children: [
              Icon(metric.icon, color: metric.color, size: 20),
              const SizedBox(width: 8),
              Text(
                metric.label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metric.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: metric.isPositive
                  ? AppColors.success.withAlpha(25)
                  : AppColors.error.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              metric.change,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: metric.isPositive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformBreakdown extends StatelessWidget {
  final bool isDark;

  const _PlatformBreakdown({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final platforms = [
      _Platform(name: 'YouTube', percentage: 0.45, color: Colors.red),
      _Platform(name: 'Instagram', percentage: 0.30, color: Colors.purple),
      _Platform(name: 'TikTok', percentage: 0.15, color: Colors.black87),
      _Platform(name: 'Twitter', percentage: 0.10, color: Colors.blue),
    ];

    return Column(
      children: platforms.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '${(p.percentage * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: p.percentage,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation(p.color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Platform {
  final String name;
  final double percentage;
  final Color color;

  _Platform({
    required this.name,
    required this.percentage,
    required this.color,
  });
}
