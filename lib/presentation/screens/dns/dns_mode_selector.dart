import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/dns_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/dns_provider.dart';
import '../../providers/premium_provider.dart';

class DnsModeSelector extends StatelessWidget {
  const DnsModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<DnsProvider, PremiumProvider>(
      builder: (context, dns, premium, child) {
        return SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: DnsProviders.all.length,
            itemBuilder: (context, index) {
              final provider = DnsProviders.all[index];
              final isSelected = dns.selectedProviderId == provider.id;
              final isLocked = provider.isPremiumOnly && !premium.isPremium;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < DnsProviders.all.length - 1 ? 12 : 0,
                ),
                child: _DnsModeChip(
                  provider: provider,
                  isSelected: isSelected,
                  isLocked: isLocked,
                  isDark: isDark,
                  onTap: isLocked
                      ? () => _showPremiumPrompt(context)
                      : () {
                          HapticFeedback.selectionClick();
                          dns.selectProvider(provider.id);
                        },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showPremiumPrompt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upgrade to Premium to unlock this DNS mode'),
        action: SnackBarAction(
          label: 'Upgrade',
          onPressed: () {}, // Navigate to premium
        ),
      ),
    );
  }
}

class _DnsModeChip extends StatelessWidget {
  final dynamic provider;
  final bool isSelected;
  final bool isLocked;
  final bool isDark;
  final VoidCallback onTap;

  const _DnsModeChip({
    required this.provider,
    required this.isSelected,
    required this.isLocked,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? provider.color as Color
        : isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight;

    final textColor = isSelected
        ? Colors.white
        : isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight;

    final subtextColor = isSelected
        ? Colors.white.withAlpha(204)
        : isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isDark
                    ? Colors.white12
                    : Colors.black12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  _getIconData(provider.iconName as String),
                  size: 18,
                  color: isSelected ? Colors.white : provider.color as Color,
                ),
                const SizedBox(width: 6),
                Text(
                  provider.name as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (isLocked) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: isSelected ? Colors.white70 : AppColors.warning,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              provider.description as String,
              style: TextStyle(
                fontSize: 11,
                color: subtextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'shield':
        return Icons.shield_outlined;
      case 'lock':
        return Icons.lock_outline;
      case 'psychology':
        return Icons.psychology_outlined;
      case 'feather':
        return Icons.edit_outlined;
      default:
        return Icons.dns_outlined;
    }
  }
}
