import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../constants/app_constants.dart';
import '../models/subject_model.dart';
import '../services/auth_provider.dart';
import '../services/ai_provider.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';
import 'quiz_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final Subject subject;
  final int level;
  final int score;
  final int totalQuestions;
  final int correctAnswers;

  const QuizResultScreen({
    super.key,
    required this.subject,
    required this.level,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late ConfettiController _confettiController;
  bool _isPassed = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _isPassed = widget.correctAnswers / widget.totalQuestions >= 0.6;

    if (_isPassed) {
      _confettiController.play();
      _updateUserProgress();
    }
    _loadAiAnalysis();
  }

  Future<void> _loadAiAnalysis() async {
    if (!GeminiService().isInitialized) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final aiProvider = Provider.of<AiProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) return;

    final allResults = await SupabaseService().getUserTestResults(user.id);
    final recentResults = allResults.take(5).toList();

    await aiProvider.analyzePerformance(
      recentResults: recentResults,
      user: user,
      subjectNames: [widget.subject.nameUz],
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _updateUserProgress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      final result = TestResult(
        id: '',
        userId: user.id,
        subjectId: widget.subject.id,
        level: widget.level,
        score: widget.score,
        totalQuestions: widget.totalQuestions,
        correctAnswers: widget.correctAnswers,
        completedAt: DateTime.now(),
        durationSeconds: null,
      );
      await SupabaseService().saveTestResult(result);
    }
    await authProvider.updateUserPoints(widget.score);

    // Level up if passed
    if (user != null && widget.level == user.level) {
      await authProvider.updateUserLevel(widget.level + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.correctAnswers / widget.totalQuestions) * 100;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _isPassed
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.error.withOpacity(0.2),
              AppColors.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Emoji
                      Text(
                        _isPassed ? '🎉' : '😔',
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        _isPassed
                            ? AppStrings.congratulations
                            : AppStrings.tryAgain,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isPassed
                            ? 'Siz testni muvaffaqiyatli yakunladingiz!'
                            : 'Keyingi safar yaxshiroq bo\'ladi!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Score Circle
                      CircularPercentIndicator(
                        radius: 80,
                        lineWidth: 12,
                        percent: percentage / 100,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${percentage.toInt()}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${widget.correctAnswers}/${widget.totalQuestions}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        progressColor: _isPassed
                            ? AppColors.success
                            : AppColors.error,
                        backgroundColor:
                            (_isPassed ? AppColors.success : AppColors.error)
                                .withOpacity(0.2),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),

                      const SizedBox(height: 40),

                      // Stats
                      Container(
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
                        child: Column(
                          children: [
                            _buildStatRow(
                              'Fan',
                              widget.subject.nameUz,
                              Icons.book,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              'Daraja',
                              '${widget.level}',
                              Icons.trending_up,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              'Ball',
                              '${widget.score}',
                              Icons.stars,
                            ),
                            const Divider(height: 24),
                            _buildStatRow(
                              'To\'g\'ri javoblar',
                              '${widget.correctAnswers}/${widget.totalQuestions}',
                              Icons.check_circle,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // AI Tahlil kartochkasi
                      if (GeminiService().isInitialized)
                        Consumer<AiProvider>(
                          builder: (ctx, ai, _) {
                            if (ai.isAnalyzing) {
                              return Container(
                                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 12),
                                    Text('EduBot tahlil qilmoqda...', style: TextStyle(color: AppColors.textSecondary)),
                                  ],
                                ),
                              );
                            }
                            final analysis = ai.lastAnalysis;
                            if (analysis == null || analysis.xulosa.isEmpty) return const SizedBox.shrink();

                            return Container(
                              padding: const EdgeInsets.all(AppSizes.paddingLarge),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary.withOpacity(0.08), AppColors.accent.withOpacity(0.05)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32, height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(Icons.smart_toy, color: AppColors.primary, size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'EduBot Tahlili',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(analysis.xulosa, style: const TextStyle(color: AppColors.textPrimary, height: 1.5)),
                                  if (analysis.tavsiyalar.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Text('Tavsiyalar:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                    const SizedBox(height: 6),
                                    ...analysis.tavsiyalar.map((t) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                          Expanded(child: Text(t, style: const TextStyle(color: AppColors.textSecondary, height: 1.4))),
                                        ],
                                      ),
                                    )),
                                  ],
                                  if (analysis.motivatsiya.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        analysis.motivatsiya,
                                        style: const TextStyle(color: AppColors.success, fontStyle: FontStyle.italic, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium,
                                  ),
                                ),
                              ),
                              child: const Text('Bosh sahifa'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_isPassed) {
                                  // Keyingi daraja — pop to first then push new quiz
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => QuizScreen(
                                        subject: widget.subject,
                                        level: widget.level + 1,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Qayta urinish — restart same level
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuizScreen(
                                        subject: widget.subject,
                                        level: widget.level,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isPassed
                                    ? AppColors.success
                                    : AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium,
                                  ),
                                ),
                              ),
                              child: Text(
                                _isPassed ? 'Keyingi daraja' : 'Qayta urinish',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Confetti
            if (_isPassed)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 3.14 / 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
