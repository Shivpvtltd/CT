import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/premium_provider.dart';
import 'pricing_card.dart';
import 'feature_list.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with close button
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Crown illustration
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 8),
              child: Text(
                'Go Premium',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Subtitle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Unlimited protection. Zero interruptions.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Feature list
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(32, 32, 32, 16),
              child: FeatureList(),
            ),
          ),
          // Pricing cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: PricingCard(
                      title: 'Monthly',
                      price: '\$${AppConstants.premiumMonthlyPrice}',
                      period: '/month',
                      isPopular: false,
                      onTap: () => _activatePremium(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PricingCard(
                      title: 'Yearly',
                      price: '\$${AppConstants.premiumYearlyPrice}',
                      period: '/year',
                      isPopular: true,
                      onTap: () => _activatePremium(context, true),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // CTA Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Consumer<PremiumProvider>(
                builder: (context, premium, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: premium.isLoading
                          ? null
                          : () => _activatePremium(context, true),
                      child: premium.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Start Free Trial'),
                    ),
                  );
                },
              ),
            ),
          ),
          // Restore purchases
          SliverToBoxAdapter(
            child: Center(
              child: TextButton(
                onPressed: () {
                  context.read<PremiumProvider>().restorePurchases();
                },
                child: const Text('Restore Purchases'),
              ),
            ),
          ),
          // Disclaimer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
              child: Text(
                'Cancel anytime. Subscription auto-renews unless cancelled 24 hours before renewal.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _activatePremium(BuildContext context, bool yearly) {
    HapticFeedback.mediumImpact();
    final provider = context.read<PremiumProvider>();
    provider.activatePremium(yearly: yearly).then((_) {
      if (provider.isPremium && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium activated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    });
  }
}
