import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../models/subject_model.dart';
import '../services/supabase_service.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Subject subject;
  final int level;

  const QuizScreen({super.key, required this.subject, required this.level});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  Timer? _timer;
  int _timeLeft = 30;
  bool _isLoading = true;
  String? _errorMessage;

  // Savollar ro'yxati
  late List<Question> _questions;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Supabase'dan savollar yukla
      final questions = await _supabaseService.getQuestions(
        subjectId: widget.subject.id,
        level: widget.level,
        limit: 10,
      );

      if (mounted) {
        if (questions.isEmpty) {
          // Demo ma'lumotlar agar Supabase bo'sh bo'lsa
          setState(() {
            _questions = _getDemoQuestions();
            _isLoading = false;
          });
        } else {
          setState(() {
            _questions = questions;
            _isLoading = false;
          });
        }
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Savollar yuklanishida xato: $e';
          _isLoading = false;
          _questions = _getDemoQuestions();
        });
      }
      debugPrint('Savollar yuklash xatosi: $e');
    }
  }

  List<Question> _getDemoQuestions() {
    return [
      Question(
        id: '1',
        subjectId: widget.subject.id,
        level: widget.level,
        type: QuestionType.multipleChoice,
        questionText: '2 + 2 = ?',
        options: ['3', '4', '5', '6'],
        correctAnswer: '4',
        points: 10,
      ),
      Question(
        id: '2',
        subjectId: widget.subject.id,
        level: widget.level,
        type: QuestionType.multipleChoice,
        questionText: '5 x 3 = ?',
        options: ['12', '15', '18', '20'],
        correctAnswer: '15',
        points: 10,
      ),
      Question(
        id: '3',
        subjectId: widget.subject.id,
        level: widget.level,
        type: QuestionType.multipleChoice,
        questionText: '10 - 7 = ?',
        options: ['2', '3', '4', '5'],
        correctAnswer: '3',
      ),
      Question(
        id: '4',
        subjectId: widget.subject.id,
        level: widget.level,
        type: QuestionType.multipleChoice,
        questionText: '20 / 4 = ?',
        options: ['4', '5', '6', '7'],
        correctAnswer: '5',
        points: 10,
      ),
      Question(
        id: '5',
        subjectId: widget.subject.id,
        level: widget.level,
        type: QuestionType.multipleChoice,
        questionText: '3 x 7 = ?',
        options: ['18', '21', '24', '27'],
        correctAnswer: '21',
        points: 10,
      ),
    ];
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _nextQuestion();
      }
    });
  }

  void _selectAnswer(String answer) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
    });

    final question = _questions[_currentQuestionIndex];
    final isCorrect = answer == question.correctAnswer;

    if (isCorrect) {
      _correctAnswers++;
      _score += question.points;
    }

    // Auto move to next question after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    _timer?.cancel();

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
        _timeLeft = 30;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          subject: widget.subject,
          level: widget.level,
          score: _score,
          totalQuestions: _questions.length,
          correctAnswers: _correctAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.background,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }

    // Error state
    if (_errorMessage != null && _questions.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.background,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Xato',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Orqaga qaytish'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _showExitDialog(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 10
                            ? AppColors.error
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_timeLeft',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Savol ${_currentQuestionIndex + 1}/${_questions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Ball: $_score',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / _questions.length,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Question
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLarge,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingLarge),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLarge,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          question.questionText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Options
                      ...question.options.map((option) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildOptionCard(option, question),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(String option, Question question) {
    final isSelected = _selectedAnswer == option;
    final isCorrect = question.correctAnswer == option;
    final showResult = _isAnswered;

    Color getColor() {
      if (!showResult) {
        return isSelected
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.cardBackground;
      }
      if (isCorrect) {
        return AppColors.success.withOpacity(0.2);
      }
      if (isSelected && !isCorrect) {
        return AppColors.error.withOpacity(0.2);
      }
      return AppColors.cardBackground;
    }

    Color getBorderColor() {
      if (!showResult) {
        return isSelected ? AppColors.primary : Colors.transparent;
      }
      if (isCorrect) {
        return AppColors.success;
      }
      if (isSelected && !isCorrect) {
        return AppColors.error;
      }
      return Colors.transparent;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(option),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: getColor(),
          border: Border.all(color: getBorderColor(), width: 2),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Row(
          children: [
            if (showResult)
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? AppColors.success : AppColors.error,
              ),
            if (showResult) const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: showResult && isCorrect
                      ? AppColors.success
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Testni tark etmoqchimisiz?'),
        content: const Text('Barcha jarayon yo\'qoladi va ball hisoblanmaydi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Chiqish',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
