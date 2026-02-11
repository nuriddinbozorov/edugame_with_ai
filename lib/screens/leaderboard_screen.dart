import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bu yerda Supabase'дан yetakchilar ro'yxati yuklanadi
    // Hozircha demo ma'lumotlar
    final leaders = [
      {'name': 'Aziza Karimova', 'points': 1250, 'level': 15, 'rank': 1},
      {'name': 'Jamshid Tursunov', 'points': 1180, 'level': 14, 'rank': 2},
      {'name': 'Dilnoza Rahimova', 'points': 1050, 'level': 13, 'rank': 3},
      {'name': 'Sardor Alimov', 'points': 980, 'level': 12, 'rank': 4},
      {'name': 'Madina Yusupova', 'points': 920, 'level': 12, 'rank': 5},
      {'name': 'Bekzod Ismoilov', 'points': 880, 'level': 11, 'rank': 6},
      {'name': 'Feruza Davlatova', 'points': 840, 'level': 11, 'rank': 7},
      {'name': 'Otabek Rustamov', 'points': 800, 'level': 10, 'rank': 8},
      {'name': 'Nilufar Saidova', 'points': 760, 'level': 10, 'rank': 9},
      {'name': 'Jasur Mirzaev', 'points': 720, 'level': 9, 'rank': 10},
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.warning.withOpacity(0.2), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Column(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.leaderboard,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Eng yaxshi o\'quvchilar',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Top 3
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTopCard(leaders[1], 2),
                    const SizedBox(width: 8),
                    _buildTopCard(leaders[0], 1),
                    const SizedBox(width: 8),
                    _buildTopCard(leaders[2], 3),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Others
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.radiusLarge),
                      topRight: Radius.circular(AppSizes.radiusLarge),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    itemCount: leaders.length - 3,
                    itemBuilder: (context, index) {
                      final leader = leaders[index + 3];
                      return _buildLeaderCard(leader);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard(Map<String, dynamic> leader, int rank) {
    final heights = {1: 140.0, 2: 120.0, 3: 100.0};
    final colors = {
      1: AppColors.warning,
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };
    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};

    return Expanded(
      child: Container(
        height: heights[rank],
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors[rank]!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: colors[rank]!, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(medals[rank]!, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              leader['name'].toString().split(' ')[0],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colors[rank],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${leader['points']} ball',
              style: TextStyle(fontSize: 10, color: colors[rank]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderCard(Map<String, dynamic> leader) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${leader['rank']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              leader['name'].toString()[0],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name and level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leader['name'].toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Daraja ${leader['level']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, size: 16, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  '${leader['points']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
