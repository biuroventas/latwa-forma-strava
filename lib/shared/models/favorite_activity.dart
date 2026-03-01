import 'activity.dart';

class FavoriteActivity {
  final String? id;
  final String userId;
  final String name;
  final double caloriesBurned;
  final int? durationMinutes;
  final String? activityType;
  final DateTime? createdAt;

  FavoriteActivity({
    this.id,
    required this.userId,
    required this.name,
    required this.caloriesBurned,
    this.durationMinutes,
    this.activityType,
    this.createdAt,
  });

  factory FavoriteActivity.fromJson(Map<String, dynamic> json) {
    return FavoriteActivity(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      caloriesBurned: (json['calories_burned'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] as int?,
      activityType: json['activity_type'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'calories_burned': caloriesBurned,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (activityType != null) 'activity_type': activityType,
    };
  }

  Activity toActivity({DateTime? createdAt}) {
    return Activity(
      userId: userId,
      name: name,
      caloriesBurned: caloriesBurned,
      durationMinutes: durationMinutes,
      activityType: activityType,
      createdAt: createdAt,
    );
  }
}
