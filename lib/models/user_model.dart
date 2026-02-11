class User {
  final String id;
  final String name;
  final String email;
  final int grade;
  final int level;
  final int points;
  final int coins;
  final int gems;
  final int streak;
  final DateTime createdAt;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.grade,
    this.level = 1,
    this.points = 0,
    this.coins = 0,
    this.gems = 0,
    this.streak = 0,
    required this.createdAt,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      grade: json['grade'] as int,
      level: json['level'] as int? ?? 1,
      points: json['points'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      avatarUrl: json['avatar_url'] as String?,
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
      'created_at': createdAt.toIso8601String(),
      'avatar_url': avatarUrl,
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
    DateTime? createdAt,
    String? avatarUrl,
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
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
