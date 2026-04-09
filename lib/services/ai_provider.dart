import 'package:flutter/foundation.dart';
import '../models/ai_models.dart';
import '../models/subject_model.dart';
import '../models/user_model.dart';
import 'gemini_service.dart';

class AiProvider extends ChangeNotifier {
  final GeminiService _gemini = GeminiService();

  // EduBot chat holati
  final List<ChatMessage> _chatHistory = [];
  bool _isThinking = false;
  String? _chatError;

  // Natija tahlili
  PerformanceAnalysis? _lastAnalysis;
  bool _isAnalyzing = false;

  // Maslahat holati
  String? _currentHint;
  bool _isLoadingHint = false;

  // Getters
  List<ChatMessage> get chatHistory => List.unmodifiable(_chatHistory);
  bool get isThinking => _isThinking;
  String? get chatError => _chatError;
  PerformanceAnalysis? get lastAnalysis => _lastAnalysis;
  bool get isAnalyzing => _isAnalyzing;
  String? get currentHint => _currentHint;
  bool get isLoadingHint => _isLoadingHint;

  /// EduBot ga xabar yuborish
  Future<void> sendMessage(String message, {String? subjectContext}) async {
    if (message.trim().isEmpty) return;

    _chatHistory.add(ChatMessage(role: 'user', content: message.trim()));
    _isThinking = true;
    _chatError = null;
    notifyListeners();

    final response = await _gemini.getChatResponse(
      userMessage: message.trim(),
      history: _chatHistory,
      subjectContext: subjectContext,
    );

    _chatHistory.add(ChatMessage(role: 'model', content: response));
    _isThinking = false;
    notifyListeners();
  }

  /// Suhbat tarixini tozalash
  void clearChat() {
    _chatHistory.clear();
    _chatError = null;
    _currentHint = null;
    notifyListeners();
  }

  /// Savol uchun maslahat olish
  Future<void> requestHint({
    required Question question,
    required String subjectUz,
  }) async {
    _isLoadingHint = true;
    _currentHint = null;
    notifyListeners();

    final hint = await _gemini.getHint(
      question: question,
      subjectUz: subjectUz,
    );

    _currentHint = hint;
    _isLoadingHint = false;
    notifyListeners();
  }

  void clearHint() {
    _currentHint = null;
    notifyListeners();
  }

  /// Test natijalari bo'yicha tahlil
  Future<void> analyzePerformance({
    required List<TestResult> recentResults,
    required User user,
    required List<String> subjectNames,
  }) async {
    if (recentResults.isEmpty) return;

    _isAnalyzing = true;
    _lastAnalysis = null;
    notifyListeners();

    final analysis = await _gemini.analyzePerformance(
      recentResults: recentResults,
      user: user,
      subjectNames: subjectNames,
    );

    _lastAnalysis = analysis.xulosa.isNotEmpty ? analysis : null;
    _isAnalyzing = false;
    notifyListeners();
  }

  void clearAnalysis() {
    _lastAnalysis = null;
    notifyListeners();
  }
}
