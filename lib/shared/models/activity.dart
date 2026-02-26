class Activity {
  final String? id;
  final String userId;
  final String name;
  final double caloriesBurned;
  final int? durationMinutes;
  final String? intensity;
  final DateTime? createdAt;
  /// Jeśli true, aktywność nie wlicza się do „spalone” na dashboardzie.
  final bool excludedFromBalance;

  Activity({
    this.id,
    required this.userId,
    required this.name,
    required this.caloriesBurned,
    this.durationMinutes,
    this.intensity,
    this.createdAt,
    this.excludedFromBalance = false,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      caloriesBurned: (json['calories_burned'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] as int?,
      intensity: json['intensity'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      excludedFromBalance: json['excluded_from_balance'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'calories_burned': caloriesBurned,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (intensity != null) 'intensity': intensity,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'excluded_from_balance': excludedFromBalance,
    };
  }

  /// Czy aktywność pochodzi z Garmin (po nazwie dodawanej w webhooku).
  bool get isFromGarmin => name.endsWith(' (Garmin)');

  Activity copyWith({
    String? id,
    String? userId,
    String? name,
    double? caloriesBurned,
    int? durationMinutes,
    String? intensity,
    DateTime? createdAt,
    bool? excludedFromBalance,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      createdAt: createdAt ?? this.createdAt,
      excludedFromBalance: excludedFromBalance ?? this.excludedFromBalance,
    );
  }
}
