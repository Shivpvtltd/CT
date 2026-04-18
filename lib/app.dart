import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'injection.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/providers/dns_provider.dart';
import 'presentation/providers/session_provider.dart';
import 'presentation/providers/premium_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/dns/dns_panel_screen.dart';
import 'presentation/screens/dns/dns_reactivation_screen.dart';
import 'presentation/screens/premium/premium_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/tools/text_formatter_screen.dart';
import 'presentation/screens/tools/hashtag_generator_screen.dart';
import 'presentation/screens/tools/scheduler_screen.dart';
import 'presentation/screens/tools/analytics_screen.dart';

class CreatorToolsApp extends StatelessWidget {
  const CreatorToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Injection.instance.appProvider),
        ChangeNotifierProvider.value(value: Injection.instance.dnsProvider),
        ChangeNotifierProvider.value(value: Injection.instance.sessionProvider),
        ChangeNotifierProvider.value(value: Injection.instance.premiumProvider),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/': (context) => const HomeScreen(),
              '/dns-panel': (context) => const DnsPanelScreen(),
              '/dns-reactivate': (context) => const DnsReactivationScreen(),
              '/premium': (context) => const PremiumScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/tools/textformatter': (context) => const TextFormatterScreen(),
              '/tools/hashtag': (context) => const HashtagGeneratorScreen(),
              '/tools/scheduler': (context) => const SchedulerScreen(),
              '/tools/analytics': (context) => const AnalyticsScreen(),
            },
          );
        },
      ),
    );
  }
}
