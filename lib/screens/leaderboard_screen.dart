import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/supabase_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isListLoading = false;
  List<Map<String, dynamic>> _leaders = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isListLoading = true);
    try {
      final users = await SupabaseService().getLeaderboard(limit: 20);
      if (mounted) {
        setState(() {
          _leaders = users
              .asMap()
              .entries
              .map((e) => {
                    'name': e.value.name,
                    'points': e.value.points,
                    'level': e.value.level,
                    'rank': e.key + 1,
                  })
              .toList();
          _isListLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isListLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Top 3 faqat 3 va undan ko'p bo'lsa
    final hasTop3 = _leaders.length >= 3;
    // Ro'yxat: top3 bo'lsa 4-dan, aks holda hammasi
    final listItems = hasTop3 ? _leaders.sublist(3) : _leaders;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.warning.withOpacity(0.2),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header — har doim ko'rinadi
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.paddingLarge,
                  AppSizes.paddingLarge,
                  AppSizes.paddingLarge,
                  0,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🏆', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 4),
                          Text(
                            AppStrings.leaderboard,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Eng yaxshi o\'quvchilar',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Faqat jadval yangilanadigan refresh tugmasi
                    IconButton(
                      onPressed: _isListLoading ? null : _loadLeaderboard,
                      icon: _isListLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.refresh,
                              color: AppColors.primary,
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Top 3 podium (faqat 3+ kishi bo'lsa)
              if (hasTop3)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLarge,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildTopCard(_leaders[1], 2),
                      const SizedBox(width: 8),
                      _buildTopCard(_leaders[0], 1),
                      const SizedBox(width: 8),
                      _buildTopCard(_leaders[2], 3),
                    ],
                  ),
                ),

              if (hasTop3) const SizedBox(height: 16),

              // Jadval qismi — faqat shu qism yuklanadi
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.radiusLarge),
                      topRight: Radius.circular(AppSizes.radiusLarge),
                    ),
                  ),
                  child: _isListLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                      : listItems.isEmpty
                          ? _buildEmptyState(hasTop3)
                          : ListView.builder(
                              padding: const EdgeInsets.all(
                                AppSizes.paddingMedium,
                              ),
                              itemCount: listItems.length,
                              itemBuilder: (context, index) =>
                                  _buildLeaderCard(listItems[index]),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool hasTop3) {
    if (hasTop3) {
      // Top 3 ko'rsatilgan, ro'yxatda boshqa yo'q
      return const Center(
        child: Text(
          'Top 3 dan tashqari o\'quvchilar yo\'q',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'Hozircha o\'quvchilar yo\'q',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Birinchi bo\'ling!',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors[rank]!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: colors[rank]!, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(medals[rank]!, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
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
            const SizedBox(height: 2),
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
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              leader['name'].toString()[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
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
