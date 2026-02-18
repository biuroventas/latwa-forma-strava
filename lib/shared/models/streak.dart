class Streak {
  final String? id;
  final String userId;
  final String streakType; // 'meals', 'water', 'activities', 'weight'
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Streak({
    this.id,
    required this.userId,
    required this.streakType,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      streakType: json['streak_type'] as String,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      lastDate: json['last_date'] != null 
          ? DateTime.parse(json['last_date'] as String)
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'streak_type': streakType,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      if (lastDate != null) 'last_date': lastDate!.toIso8601String().split('T')[0],
    };
  }

  String get displayName {
    switch (streakType) {
      case 'meals':
        return 'Posiłki';
      case 'water':
        return 'Woda';
      case 'activities':
        return 'Aktywności';
      case 'weight':
        return 'Waga';
      default:
        return streakType;
    }
  }
}
