import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/session_provider.dart';

class SessionTimer extends StatelessWidget {
  const SessionTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SessionProvider>(
      builder: (context, session, child) {
        final hasSession = session.hasActiveSession;
        final remaining = session.remainingTime;
        final isExpired = session.isExpired;

        // Calculate progress color based on remaining time
        Color progressColor;
        if (remaining.inHours >= 1) {
          progressColor = AppColors.success;
        } else if (remaining.inMinutes > 15) {
          progressColor = AppColors.warning;
        } else {
          progressColor = AppColors.error;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          child: Column(
            children: [
              // Circular progress
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background circle
                    CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 8,
                      backgroundColor: isDark
                          ? Colors.white12
                          : Colors.black12,
                      valueColor: const AlwaysStoppedAnimation(Colors.transparent),
                    ),
                    // Progress circle
                    CircularProgressIndicator(
                      value: hasSession ? session.progressPercentage : 0,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(progressColor),
                      strokeCap: StrokeCap.round,
                    ),
                    // Center text
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hasSession
                                ? remaining.formatted
                                : isExpired
                                    ? '00:00:00'
                                    : '--:--:--',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasSession
                                ? 'remaining'
                                : isExpired
                                    ? 'Session ended'
                                    : 'No active session',
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
              ),
              const SizedBox(height: 16),
              // Time indicators
              if (hasSession) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimeIndicator(
                      label: 'Hours',
                      value: remaining.inHours.toString().padLeft(2, '0'),
                      isDark: isDark,
                    ),
                    _TimeSeparator(isDark: isDark),
                    _TimeIndicator(
                      label: 'Minutes',
                      value: (remaining.inMinutes % 60).toString().padLeft(2, '0'),
                      isDark: isDark,
                    ),
                    _TimeSeparator(isDark: isDark),
                    _TimeIndicator(
                      label: 'Seconds',
                      value: (remaining.inSeconds % 60).toString().padLeft(2, '0'),
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TimeIndicator extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _TimeIndicator({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _TimeSeparator extends StatelessWidget {
  final bool isDark;

  const _TimeSeparator({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
