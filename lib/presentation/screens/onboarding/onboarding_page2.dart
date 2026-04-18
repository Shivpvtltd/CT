import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final tools = [
      _ToolPreview(
        icon: Icons.text_fields,
        color: Colors.blue,
        title: 'Text Formatter',
        subtitle: 'Format captions with styles',
      ),
      _ToolPreview(
        icon: Icons.tag,
        color: Colors.green,
        title: 'Hashtag Gen',
        subtitle: 'Discover trending hashtags',
      ),
      _ToolPreview(
        icon: Icons.calendar_today,
        color: Colors.purple,
        title: 'Scheduler',
        subtitle: 'Plan your content calendar',
      ),
      _ToolPreview(
        icon: Icons.bar_chart,
        color: Colors.orange,
        title: 'Analytics',
        subtitle: 'Track engagement metrics',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Essential Tools at Your Fingertips',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Everything you need to create, optimize, and grow.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Tool preview grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            physics: const NeverScrollableScrollPhysics(),
            children: tools.map((tool) => _ToolPreviewCard(tool: tool)).toList(),
          ),
        ],
      ),
    );
  }
}

class _ToolPreview {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  _ToolPreview({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

class _ToolPreviewCard extends StatelessWidget {
  final _ToolPreview tool;

  const _ToolPreviewCard({required this.tool});

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tool.icon, color: tool.color, size: 32),
          const SizedBox(height: 8),
          Text(
            tool.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            tool.subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
