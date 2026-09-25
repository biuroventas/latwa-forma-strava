import 'package:latwa_forma/l10n/app_localizations.dart';

import '../../core/providers/locale_provider.dart';

class BodyMeasurement {
  final String? id;
  final String userId;
  final String measurementType; // 'waist', 'hips', 'chest', 'arm', 'thigh'
  final double valueCm;
  final DateTime? createdAt;

  BodyMeasurement({
    this.id,
    required this.userId,
    required this.measurementType,
    required this.valueCm,
    this.createdAt,
  });

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      measurementType: json['measurement_type'] as String,
      valueCm: (json['value_cm'] as num).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'measurement_type': measurementType,
      'value_cm': valueCm,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  String get displayName {
    final l10n = lookupAppLocalizations(currentAppLocale());
    switch (measurementType) {
      case 'waist':
        return l10n.trackTypeWaist;
      case 'hips':
        return l10n.trackTypeHips;
      case 'chest':
        return l10n.trackTypeChest;
      case 'arm':
        return l10n.trackTypeArm;
      case 'thigh':
        return l10n.trackTypeThigh;
      default:
        return measurementType;
    }
  }
}
