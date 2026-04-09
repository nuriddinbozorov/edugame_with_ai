import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../utils/logger.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  bool _initialized = false;

  SupabaseClient get client {
    if (_client == null || !_initialized) {
      throw Exception('Supabase is not initialized. Call initialize() first.');
    }
    return _client!;
  }

  bool get isInitialized => _initialized;

  Future<void> initialize(String url, String anonKey) async {
    try {
      if (_initialized) {
        AppLogger.warning('Supabase already initialized');
        return;
      }

      await Supabase.initialize(url: url, anonKey: anonKey);

      _client = Supabase.instance.client;
      _initialized = true;

      AppLogger.success('Supabase initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Supabase', e, stackTrace);
      rethrow;
    }
  }

  // =====================================================
  // AUTH METHODS
  // =====================================================

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required int grade,
  }) async {
    try {
      AppLogger.info('Attempting to sign up user: $email');

      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'grade': grade.toString(),
        },
      );

      if (response.user != null) {
        // Trigger public.handle_new_user() avtomatik users jadvaliga yozadi.
        // Biroq trigger async ishlashi mumkin, shuning uchun biroz kutamiz.
        await Future.delayed(const Duration(milliseconds: 500));

        final user = await getUser(response.user!.id) ??
            User(
              id: response.user!.id,
              name: name,
              email: email,
              grade: grade,
              updatedAt: DateTime.now(),
            );

        AppLogger.success('User signed up successfully: ${user.id}');
        return user;
      }

      AppLogger.warning('Sign up response user is null');
      return null;
    } on AuthException catch (e) {
      AppLogger.error('Auth error during sign up: ${e.message}', e);
      throw Exception('Ro\'yxatdan o\'tishda xatolik: ${e.message}');
    } on PostgrestException catch (e) {
      AppLogger.error('Database error during sign up: ${e.message}', e);
      throw Exception('Ma\'lumotlar bazasida xatolik: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign up', e, stackTrace);
      throw Exception('Ro\'yxatdan o\'tishda xatolik yuz berdi');
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Attempting to sign in user: $email');

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = await getUser(response.user!.id);
        AppLogger.success('User signed in successfully: ${user?.id}');
        return user;
      }

      AppLogger.warning('Sign in response user is null');
      return null;
    } on AuthException catch (e) {
      AppLogger.error('Auth error during sign in: ${e.message}', e);
      if (e.message.toLowerCase().contains('email not confirmed')) {
        throw Exception(
          'Elektron pochtangiz tasdiqlanmagan. Pochta qutingizni tekshiring.',
        );
      }
      throw Exception('Kirish xatosi: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign in', e, stackTrace);
      throw Exception('Kirishda xatolik yuz berdi');
    }
  }

  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out user');
      await client.auth.signOut();
      AppLogger.success('User signed out successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error during sign out', e, stackTrace);
      throw Exception('Chiqishda xatolik yuz berdi');
    }
  }

  /// Parolni tiklash uchun elektron pochtaga havola yuboradi.
  Future<void> resetPasswordForEmail(String email) async {
    try {
      AppLogger.info('Sending password reset email to: $email');
      await client.auth.resetPasswordForEmail(email);
      AppLogger.success('Password reset email sent successfully');
    } on AuthException catch (e) {
      AppLogger.error('Auth error during password reset: ${e.message}', e);
      throw Exception('Parolni tiklash xatosi: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('Error during password reset', e, stackTrace);
      throw Exception('Parolni tiklashda xatolik yuz berdi');
    }
  }

  // =====================================================
  // USER METHODS
  // =====================================================

  Future<User?> getUser(String userId) async {
    try {
      AppLogger.info('Fetching user: $userId');

      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      final user = User.fromJson(response);
      AppLogger.success('User fetched successfully: ${user.id}');
      return user;
    } on PostgrestException catch (e) {
      AppLogger.error('Database error fetching user: ${e.message}', e);
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching user', e, stackTrace);
      return null;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      AppLogger.info('Updating user: ${user.id}');

      await client.from('users').update(user.toJson()).eq('id', user.id);

      AppLogger.success('User updated successfully: ${user.id}');
      return true;
    } on PostgrestException catch (e) {
      AppLogger.error('Database error updating user: ${e.message}', e);
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Error updating user', e, stackTrace);
      return false;
    }
  }

  Future<UserStats> getUserStats(String userId) async {
    try {
      AppLogger.info('Fetching user stats: $userId');

      final response = await client
          .rpc('get_user_stats', params: {'user_id_param': userId})
          .single();

      final stats = UserStats.fromJson(Map<String, dynamic>.from(response));
      AppLogger.success('User stats fetched successfully');
      return stats;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching user stats', e, stackTrace);
      return UserStats.empty();
    }
  }

  // =====================================================
  // SUBJECT METHODS
  // =====================================================

  Future<List<Subject>> getSubjects() async {
    try {
      AppLogger.info('Fetching all subjects');

      final response = await client.from('subjects').select().order('name_uz');

      final subjects = (response as List)
          .map((json) => Subject.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${subjects.length} subjects');
      return subjects;
    } on PostgrestException catch (e) {
      AppLogger.error('Database error fetching subjects: ${e.message}', e);
      return [];
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching subjects', e, stackTrace);
      return [];
    }
  }

  Future<Subject?> getSubject(String subjectId) async {
    try {
      AppLogger.info('Fetching subject: $subjectId');

      final response = await client
          .from('subjects')
          .select()
          .eq('id', subjectId)
          .single();

      final subject = Subject.fromJson(response);
      AppLogger.success('Subject fetched successfully: ${subject.nameUz}');
      return subject;
    } on PostgrestException catch (e) {
      AppLogger.error('Database error fetching subject: ${e.message}', e);
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching subject', e, stackTrace);
      return null;
    }
  }

  // =====================================================
  // QUESTION METHODS
  // =====================================================

  Future<List<Question>> getQuestions({
    required String subjectId,
    required int level,
    int limit = 10,
  }) async {
    try {
      AppLogger.info('Fetching questions for subject $subjectId, level $level');

      final response = await client
          .from('questions')
          .select()
          .eq('subject_id', subjectId)
          .eq('level', level)
          .limit(limit);

      final questions = (response as List)
          .map((json) => Question.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${questions.length} questions');
      return questions;
    } on PostgrestException catch (e) {
      AppLogger.error('Database error fetching questions: ${e.message}', e);
      return [];
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching questions', e, stackTrace);
      return [];
    }
  }

  // =====================================================
  // TEST RESULT METHODS
  // =====================================================

  Future<bool> saveTestResult(TestResult result) async {
    try {
      AppLogger.info('Saving test result for user ${result.userId}');

      final data = Map<String, dynamic>.from(result.toJson())..remove('id');
      await client.from('test_results').insert(data);

      AppLogger.success('Test result saved successfully');
      return true;
    } on PostgrestException catch (e) {
      AppLogger.error('Database error saving test result: ${e.message}', e);
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Error saving test result', e, stackTrace);
      return false;
    }
  }

  /// Berilgan fan bo'yicha foydalanuvchi o'tgan eng yuqori darajani qaytaradi
  /// (score >= 60% bo'lsa o'tilgan hisoblanadi)
  Future<int> getSubjectMaxUnlockedLevel(String userId, String subjectId) async {
    try {
      final response = await client
          .from('test_results')
          .select('level, correct_answers, total_questions')
          .eq('user_id', userId)
          .eq('subject_id', subjectId);

      int maxCompleted = 0;
      for (final row in response as List) {
        final correct = (row['correct_answers'] as num).toInt();
        final total = (row['total_questions'] as num).toInt();
        final level = (row['level'] as num).toInt();
        if (total > 0 && correct / total >= 0.6 && level > maxCompleted) {
          maxCompleted = level;
        }
      }
      // O'tilgan daraja + 1 ga ruxsat (1 dan kam bo'lmaydi)
      return maxCompleted + 1;
    } catch (e) {
      return 1;
    }
  }

  Future<List<TestResult>> getUserTestResults(String userId) async {
    try {
      AppLogger.info('Fetching test results for user $userId');

      final response = await client
          .from('test_results')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);

      final results = (response as List)
          .map((json) => TestResult.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${results.length} test results');
      return results;
    } on PostgrestException catch (e) {
      AppLogger.error('Database error fetching test results: ${e.message}', e);
      return [];
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching test results', e, stackTrace);
      return [];
    }
  }

  // =====================================================
  // ACHIEVEMENT METHODS
  // =====================================================

  Future<List<Achievement>> getAchievements() async {
    try {
      AppLogger.info('Fetching all achievements');

      final response = await client
          .from('achievements')
          .select()
          .order('required_points');

      final achievements = (response as List)
          .map((json) => Achievement.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${achievements.length} achievements');
      return achievements;
    } on PostgrestException catch (e) {
      AppLogger.error('Database error fetching achievements: ${e.message}', e);
      return [];
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching achievements', e, stackTrace);
      return [];
    }
  }

  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    try {
      AppLogger.info('Fetching achievements for user $userId');

      final response = await client
          .from('user_achievements')
          .select('*, achievements(*)')
          .eq('user_id', userId);

      final userAchievements = (response as List)
          .map((json) => UserAchievement.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${userAchievements.length} user achievements');
      return userAchievements;
    } on PostgrestException catch (e) {
      AppLogger.error(
        'Database error fetching user achievements: ${e.message}',
        e,
      );
      return [];
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching user achievements', e, stackTrace);
      return [];
    }
  }

  Future<bool> unlockAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      AppLogger.info('Unlocking achievement $achievementId for user $userId');

      await client.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
      });

      AppLogger.success('Achievement unlocked successfully');
      return true;
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique constraint violation - achievement already unlocked
        AppLogger.warning('Achievement already unlocked');
        return false;
      }
      AppLogger.error('Database error unlocking achievement: ${e.message}', e);
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Error unlocking achievement', e, stackTrace);
      return false;
    }
  }

  Future<void> checkAndAwardAchievements(String userId) async {
    try {
      AppLogger.info('Checking achievements for user $userId');

      await client.rpc(
        'check_and_award_achievements',
        params: {'user_id_param': userId},
      );

      AppLogger.success('Achievements checked and awarded');
    } catch (e, stackTrace) {
      AppLogger.error('Error checking achievements', e, stackTrace);
    }
  }

  // =====================================================
  // LEADERBOARD METHODS
  // =====================================================

  Future<List<User>> getLeaderboard({int limit = 10}) async {
    try {
      AppLogger.info('Fetching leaderboard (top $limit)');

      final response = await client
          .from('users')
          .select()
          .order('points', ascending: false)
          .limit(limit);

      final users = (response as List)
          .map((json) => User.fromJson(json))
          .toList();

      AppLogger.success('Fetched leaderboard with ${users.length} users');
      return users;
    } on PostgrestException catch (e) {
      AppLogger.error('Database error fetching leaderboard: ${e.message}', e);
      return [];
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching leaderboard', e, stackTrace);
      return [];
    }
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================

  Future<int> getUserRank(String userId) async {
    try {
      final leaderboard = await getLeaderboard(limit: 1000);
      final index = leaderboard.indexWhere((user) => user.id == userId);
      return index >= 0 ? index + 1 : -1;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting user rank', e, stackTrace);
      return -1;
    }
  }
}
