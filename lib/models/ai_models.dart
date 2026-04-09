class ChatMessage {
  final String role; // 'user' or 'model'
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isUser => role == 'user';
}

class PerformanceAnalysis {
  final String xulosa;
  final List<String> kuchliTomonlar;
  final List<String> zaifTomonlar;
  final List<String> tavsiyalar;
  final String motivatsiya;
  final String maqsad;

  PerformanceAnalysis({
    required this.xulosa,
    required this.kuchliTomonlar,
    required this.zaifTomonlar,
    required this.tavsiyalar,
    required this.motivatsiya,
    required this.maqsad,
  });

  factory PerformanceAnalysis.fromJson(Map<String, dynamic> json) {
    return PerformanceAnalysis(
      xulosa: json['xulosa'] as String? ?? '',
      kuchliTomonlar: List<String>.from(json['kuchli_tomonlar'] ?? []),
      zaifTomonlar: List<String>.from(json['zaif_tomonlar'] ?? []),
      tavsiyalar: List<String>.from(json['tavsiyalar'] ?? []),
      motivatsiya: json['motivatsiya'] as String? ?? '',
      maqsad: json['maqsad'] as String? ?? '',
    );
  }

  factory PerformanceAnalysis.empty() {
    return PerformanceAnalysis(
      xulosa: '',
      kuchliTomonlar: [],
      zaifTomonlar: [],
      tavsiyalar: [],
      motivatsiya: '',
      maqsad: '',
    );
  }
}

class DailyChallenge {
  final String id;
  final DateTime challengeDate;
  final String? subjectId;
  final String titleUz;
  final String? descriptionUz;
  final List<Map<String, dynamic>> questions;
  final int rewardCoins;
  final int rewardGems;
  final int rewardPoints;
  final bool isAiGenerated;

  DailyChallenge({
    required this.id,
    required this.challengeDate,
    this.subjectId,
    required this.titleUz,
    this.descriptionUz,
    required this.questions,
    this.rewardCoins = 20,
    this.rewardGems = 5,
    this.rewardPoints = 50,
    this.isAiGenerated = true,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    final questionsData = json['questions'];
    List<Map<String, dynamic>> questionsList = [];
    if (questionsData is List) {
      questionsList = questionsData
          .map((q) => Map<String, dynamic>.from(q as Map))
          .toList();
    }

    return DailyChallenge(
      id: json['id'] as String,
      challengeDate: DateTime.parse(json['challenge_date'] as String),
      subjectId: json['subject_id'] as String?,
      titleUz: json['title_uz'] as String,
      descriptionUz: json['description_uz'] as String?,
      questions: questionsList,
      rewardCoins: json['reward_coins'] as int? ?? 20,
      rewardGems: json['reward_gems'] as int? ?? 5,
      rewardPoints: json['reward_points'] as int? ?? 50,
      isAiGenerated: json['is_ai_generated'] as bool? ?? true,
    );
  }
}

class ShopItem {
  final String id;
  final String nameUz;
  final String? descriptionUz;
  final String type; // avatar, theme, hint_pack, boost
  final String? iconPath;
  final int priceCoins;
  final int priceGems;
  final Map<String, dynamic>? value;

  ShopItem({
    required this.id,
    required this.nameUz,
    this.descriptionUz,
    required this.type,
    this.iconPath,
    this.priceCoins = 0,
    this.priceGems = 0,
    this.value,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'] as String,
      nameUz: json['name_uz'] as String,
      descriptionUz: json['description_uz'] as String?,
      type: json['type'] as String,
      iconPath: json['icon_path'] as String?,
      priceCoins: json['price_coins'] as int? ?? 0,
      priceGems: json['price_gems'] as int? ?? 0,
      value: json['value'] as Map<String, dynamic>?,
    );
  }

  String get typeEmoji {
    switch (type) {
      case 'avatar':
        return '👤';
      case 'theme':
        return '🎨';
      case 'hint_pack':
        return '💡';
      case 'boost':
        return '⚡';
      default:
        return '🎁';
    }
  }
}
