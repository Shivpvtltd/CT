import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/secret_gesture_detector.dart';
import 'tool_card.dart';
import 'stats_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

  // Secret gesture: tap logo 5 times to access DNS panel
  final _secretGesture = SecretGestureDetector(
    onSecretActivated: () {
      // Navigate to hidden DNS panel
    },
  );

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _onToolTap(String route) {
    Navigator.of(context).pushNamed(route);
  }

  void _openDnsPanel() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushNamed('/dns-panel');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    // Secret tap: tap logo 5 times for DNS panel
                    SecretTapWrapper(
                      onSecretActivated: _openDnsPanel,
                      requiredTaps: 5,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ShieldX',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '$_greeting',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Settings icon
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                      icon: Icon(
                        Icons.settings_outlined,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Stats Row
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: StatsRow(),
              ),
            ),
            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tools',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),
            // Tools Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildListDelegate([
                  ToolCard(
                    icon: Icons.text_fields,
                    color: Colors.blue,
                    title: 'Text Formatter',
                    subtitle: 'Format \u0026 style captions',
                    onTap: () => _onToolTap('/tools/textformatter'),
                  ),
                  ToolCard(
                    icon: Icons.tag,
                    color: Colors.green,
                    title: 'Hashtag Gen',
                    subtitle: 'Trending hashtags',
                    onTap: () => _onToolTap('/tools/hashtag'),
                  ),
                  ToolCard(
                    icon: Icons.calendar_today,
                    color: Colors.purple,
                    title: 'Scheduler',
                    subtitle: 'Content calendar',
                    onTap: () => _onToolTap('/tools/scheduler'),
                  ),
                  ToolCard(
                    icon: Icons.bar_chart,
                    color: Colors.orange,
                    title: 'Analytics',
                    subtitle: 'Engagement insights',
                    onTap: () => _onToolTap('/tools/analytics'),
                  ),
                  ToolCard(
                    icon: Icons.link,
                    color: Colors.cyan,
                    title: 'Link Shortener',
                    subtitle: 'Shorten URLs',
                    onTap: () {},
                  ),
                  ToolCard(
                    icon: Icons.dashboard_outlined,
                    color: Colors.pink,
                    title: 'Template Hub',
                    subtitle: 'Content templates',
                    onTap: () {},
                  ),
                ]),
              ),
            ),
            // Recent Activity Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _RecentActivityCard(isDark: isDark),
              ),
            ),
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined),
            activeIcon: Icon(Icons.apps),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_outlined),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final bool isDark;

  const _RecentActivityCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final activities = [
      _Activity(
        icon: Icons.text_fields,
        color: Colors.blue,
        title: 'Text formatted',
        time: '2 hours ago',
      ),
      _Activity(
        icon: Icons.tag,
        color: Colors.green,
        title: 'Hashtags generated',
        time: '5 hours ago',
      ),
    ];

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
        children: activities.asMap().entries.map((entry) {
          final activity = entry.value;
          final isLast = entry.key == activities.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: activity.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    activity.icon,
                    color: activity.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        activity.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Activity {
  final IconData icon;
  final Color color;
  final String title;
  final String time;

  _Activity({
    required this.icon,
    required this.color,
    required this.title,
    required this.time,
  });
}
