import '../../core/constants/app_constants.dart';

class SessionModel {
  final String id;
  final DateTime startTime;
  final DateTime expiryTime;
  final String dnsProviderId;
  final bool isActive;
  final bool isPremium;

  const SessionModel({
    required this.id,
    required this.startTime,
    required this.expiryTime,
    required this.dnsProviderId,
    required this.isActive,
    required this.isPremium,
  });

  factory SessionModel.create({
    required String dnsProviderId,
    bool isPremium = false,
  }) {
    final now = DateTime.now();
    return SessionModel(
      id: now.millisecondsSinceEpoch.toString(),
      startTime: now,
      expiryTime: now.add(
        const Duration(hours: AppConstants.sessionDurationHours),
      ),
      dnsProviderId: dnsProviderId,
      isActive: true,
      isPremium: isPremium,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiryTime);

  Duration get remainingTime {
    if (isExpired) return Duration.zero;
    return expiryTime.difference(DateTime.now());
  }

  double get progressPercentage {
    final totalDuration = const Duration(
      hours: AppConstants.sessionDurationHours,
    ).inSeconds;
    final remaining = remainingTime.inSeconds;
    return remaining / totalDuration;
  }

  SessionModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? expiryTime,
    String? dnsProviderId,
    bool? isActive,
    bool? isPremium,
  }) {
    return SessionModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      expiryTime: expiryTime ?? this.expiryTime,
      dnsProviderId: dnsProviderId ?? this.dnsProviderId,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'expiryTime': expiryTime.toIso8601String(),
      'dnsProviderId': dnsProviderId,
      'isActive': isActive,
      'isPremium': isPremium,
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      expiryTime: DateTime.parse(json['expiryTime'] as String),
      dnsProviderId: json['dnsProviderId'] as String,
      isActive: json['isActive'] as bool,
      isPremium: json['isPremium'] as bool,
    );
  }
}
