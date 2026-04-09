import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/subject_model.dart';
import '../services/auth_provider.dart';
import '../services/supabase_service.dart';
import 'quiz_screen.dart';

class SubjectScreen extends StatefulWidget {
  final Subject subject;

  const SubjectScreen({super.key, required this.subject});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  int _maxUnlockedLevel = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final maxLevel = await SupabaseService().getSubjectMaxUnlockedLevel(
      userId,
      widget.subject.id,
    );

    if (mounted) {
      setState(() {
        _maxUnlockedLevel = maxLevel;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor = widget.subject.color != null
        ? Color(int.parse('0xFF${widget.subject.color}'))
        : AppColors.primary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [subjectColor.withOpacity(0.2), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      widget.subject.iconPath ?? widget.subject.getIconEmoji(),
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subject.nameUz,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${widget.subject.totalLevels} ta daraja',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Levels Grid
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSizes.paddingLarge),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: AppSizes.paddingMedium,
                              crossAxisSpacing: AppSizes.paddingMedium,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: widget.subject.totalLevels,
                        itemBuilder: (context, index) {
                          final level = index + 1;
                          final isUnlocked = level <= _maxUnlockedLevel;
                          final isCurrent = level == _maxUnlockedLevel;

                          return _buildLevelCard(level, isUnlocked, isCurrent);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(int level, bool isUnlocked, bool isCurrent) {
    return GestureDetector(
      onTap: isUnlocked
          ? () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      QuizScreen(subject: widget.subject, level: level),
                ),
              );
              // Kviz tugagach progressni yangilash
              _loadProgress();
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isCurrent ? AppColors.primary : AppColors.cardBackground)
              : AppColors.textSecondary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: (isCurrent ? AppColors.primary : Colors.black)
                        .withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnlocked
                  ? (isCurrent ? Icons.play_circle_fill : Icons.check_circle)
                  : Icons.lock,
              size: 32,
              color: isUnlocked
                  ? (isCurrent ? Colors.white : AppColors.success)
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'Daraja $level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isUnlocked
                    ? (isCurrent ? Colors.white : AppColors.textPrimary)
                    : AppColors.textSecondary,
              ),
            ),
            if (!isUnlocked)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Yopiq',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            if (isCurrent)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Hozirgi',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
