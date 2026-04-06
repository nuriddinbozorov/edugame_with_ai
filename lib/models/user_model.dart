class User {
  final String id;
  final String name;
  final String email;
  final int? grade;
  final int level;
  final int points;
  final int coins;
  final int gems;
  final int streak;
  final String? avatarUrl;
  // final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.grade,
    this.level = 1,
    this.points = 0,
    this.coins = 0,
    this.gems = 0,
    this.streak = 0,
    this.avatarUrl,
    // required this.createdAt,
    required this.updatedAt,
  });

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      grade: _toInt(json['grade']),
      level: _toInt(json['level']) ?? 1,
      points: _toInt(json['points']) ?? 0,
      coins: _toInt(json['coins']) ?? 0,
      gems: _toInt(json['gems']) ?? 0,
      streak: _toInt(json['streak']) ?? 0,
      avatarUrl: json['avatar_url'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'grade': grade,
      'level': level,
      'points': points,
      'coins': coins,
      'gems': gems,
      'streak': streak,
      'avatar_url': avatarUrl,
      // 'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? grade,
    int? level,
    int? points,
    int? coins,
    int? gems,
    int? streak,
    String? avatarUrl,
    // DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      grade: grade ?? this.grade,
      level: level ?? this.level,
      points: points ?? this.points,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      streak: streak ?? this.streak,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      // createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get user's progress to next level (0.0 to 1.0)
  double get progressToNextLevel {
    // Each level requires more points
    final requiredPoints = level * 100;
    final currentLevelPoints = points % requiredPoints;
    return currentLevelPoints / requiredPoints;
  }

  // Get user's rank title
  String get rankTitle {
    if (level >= 100) return 'Ustozlik';
    if (level >= 50) return 'Mutaxassis';
    if (level >= 25) return 'Ilg\'or';
    if (level >= 10) return 'Boshlang\'ich';
    return 'Yangi boshlovchi';
  }

  // Check if user has active streak
  bool get hasActiveStreak => streak > 0;

  // Get avatar initials
  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

// User statistics model
class UserStats {
  final int totalPoints;
  final int totalTests;
  final double avgScore;
  final int totalAchievements;
  final int currentStreak;

  UserStats({
    required this.totalPoints,
    required this.totalTests,
    required this.avgScore,
    required this.totalAchievements,
    required this.currentStreak,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      totalTests: (json['total_tests'] as num?)?.toInt() ?? 0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
      totalAchievements: (json['total_achievements'] as num?)?.toInt() ?? 0,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
    );
  }

  factory UserStats.empty() {
    return UserStats(
      totalPoints: 0,
      totalTests: 0,
      avgScore: 0.0,
      totalAchievements: 0,
      currentStreak: 0,
    );
  }
}
