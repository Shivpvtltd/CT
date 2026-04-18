import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/dns_provider.dart';

class DnsToggleButton extends StatelessWidget {
  final VoidCallback onTap;

  const DnsToggleButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<DnsProvider>(
      builder: (context, dns, child) {
        final isOn = dns.status == DnsStatus.on;
        final isDisabled = dns.status == DnsStatus.disabled;

        Color buttonColor;
        Color iconColor;
        String label;
        IconData icon;

        if (isOn) {
          buttonColor = AppColors.success;
          iconColor = Colors.white;
          label = 'Protected';
          icon = Icons.power_settings_new;
        } else if (isDisabled) {
          buttonColor = AppColors.warning;
          iconColor = Colors.white70;
          label = 'Expired';
          icon = Icons.timer_off;
        } else {
          buttonColor = Colors.grey.shade300;
          iconColor = Colors.grey.shade600;
          label = 'Tap to Protect';
          icon = Icons.power_settings_new;
        }

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: AnimatedContainer(
            duration: AppConstants.toggleAnimationDuration,
            curve: Curves.easeInOut,
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: buttonColor,
              shape: BoxShape.circle,
              boxShadow: isOn
                  ? [
                      BoxShadow(
                        color: AppColors.success.withAlpha(77),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 150),
              scale: dns.isSwitching ? 0.9 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: iconColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
