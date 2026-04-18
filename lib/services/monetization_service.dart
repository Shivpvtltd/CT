import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MonetizationService {
  static final MonetizationService _instance = MonetizationService._internal();
  factory MonetizationService() => _instance;
  MonetizationService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;
  bool _isPremium = false;

  bool get isPremium => _isPremium;
  bool get isAdLoading => _isAdLoading;
  bool get isAdReady => _rewardedAd != null;

  /// Initialize the monetization service
  Future<void> initialize({bool isPremium = false}) async {
    _isPremium = isPremium;

    if (!isPremium) {
      await _loadRewardedAd();
    }
  }

  /// Set premium status
  void setPremium(bool premium) {
    _isPremium = premium;
    if (premium) {
      _rewardedAd?.dispose();
      _rewardedAd = null;
    }
  }

  /// Load a rewarded ad
  Future<void> _loadRewardedAd() async {
    if (_isPremium || _isAdLoading || _rewardedAd != null) return;

    _isAdLoading = true;

    await RewardedAd.load(
      adUnitId: _getRewardedAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isAdLoading = false;
          debugPrint('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  /// Show rewarded ad and return whether user completed watching
  Future<bool> showRewardedAd() async {
    if (_isPremium) return true;

    if (_rewardedAd == null) {
      await _loadRewardedAd();
      if (_rewardedAd == null) {
        // Ad failed to load, grant reward anyway for good UX
        return true;
      }
    }

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd(); // Preload next ad
        if (!completer.isCompleted) {
          completer.complete(false); // User dismissed without reward
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        if (!completer.isCompleted) {
          completer.complete(true); // Grant on error for UX
        }
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
    );

    return completer.future;
  }

  /// Get the appropriate rewarded ad unit ID
  String _getRewardedAdUnitId() {
    // Use test ad unit ID for development
    return 'ca-app-pub-3940256099942544/5224354917';
  }

  /// Dispose resources
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
