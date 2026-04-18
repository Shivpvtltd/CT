import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/secret_gesture_detector.dart';
import '../../providers/app_provider.dart';
import '../../providers/premium_provider.dart';
import 'settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showSecretActivated = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Account Section
          SettingsSection(
            title: 'Account',
            children: [
              // Subscription status
              Consumer<PremiumProvider>(
                builder: (context, premium, child) {
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: premium.isPremium
                            ? AppColors.accent.withAlpha(25)
                            : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        premium.isPremium ? Icons.workspace_premium : Icons.person_outline,
                        color: premium.isPremium ? AppColors.accent : textSecondary,
                      ),
                    ),
                    title: const Text('Subscription Status'),
                    subtitle: Text(
                      premium.isPremium ? 'Premium Active' : 'Free Plan',
                      style: TextStyle(
                        color: premium.isPremium ? AppColors.success : textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (!premium.isPremium) {
                        Navigator.pushNamed(context, '/premium');
                      }
                    },
                  );
                },
              ),
              // Restore purchases
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.restore, color: textSecondary),
                ),
                title: const Text('Restore Purchases'),
                onTap: () {
                  context.read<PremiumProvider>().restorePurchases();
                },
              ),
            ],
          ),
          // Appearance Section
          SettingsSection(
            title: 'Appearance',
            children: [
              // Theme
              Consumer<AppProvider>(
                builder: (context, app, child) {
                  return Column(
                    children: [
                      _ThemeOption(
                        title: 'Light',
                        icon: Icons.light_mode_outlined,
                        isSelected: app.themeMode == ThemeMode.light,
                        onTap: () => app.setThemeMode(ThemeMode.light),
                      ),
                      _ThemeOption(
                        title: 'Dark',
                        icon: Icons.dark_mode_outlined,
                        isSelected: app.themeMode == ThemeMode.dark,
                        onTap: () => app.setThemeMode(ThemeMode.dark),
                      ),
                      _ThemeOption(
                        title: 'System',
                        icon: Icons.tune,
                        isSelected: app.themeMode == ThemeMode.system,
                        onTap: () => app.setThemeMode(ThemeMode.system),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          // Notifications Section
          SettingsSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                secondary: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.notifications_outlined, color: textSecondary),
                ),
                title: const Text('Tool Reminders'),
                subtitle: const Text('Get reminded about scheduled tasks'),
                value: true,
                onChanged: (v) {},
              ),
              SwitchListTile(
                secondary: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.article_outlined, color: textSecondary),
                ),
                title: const Text('Weekly Summary'),
                subtitle: const Text('Receive weekly activity report'),
                value: false,
                onChanged: (v) {},
              ),
            ],
          ),
          // About Section
          SettingsSection(
            title: 'About',
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.help_outline, color: textSecondary),
                ),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () {},
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.privacy_tip_outlined, color: textSecondary),
                ),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () {},
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.description_outlined, color: textSecondary),
                ),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () {},
              ),
              // SECRET TRIGGER: Version number - triple tap to access DNS panel
              SecretTapWrapper(
                onSecretActivated: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _showSecretActivated = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _showSecretActivated = false);
                  });
                  Navigator.pushNamed(context, '/dns-panel');
                },
                requiredTaps: 3,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.info_outline, color: textSecondary),
                  ),
                  title: const Text('Version'),
                  subtitle: Text(
                    AppConstants.appVersion,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Secret activated indicator
          if (_showSecretActivated)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Advanced mode activated',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          // Danger Zone
          SettingsSection(
            title: 'Danger Zone',
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: AppColors.error),
                ),
                title: const Text(
                  'Reset All Data',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => _showResetDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will clear all app data including preferences and sessions. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset data
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : null,
      ),
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
