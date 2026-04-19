import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/providers.dart';
import '../../shared/theme/app_theme.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      emoji: '🛡️',
      title: 'Block Ads at\nthe DNS Level',
      subtitle:
          'DNSGuard routes your queries through secure, ad-filtering DNS servers — blocking ads before they even load.',
      gradient: [Color(0xFF00E5FF), Color(0xFF0066FF)],
    ),
    _OnboardingData(
      emoji: '⚡',
      title: 'One Tap.\n6-Hour Shield.',
      subtitle:
          'Activate protection instantly. Your session runs for 6 hours, then auto-expires. No battery drain. No VPN slowdowns.',
      gradient: [Color(0xFF00FF88), Color(0xFF00B8FF)],
    ),
    _OnboardingData(
      emoji: '🔍',
      title: 'What Gets\nBlocked?',
      subtitle:
          'Ads in apps & browsers, trackers, analytics, malware domains.\n\n⚠️ Blocks most ads. Some apps may require ads to function.',
      gradient: [Color(0xFFFFB142), Color(0xFFFF4757)],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingDoneProvider.notifier).markDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.brandDark : AppTheme.lightBg;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background gradient blob
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _pages[_currentPage].gradient[0].withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
                  ),
                ),

                // Dots & button
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          final active = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: active
                                  ? _pages[_currentPage].gradient[0]
                                  : Colors.white24,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // CTA Button
                      _currentPage == _pages.length - 1
                          ? _GlowButton(
                              label: 'Get Protected',
                              gradient: _pages[_currentPage].gradient,
                              onTap: _finish,
                            )
                          : _GlowButton(
                              label: 'Next',
                              gradient: _pages[_currentPage].gradient,
                              onTap: () {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                    ],
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

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji icon with glow
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  data.gradient[0].withOpacity(0.2),
                  data.gradient[1].withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: data.gradient[0].withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 56)),
            ),
          )
              .animate()
              .scale(duration: 500.ms, curve: Curves.easeOut)
              .fade(duration: 400.ms),
          const SizedBox(height: 40),

          // Title
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: data.gradient,
            ).createShader(bounds),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    height: 1.15,
                  ),
            ),
          )
              .animate()
              .slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOut)
              .fade(duration: 500.ms, delay: 100.ms),
          const SizedBox(height: 20),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white60,
                  height: 1.6,
                ),
          )
              .animate()
              .fade(duration: 500.ms, delay: 200.ms),
        ],
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _GlowButton({
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: gradient),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
