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
  final String iconPath;
  final String color;
  final int totalLevels;

  Subject({
    required this.id,
    required this.name,
    required this.nameUz,
    required this.type,
    required this.iconPath,
    required this.color,
    this.totalLevels = 10,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      nameUz: json['name_uz'] as String,
      type: SubjectType.values.firstWhere(
        (e) => e.toString() == 'SubjectType.${json['type']}',
        orElse: () => SubjectType.mathematics,
      ),
      iconPath: json['icon_path'] as String,
      color: json['color'] as String,
      totalLevels: json['total_levels'] as int? ?? 10,
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
    };
  }
}

enum QuestionType { multipleChoice, trueFalse, fillInBlank, matching }

class Question {
  final String id;
  final String subjectId;
  final int level;
  final QuestionType type;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final int points;
  final String? imageUrl;

  Question({
    required this.id,
    required this.subjectId,
    required this.level,
    required this.type,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.points = 10,
    this.imageUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      level: json['level'] as int,
      type: QuestionType.values.firstWhere(
        (e) => e.toString() == 'QuestionType.${json['type']}',
        orElse: () => QuestionType.multipleChoice,
      ),
      questionText: json['question_text'] as String,
      options: (json['options'] as List).map((e) => e.toString()).toList(),
      correctAnswer: json['correct_answer'] as String,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 10,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'level': level,
      'type': type.toString().split('.').last,
      'question_text': questionText,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'points': points,
      'image_url': imageUrl,
    };
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
    };
  }

  double get percentage => (correctAnswers / totalQuestions) * 100;
}

class Achievement {
  final String id;
  final String name;
  final String nameUz;
  final String description;
  final String iconPath;
  final int requiredPoints;
  final int coins;
  final int gems;

  Achievement({
    required this.id,
    required this.name,
    required this.nameUz,
    required this.description,
    required this.iconPath,
    required this.requiredPoints,
    this.coins = 0,
    this.gems = 0,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      nameUz: json['name_uz'] as String,
      description: json['description'] as String,
      iconPath: json['icon_path'] as String,
      requiredPoints: json['required_points'] as int,
      coins: json['coins'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_uz': nameUz,
      'description': description,
      'icon_path': iconPath,
      'required_points': requiredPoints,
      'coins': coins,
      'gems': gems,
    };
  }
}
