import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

/// A utility class that detects the secret gesture pattern to reveal
/// the hidden DNS panel. Uses a triple-tap pattern within a time window.
class SecretGestureDetector {
  int _tapCount = 0;
  Timer? _resetTimer;
  final VoidCallback onSecretActivated;

  SecretGestureDetector({required this.onSecretActivated});

  void onTap() {
    _tapCount++;

    _resetTimer?.cancel();
    _resetTimer = Timer(
      const Duration(milliseconds: AppConstants.secretTapWindowMs),
      () => _tapCount = 0,
    );

    if (_tapCount >= AppConstants.secretTapThreshold) {
      _tapCount = 0;
      _resetTimer?.cancel();
      HapticFeedback.mediumImpact();
      onSecretActivated();
    }
  }

  void dispose() {
    _resetTimer?.cancel();
  }
}

/// Widget that wraps a child with a secret triple-tap gesture detector.
class SecretTapWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onSecretActivated;
  final int requiredTaps;

  const SecretTapWrapper({
    super.key,
    required this.child,
    required this.onSecretActivated,
    this.requiredTaps = 3,
  });

  @override
  State<SecretTapWrapper> createState() => _SecretTapWrapperState();
}

class _SecretTapWrapperState extends State<SecretTapWrapper> {
  int _tapCount = 0;
  Timer? _resetTimer;

  void _handleTap() {
    _tapCount++;

    _resetTimer?.cancel();
    _resetTimer = Timer(
      const Duration(milliseconds: AppConstants.secretTapWindowMs),
      () {
        if (mounted) {
          setState(() => _tapCount = 0);
        }
      },
    );

    if (_tapCount >= widget.requiredTaps) {
      _tapCount = 0;
      _resetTimer?.cancel();
      HapticFeedback.mediumImpact();
      widget.onSecretActivated();
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
