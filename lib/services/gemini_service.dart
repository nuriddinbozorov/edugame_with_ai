import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import '../models/subject_model.dart';
import '../models/user_model.dart';
import '../models/ai_models.dart';
import '../utils/logger.dart';
import 'rate_limiter.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;
  final RateLimiter _rateLimiter = RateLimiter();
  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    try {
      final firebaseAI = FirebaseAI.googleAI(auth: FirebaseAuth.instance);
      _model = firebaseAI.generativeModel(model: 'gemini-2.5-flash');
      _initialized = true;
      AppLogger.success('GeminiService: Initialized with Firebase AI');
    } catch (e, st) {
      AppLogger.error('GeminiService: Failed to initialize Firebase AI', e, st);
      _initialized = false;
    }
  }

  bool get isInitialized => _initialized;

  /// Gemini javobidan JSON ni ajratib oladi (markdown wrapper ni tozalaydi)
  String _extractJson(String raw) {
    final jsonBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = jsonBlockRegex.firstMatch(raw);
    if (match != null) {
      return match.group(1)!.trim();
    }
    return raw.trim();
  }

  /// Fan va daraja bo'yicha savollar generatsiya qiladi
  Future<List<Question>> generateQuestions({
    required String subjectId,
    required String subjectUz,
    required int level,
    int count = 5,
  }) async {
    if (!_initialized) {
      AppLogger.warning('GeminiService: Not initialized');
      return [];
    }

    try {
      await _rateLimiter.throttle();

      final difficulty = level <= 3
          ? 'oson'
          : level <= 6
          ? "o'rta"
          : 'qiyin';
      final prompt =
          '''Sen "EduGame" ilovasining savol generatoriSan.
Fan: $subjectUz | Daraja: $level/10 ($difficulty) | Savol soni: $count

Qoidalar:
- Barcha savollar O'ZBEK tilida (Lotin yozuvi)
- Ko'p tanlovli: 4 variant, faqat 1 ta to'g'ri
- Qiyinlik darajasi $level ga mos bo'lsin
- JSON formatida qaytargin, boshqa narsa yozma
- Kirill yozuvidan foydalanma

Format:
{"questions":[{"question_text":"...","options":["A variant","B variant","C variant","D variant"],"correct_answer":"...","explanation_uz":"...","difficulty":"easy","points":${level * 10}}]}''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final text = response.text ?? '';

      final jsonStr = _extractJson(text);
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;
      final questionsJson = parsed['questions'] as List;

      return questionsJson.map((q) {
        final map = q as Map<String, dynamic>;
        return Question(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              questionsJson.indexOf(q).toString(),
          subjectId: subjectId,
          level: level,
          type: QuestionType.multipleChoice,
          questionText: map['question_text'] as String,
          options: List<String>.from(map['options'] as List),
          correctAnswer: map['correct_answer'] as String,
          explanationUz: map['explanation_uz'] as String?,
          points: map['points'] as int? ?? level * 10,
          difficulty: _parseDifficulty(map['difficulty'] as String? ?? 'easy'),
        );
      }).toList();
    } catch (e, st) {
      AppLogger.error('GeminiService: generateQuestions failed', e, st);
      return [];
    }
  }

  QuestionDifficulty _parseDifficulty(String s) {
    if (s == 'medium') return QuestionDifficulty.medium;
    if (s == 'hard') return QuestionDifficulty.hard;
    return QuestionDifficulty.easy;
  }

  /// EduBot chat javobi
  Future<String> getChatResponse({
    required String userMessage,
    required List<ChatMessage> history,
    String? subjectContext,
  }) async {
    if (!_initialized) return 'Xizmat hozir mavjud emas.';

    try {
      await _rateLimiter.throttle();

      final subjectPart = subjectContext != null
          ? " Mavzu: $subjectContext."
          : '';
      final systemPrompt =
          '''Sen "EduBot" — O'zbek maktab o'quvchilari (7-14 yosh) uchun AI o'qituvchiSan.$subjectPart
Qoidalar:
- Faqat O'ZBEK tilida (Lotin yozuvi) javob ber
- Qisqa, aniq, rag'batlantiruvchi bo'l (3-5 jumla)
- Faqat ta'lim mavzularida gapir
- Test javoblarini to'g'ridan-to'g'ri berma — yo'naltir
- Kirill yozuvidan foydalanma''';

      final chatHistory = <Content>[];
      chatHistory.add(Content.text(systemPrompt));

      for (final msg in history.take(10)) {
        if (msg.isUser) {
          chatHistory.add(Content.text(msg.content));
        } else {
          chatHistory.add(Content.model([TextPart(msg.content)]));
        }
      }
      chatHistory.add(Content.text(userMessage));

      final response = await _model!.generateContent(chatHistory);
      return response.text?.trim() ??
          'Kechirasiz, javob berishda xato yuz berdi.';
    } catch (e, st) {
      AppLogger.error('GeminiService: getChatResponse failed', e, st);
      return "Kechirasiz, hozir javob bera olmayapman. Qayta urinib ko'ring.";
    }
  }

  /// Kviz savoli uchun maslahat generatsiya qiladi
  Future<String> getHint({
    required Question question,
    required String subjectUz,
  }) async {
    if (!_initialized) return 'Maslahat hozir mavjud emas.';

    try {
      await _rateLimiter.throttle();

      final optionsStr = question.options.join(', ');
      final prompt =
          '''Savol: ${question.questionText}
Variantlar: $optionsStr
Fan: $subjectUz

Qoidalar: To'g'ri javobni AYTMA. Faqat 1-2 jumlada yo'naltir. O'ZBEK tilida yoz. Lotin yozuvida yoz.''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "Savolni diqqat bilan o'qing.";
    } catch (e, st) {
      AppLogger.error('GeminiService: getHint failed', e, st);
      return "Savolni diqqat bilan o'qing va variantlarni solishtiring.";
    }
  }

  /// Foydalanuvchi testlari bo'yicha AI tahlili
  Future<PerformanceAnalysis> analyzePerformance({
    required List<TestResult> recentResults,
    required User user,
    required List<String> subjectNames,
  }) async {
    if (!_initialized) return PerformanceAnalysis.empty();
    if (recentResults.isEmpty) return PerformanceAnalysis.empty();

    try {
      await _rateLimiter.throttle();

      final avgScore = recentResults.isEmpty
          ? 0
          : recentResults.map((r) => r.percentage).reduce((a, b) => a + b) /
                recentResults.length;

      final resultsStr = recentResults
          .take(5)
          .map(
            (r) =>
                '${r.score}/${r.totalQuestions} (${r.percentage.toStringAsFixed(0)}%)',
          )
          .join(', ');

      final prompt =
          '''O'quvchi: ${user.name}, ${user.grade ?? 7}-sinf, Daraja: ${user.level}
Oxirgi testlar natijalari: $resultsStr
O'rtacha ball: ${avgScore.toStringAsFixed(0)}%
Fanlar: ${subjectNames.join(', ')}

Quyidagi JSON formatida O'ZBEK tilida (Lotin yozuvi) tahlil bering:
{"xulosa":"2-3 jumlali umumiy baho","kuchli_tomonlar":["1-kuchli tomon"],"zaif_tomonlar":["1-zaif tomon"],"tavsiyalar":["Maslahat 1","Maslahat 2","Maslahat 3"],"motivatsiya":"Rag'batlantiruvchi gap","maqsad":"Keyingi hafta maqsad"}

Faqat JSON qaytargin.''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final jsonStr = _extractJson(text);
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;
      return PerformanceAnalysis.fromJson(parsed);
    } catch (e, st) {
      AppLogger.error('GeminiService: analyzePerformance failed', e, st);
      return PerformanceAnalysis.empty();
    }
  }

  /// Kunlik vazifa uchun savollar generatsiya qiladi
  Future<List<Map<String, dynamic>>> generateDailyChallenge({
    required String subjectUz,
    required String titleUz,
  }) async {
    if (!_initialized) return [];

    try {
      await _rateLimiter.throttle();

      final prompt =
          '''Sen "EduGame" kunlik vazifa generatoriSan.
Fan: $subjectUz | Mavzu: $titleUz | Savol soni: 5

Aralash qiyinlikdagi 5 ta savol yarat. O'ZBEK tilida (Lotin yozuvi).
Faqat JSON qaytargin:
{"questions":[{"question_text":"...","options":["A","B","C","D"],"correct_answer":"...","explanation_uz":"...","points":20}]}''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final jsonStr = _extractJson(text);
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(
        (parsed['questions'] as List).map(
          (q) => Map<String, dynamic>.from(q as Map),
        ),
      );
    } catch (e, st) {
      AppLogger.error('GeminiService: generateDailyChallenge failed', e, st);
      return [];
    }
  }
}
