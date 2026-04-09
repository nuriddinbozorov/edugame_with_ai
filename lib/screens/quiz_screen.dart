import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../models/subject_model.dart';
import '../services/supabase_service.dart';
import '../services/ai_provider.dart';
import '../services/gemini_service.dart';
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
  int _hintsUsedThisQuiz = 0;
  static const int _maxFreeHints = 2;

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
          // Supabase bo'sh bo'lsa AI dan savollar yuklaymiz
          List<Question> aiQuestions = [];
          if (GeminiService().isInitialized) {
            aiQuestions = await GeminiService().generateQuestions(
              subjectId: widget.subject.id,
              subjectUz: widget.subject.nameUz,
              level: widget.level,
            );
          }
          setState(() {
            _questions = aiQuestions.isNotEmpty ? aiQuestions : _getDemoQuestions();
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
    final type = widget.subject.type;
    final List<Map<String, dynamic>> raw;

    if (type == 'uzbekLanguage') {
      raw = [
        {'q': '"Kitob" so\'zining ko\'pligi?', 'o': ['Kitoblar', 'Kitoblon', 'Kitobcha', 'Kitoblik'], 'a': 'Kitoblar'},
        {'q': 'Qaysi so\'z ot turkumiga kiradi?', 'o': ['Yugurmoq', 'Baland', 'Daryo', 'Tez'], 'a': 'Daryo'},
        {'q': '"Do\'st" so\'zining antonimi?', 'o': ['Aka', 'Dushman', 'Qo\'shni', 'Tanish'], 'a': 'Dushman'},
        {'q': 'Qaysi so\'z fe\'l?', 'o': ['Baland', 'Tosh', 'O\'qimoq', 'Katta'], 'a': 'O\'qimoq'},
        {'q': 'O\'zbek alifbosida nechta harf bor?', 'o': ['26', '29', '30', '32'], 'a': '29'},
      ];
    } else if (type == 'english') {
      raw = [
        {'q': '"Apple" o\'zbekcha?', 'o': ['Olma', 'Nok', 'Uzum', 'Shaftoli'], 'a': 'Olma'},
        {'q': '"I ___ a student."', 'o': ['is', 'am', 'are', 'be'], 'a': 'am'},
        {'q': '"Red" o\'zbekcha?', 'o': ['Ko\'k', 'Yashil', 'Qizil', 'Sariq'], 'a': 'Qizil'},
        {'q': '"Good morning" nimani anglatadi?', 'o': ['Xayr', 'Assalomu alaykum', 'Hayrli tong', 'Rahmat'], 'a': 'Hayrli tong'},
        {'q': '"Book" o\'zbek tilida?', 'o': ['Ruchka', 'Daftar', 'Kitob', 'Qalam'], 'a': 'Kitob'},
      ];
    } else if (type == 'science') {
      raw = [
        {'q': 'Suvning kimyoviy formulasi?', 'o': ['CO2', 'H2O', 'O2', 'NaCl'], 'a': 'H2O'},
        {'q': 'Qaysi gazni nafas olamiz?', 'o': ['Azot', 'Kislorod', 'Vodorod', 'CO2'], 'a': 'Kislorod'},
        {'q': 'Quyosh sistemasida nechta sayyora bor?', 'o': ['7', '8', '9', '10'], 'a': '8'},
        {'q': 'Eng katta hayvon qaysi?', 'o': ['Fil', 'Ko\'k kit', 'Zubr', 'Timsoh'], 'a': 'Ko\'k kit'},
        {'q': 'Fotosintezda qanday gaz ajraladi?', 'o': ['CO2', 'Azot', 'Kislorod', 'Vodorod'], 'a': 'Kislorod'},
      ];
    } else if (type == 'history') {
      raw = [
        {'q': 'O\'zbekiston mustaqilligini qaysi yilda oldi?', 'o': ['1989', '1990', '1991', '1992'], 'a': '1991'},
        {'q': 'Amir Temur poytaxti?', 'o': ['Buxoro', 'Xiva', 'Samarqand', 'Toshkent'], 'a': 'Samarqand'},
        {'q': 'Birinchi jahon urushi yillari?', 'o': ['1904-1907', '1914-1918', '1918-1922', '1939-1945'], 'a': '1914-1918'},
        {'q': 'Al-Xorazmiy qaysi sohada mashhur?', 'o': ['Tibbiyot', 'Matematika va astronomiya', 'San\'at', 'Adabiyot'], 'a': 'Matematika va astronomiya'},
        {'q': 'Ibn Sino mutaxassisligi?', 'o': ['Riyoziyot', 'Tarix', 'Tibbiyot va falsafa', 'Astronomiya'], 'a': 'Tibbiyot va falsafa'},
      ];
    } else if (type == 'geography') {
      raw = [
        {'q': 'Dunyodagi eng uzun daryo?', 'o': ['Amazon', 'Nil', 'Volga', 'Yanszı'], 'a': 'Nil'},
        {'q': 'O\'zbekiston qaysi qit\'ada?', 'o': ['Afrika', 'Yevropa', 'Osiyo', 'Amerika'], 'a': 'Osiyo'},
        {'q': 'Dunyodagi eng katta okean?', 'o': ['Atlantika', 'Hind', 'Shimoliy Muz', 'Tinch'], 'a': 'Tinch'},
        {'q': 'O\'zbekiston nechta viloyatdan iborat?', 'o': ['10', '12', '14', '15'], 'a': '14'},
        {'q': 'Dunyo qit\'alari soni?', 'o': ['5', '6', '7', '8'], 'a': '7'},
      ];
    } else {
      // Matematika (default)
      raw = [
        {'q': '2 + 2 = ?', 'o': ['3', '4', '5', '6'], 'a': '4'},
        {'q': '5 × 3 = ?', 'o': ['12', '15', '18', '20'], 'a': '15'},
        {'q': '10 - 7 = ?', 'o': ['2', '3', '4', '5'], 'a': '3'},
        {'q': '20 ÷ 4 = ?', 'o': ['4', '5', '6', '7'], 'a': '5'},
        {'q': '3 × 7 = ?', 'o': ['18', '21', '24', '27'], 'a': '21'},
      ];
    }

    return raw.asMap().entries.map((e) => Question(
      id: '${e.key + 1}',
      subjectId: widget.subject.id,
      level: widget.level,
      type: QuestionType.multipleChoice,
      questionText: e.value['q'] as String,
      options: List<String>.from(e.value['o'] as List),
      correctAnswer: e.value['a'] as String,
      points: 10,
    )).toList();
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
    Navigator.pushReplacement(
      context,
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
                    // Maslahat tugmasi
                    if (GeminiService().isInitialized && !_isAnswered)
                      GestureDetector(
                        onTap: _hintsUsedThisQuiz < _maxFreeHints
                            ? () => _showHint()
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _hintsUsedThisQuiz < _maxFreeHints
                                ? AppColors.accent.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _hintsUsedThisQuiz < _maxFreeHints
                                  ? AppColors.accent
                                  : Colors.grey,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 18,
                                color: _hintsUsedThisQuiz < _maxFreeHints
                                    ? AppColors.accent
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_maxFreeHints - _hintsUsedThisQuiz}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _hintsUsedThisQuiz < _maxFreeHints
                                      ? AppColors.accent
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Future<void> _showHint() async {
    if (_hintsUsedThisQuiz >= _maxFreeHints) return;
    _timer?.cancel();
    setState(() => _hintsUsedThisQuiz++);

    final question = _questions[_currentQuestionIndex];
    final aiProvider = Provider.of<AiProvider>(context, listen: false);

    await aiProvider.requestHint(
      question: question,
      subjectUz: widget.subject.nameUz,
    );

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<AiProvider>(
          builder: (ctx, ai, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.lightbulb, color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'EduBot Maslahat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (ai.isLoadingHint)
                  const Center(child: CircularProgressIndicator())
                else
                  Text(
                    ai.currentHint ?? 'Savolni diqqat bilan o\'qing.',
                    style: const TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.5),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Tushundim'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Bottom sheet yopilgach taymerni qayta ishga tushiramiz
    if (!_isAnswered) _startTimer();
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
