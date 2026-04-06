enum SubjectType {
  mathematics,
  uzbekLanguage,
  english,
  science,
  history,
  geography,
}

class Subject {
  final String id;
  final String name;
  final String nameUz;
  final SubjectType type;
  final String? iconPath;
  final String? color;
  final int totalLevels;
  final String? description;
  final String? descriptionUz;
  // final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    required this.nameUz,
    required this.type,
    this.iconPath,
    this.color,
    this.totalLevels = 10,
    this.description,
    this.descriptionUz,
    // required this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      nameUz: json['name_uz'] as String,
      type: _parseSubjectType(json['type'] as String),
      iconPath: json['icon_path'] as String?,
      color: json['color'] as String?,
      totalLevels: json['total_levels'] as int? ?? 10,
      description: json['description'] as String?,
      descriptionUz: json['description_uz'] as String?,
      // createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_uz': nameUz,
      'type': type.toString().split('.').last,
      'icon_path': iconPath,
      'color': color,
      'total_levels': totalLevels,
      'description': description,
      'description_uz': descriptionUz,
      // 'created_at': createdAt.toIso8601String(),
    };
  }

  static SubjectType _parseSubjectType(String typeStr) {
    return SubjectType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => SubjectType.mathematics,
    );
  }

  // Get subject icon emoji
  String getIconEmoji() {
    switch (type) {
      case SubjectType.mathematics:
        return '🔢';
      case SubjectType.uzbekLanguage:
        return '📚';
      case SubjectType.english:
        return '🌍';
      case SubjectType.science:
        return '🔬';
      case SubjectType.history:
        return '📜';
      case SubjectType.geography:
        return '🗺️';
    }
  }
}

enum QuestionType { multipleChoice, trueFalse, fillInBlank, matching }

enum QuestionDifficulty { easy, medium, hard }

class Question {
  final String id;
  final String subjectId;
  final int level;
  final QuestionType type;
  final String questionText;
  final List<String> options; // Changed from JSONB to List<String> for TEXT[]
  final String correctAnswer;
  final String? explanation;
  final String? explanationUz;
  final int points;
  final String? imageUrl;
  final QuestionDifficulty? difficulty;
  // final DateTime createdAt;

  Question({
    required this.id,
    required this.subjectId,
    required this.level,
    required this.type,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.explanationUz,
    this.points = 10,
    this.imageUrl,
    this.difficulty,
    // required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Parse options from TEXT[] (comes as List from Supabase)
    List<String> optionsList;
    final optionsData = json['options'];

    if (optionsData is List) {
      optionsList = List<String>.from(optionsData);
    } else if (optionsData is String) {
      // Fallback: if it comes as string, parse it
      optionsList = [optionsData];
    } else {
      optionsList = [];
    }

    return Question(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      level: json['level'] as int,
      type: _parseQuestionType(json['type'] as String),
      questionText: json['question_text'] as String,
      options: optionsList,
      correctAnswer: json['correct_answer'] as String,
      explanation: json['explanation'] as String?,
      explanationUz: json['explanation_uz'] as String?,
      points: json['points'] as int? ?? 10,
      imageUrl: json['image_url'] as String?,
      difficulty: json['difficulty'] != null
          ? _parseDifficulty(json['difficulty'] as String)
          : null,
      // createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'level': level,
      'type': type.toString().split('.').last,
      'question_text': questionText,
      'options': options, // Will be converted to TEXT[] by Supabase
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'explanation_uz': explanationUz,
      'points': points,
      'image_url': imageUrl,
      'difficulty': difficulty?.toString().split('.').last,
      // 'created_at': createdAt.toIso8601String(),
    };
  }

  static QuestionType _parseQuestionType(String typeStr) {
    return QuestionType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => QuestionType.multipleChoice,
    );
  }

  static QuestionDifficulty _parseDifficulty(String difficultyStr) {
    return QuestionDifficulty.values.firstWhere(
      (e) => e.toString().split('.').last == difficultyStr,
      orElse: () => QuestionDifficulty.easy,
    );
  }

  // Check if answer is correct
  bool isCorrect(String answer) {
    return answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
  }
}

class TestResult {
  final String id;
  final String userId;
  final String subjectId;
  final int level;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime completedAt;
  final Map<String, dynamic>? answers;
  final int? durationSeconds;

  TestResult({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.level,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.completedAt,
    this.answers,
    this.durationSeconds,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subjectId: json['subject_id'] as String,
      level: json['level'] as int,
      score: json['score'] as int,
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      completedAt: DateTime.parse(json['completed_at'] as String),
      answers: json['answers'] as Map<String, dynamic>?,
      durationSeconds: json['duration_seconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject_id': subjectId,
      'level': level,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'completed_at': completedAt.toIso8601String(),
      'answers': answers,
      'duration_seconds': durationSeconds,
    };
  }

  double get percentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  bool get isPassed => percentage >= 60;

  String get grade {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }
}

class Achievement {
  final String id;
  final String name;
  final String nameUz;
  final String? description;
  final String? descriptionUz;
  final String? iconPath;
  final int requiredPoints;
  final int coins;
  final int gems;
  final String? category;
  final DateTime createdAt;

  Achievement({
    required this.id,
    required this.name,
    required this.nameUz,
    this.description,
    this.descriptionUz,
    this.iconPath,
    required this.requiredPoints,
    this.coins = 0,
    this.gems = 0,
    this.category,
    required this.createdAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      nameUz: json['name_uz'] as String,
      description: json['description'] as String?,
      descriptionUz: json['description_uz'] as String?,
      iconPath: json['icon_path'] as String?,
      requiredPoints: json['required_points'] as int,
      coins: json['coins'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_uz': nameUz,
      'description': description,
      'description_uz': descriptionUz,
      'icon_path': iconPath,
      'required_points': requiredPoints,
      'coins': coins,
      'gems': gems,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Get icon emoji based on category
  String getIconEmoji() {
    if (iconPath != null && iconPath!.isNotEmpty) return iconPath!;

    switch (category) {
      case 'points':
        return '⭐';
      case 'streak':
        return '🔥';
      case 'completion':
        return '🏆';
      case 'speed':
        return '⚡';
      case 'accuracy':
        return '🎯';
      default:
        return '🏅';
    }
  }
}

class UserAchievement {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;
  final Achievement? achievement;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    this.achievement,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      achievement: json['achievements'] != null
          ? Achievement.fromJson(json['achievements'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'achievement_id': achievementId,
      'unlocked_at': unlockedAt.toIso8601String(),
    };
  }
}
