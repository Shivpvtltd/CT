import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stats = [
      _Stat(
        value: '12',
        label: 'Tools Used',
        icon: Icons.apps,
        color: Colors.blue,
      ),
      _Stat(
        value: '48',
        label: 'Tasks Done',
        icon: Icons.check_circle,
        color: Colors.green,
      ),
      _Stat(
        value: '7',
        label: 'Day Streak',
        icon: Icons.local_fire_department,
        color: Colors.orange,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) => _StatItem(stat: stat)).toList(),
      ),
    );
  }
}

class _Stat {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  _Stat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _StatItem extends StatelessWidget {
  final _Stat stat;

  const _StatItem({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(stat.icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
        Text(
          stat.value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withAlpha(179),
          ),
        ),
      ],
    );
  }
}
