import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user_model.dart';
import '../models/subject_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late SupabaseClient _client;

  Future<void> initialize(String url, String anonKey) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // Auth methods
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required int grade,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = User(
          id: response.user!.id,
          name: name,
          email: email,
          grade: grade,
          createdAt: DateTime.now(),
        );

        await _client.from('users').insert(user.toJson());
        return user;
      }
      return null;
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return await getUser(response.user!.id);
      }
      return null;
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // User methods
  Future<User?> getUser(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return User.fromJson(response);
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      await _client.from('users').update(user.toJson()).eq('id', user.id);
      return true;
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }

  // Subject methods
  Future<List<Subject>> getSubjects() async {
    try {
      final response = await _client.from('subjects').select().order('name_uz');
      return (response as List).map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      print('Get subjects error: $e');
      return [];
    }
  }

  Future<Subject?> getSubject(String subjectId) async {
    try {
      final response = await _client
          .from('subjects')
          .select()
          .eq('id', subjectId)
          .single();
      return Subject.fromJson(response);
    } catch (e) {
      print('Get subject error: $e');
      return null;
    }
  }

  // Question methods
  Future<List<Question>> getQuestions({
    required String subjectId,
    required int level,
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from('questions')
          .select()
          .eq('subject_id', subjectId)
          .eq('level', level)
          .limit(limit);
      return (response as List).map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      print('Get questions error: $e');
      return [];
    }
  }

  // Test result methods
  Future<bool> saveTestResult(TestResult result) async {
    try {
      await _client.from('test_results').insert(result.toJson());
      return true;
    } catch (e) {
      print('Save test result error: $e');
      return false;
    }
  }

  Future<List<TestResult>> getUserTestResults(String userId) async {
    try {
      final response = await _client
          .from('test_results')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);
      return (response as List)
          .map((json) => TestResult.fromJson(json))
          .toList();
    } catch (e) {
      print('Get test results error: $e');
      return [];
    }
  }

  // Achievement methods
  Future<List<Achievement>> getAchievements() async {
    try {
      final response = await _client
          .from('achievements')
          .select()
          .order('required_points');
      return (response as List)
          .map((json) => Achievement.fromJson(json))
          .toList();
    } catch (e) {
      print('Get achievements error: $e');
      return [];
    }
  }

  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final response = await _client
          .from('user_achievements')
          .select('achievement_id, achievements(*)')
          .eq('user_id', userId);
      return (response as List)
          .map((json) => Achievement.fromJson(json['achievements']))
          .toList();
    } catch (e) {
      print('Get user achievements error: $e');
      return [];
    }
  }

  Future<bool> unlockAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      await _client.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
        'unlocked_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Unlock achievement error: $e');
      return false;
    }
  }

  // Leaderboard methods
  Future<List<User>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .order('points', ascending: false)
          .limit(limit);
      return (response as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print('Get leaderboard error: $e');
      return [];
    }
  }
}
