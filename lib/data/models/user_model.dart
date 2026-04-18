class UserModel {
  final bool isPremium;
  final DateTime? premiumExpiry;
  final int sessionsToday;
  final DateTime? lastSessionDate;
  final String preferredTheme;
  final String preferredDnsMode;

  const UserModel({
    this.isPremium = false,
    this.premiumExpiry,
    this.sessionsToday = 0,
    this.lastSessionDate,
    this.preferredTheme = 'system',
    this.preferredDnsMode = 'adguard',
  });

  bool get canStartFreeSession {
    if (isPremium) return true;
    if (lastSessionDate == null) return true;

    final now = DateTime.now();
    final lastDate = lastSessionDate!;

    // Reset daily counter if it's a new day
    if (now.year != lastDate.year ||
        now.month != lastDate.month ||
        now.day != lastDate.day) {
      return true;
    }

    return sessionsToday < 2;
  }

  int get remainingFreeSessions {
    if (isPremium) return -1; // Unlimited
    if (lastSessionDate == null) return 2;

    final now = DateTime.now();
    final lastDate = lastSessionDate!;

    if (now.year != lastDate.year ||
        now.month != lastDate.month ||
        now.day != lastDate.day) {
      return 2;
    }

    return 2 - sessionsToday;
  }

  UserModel copyWith({
    bool? isPremium,
    DateTime? premiumExpiry,
    int? sessionsToday,
    DateTime? lastSessionDate,
    String? preferredTheme,
    String? preferredDnsMode,
  }) {
    return UserModel(
      isPremium: isPremium ?? this.isPremium,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      sessionsToday: sessionsToday ?? this.sessionsToday,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      preferredTheme: preferredTheme ?? this.preferredTheme,
      preferredDnsMode: preferredDnsMode ?? this.preferredDnsMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPremium': isPremium,
      'premiumExpiry': premiumExpiry?.toIso8601String(),
      'sessionsToday': sessionsToday,
      'lastSessionDate': lastSessionDate?.toIso8601String(),
      'preferredTheme': preferredTheme,
      'preferredDnsMode': preferredDnsMode,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      isPremium: json['isPremium'] as bool? ?? false,
      premiumExpiry: json['premiumExpiry'] != null
          ? DateTime.parse(json['premiumExpiry'] as String)
          : null,
      sessionsToday: json['sessionsToday'] as int? ?? 0,
      lastSessionDate: json['lastSessionDate'] != null
          ? DateTime.parse(json['lastSessionDate'] as String)
          : null,
      preferredTheme: json['preferredTheme'] as String? ?? 'system',
      preferredDnsMode: json['preferredDnsMode'] as String? ?? 'adguard',
    );
  }
}
