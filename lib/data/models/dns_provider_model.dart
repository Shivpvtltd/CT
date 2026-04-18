import 'package:flutter/material.dart';

class DnsProviderModel {
  final String id;
  final String name;
  final String description;
  final List<String> dnsAddresses;
  final String iconName;
  final int colorValue;
  final bool isPremiumOnly;

  const DnsProviderModel({
    required this.id,
    required this.name,
    required this.description,
    required this.dnsAddresses,
    required this.iconName,
    required this.colorValue,
    this.isPremiumOnly = false,
  });

  Color get color => Color(colorValue);

  DnsProviderModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? dnsAddresses,
    String? iconName,
    int? colorValue,
    bool? isPremiumOnly,
  }) {
    return DnsProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dnsAddresses: dnsAddresses ?? this.dnsAddresses,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      isPremiumOnly: isPremiumOnly ?? this.isPremiumOnly,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dnsAddresses': dnsAddresses,
      'iconName': iconName,
      'colorValue': colorValue,
      'isPremiumOnly': isPremiumOnly,
    };
  }

  factory DnsProviderModel.fromJson(Map<String, dynamic> json) {
    return DnsProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      dnsAddresses: List<String>.from(json['dnsAddresses'] as List),
      iconName: json['iconName'] as String,
      colorValue: json['colorValue'] as int,
      isPremiumOnly: json['isPremiumOnly'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DnsProviderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
