import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/subject_model.dart';
import '../services/auth_provider.dart';
import 'quiz_screen.dart';

class SubjectScreen extends StatelessWidget {
  final Subject subject;

  const SubjectScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(int.parse('0xFF${subject.color}')).withOpacity(0.2),
              AppColors.background,
            ],
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
                      subject.iconPath,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.nameUz,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${subject.totalLevels} ta daraja',
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
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.currentUser;
                    final currentLevel = user?.level ?? 1;

                    return GridView.builder(
                      padding: const EdgeInsets.all(AppSizes.paddingLarge),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: AppSizes.paddingMedium,
                            crossAxisSpacing: AppSizes.paddingMedium,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: subject.totalLevels,
                      itemBuilder: (context, index) {
                        final level = index + 1;
                        final isUnlocked = level <= currentLevel;
                        final isCurrent = level == currentLevel;

                        return _buildLevelCard(
                          context,
                          level,
                          isUnlocked,
                          isCurrent,
                          subject,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context,
    int level,
    bool isUnlocked,
    bool isCurrent,
    Subject subject,
  ) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QuizScreen(subject: subject, level: level),
                ),
              );
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
              isUnlocked ? Icons.check_circle : Icons.lock,
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
          ],
        ),
      ),
    );
  }
}
