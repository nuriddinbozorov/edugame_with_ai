import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  UserStats? _userStats;
  AuthStatus _status = AuthStatus.initial;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  UserStats? get userStats => _userStats;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _currentUser != null;
  bool get isLoading => _status == AuthStatus.loading;

  // Set status
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    _setStatus(AuthStatus.unauthenticated);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // =====================================================
  // INITIALIZATION METHODS
  // =====================================================

  /// Ilovaning yuklanganda joriy sessiyani tekshiradi
  Future<void> checkAuthStatus() async {
    try {
      _setStatus(AuthStatus.loading);
      AppLogger.info('Auth Provider: Checking authentication status');

      final authUser = _supabaseService.client.auth.currentUser;

      if (authUser != null) {
        // Sessiya mavjud, foydalanuvchining ma'lumotlarini yukla
        AppLogger.info('Auth Provider: User session found: ${authUser.id}');

        final user = await _supabaseService.getUser(authUser.id);
        if (user != null) {
          _currentUser = user;
          await _loadUserStats();
          _setStatus(AuthStatus.authenticated);
          AppLogger.success('Auth Provider: User authenticated from session');
        } else {
          _setStatus(AuthStatus.unauthenticated);
          AppLogger.warning(
            'Auth Provider: Session exists but user not found in database',
          );
        }
      } else {
        // Sessiya yo'q, foydalanuvchi kirishmagan
        _setStatus(AuthStatus.unauthenticated);
        AppLogger.info('Auth Provider: No user session found');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Auth status check error', e, stackTrace);
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // =====================================================
  // AUTHENTICATION METHODS
  // =====================================================

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required int grade,
  }) async {
    try {
      _setStatus(AuthStatus.loading);
      clearError();

      AppLogger.info('Auth Provider: Signing up user');

      final user = await _supabaseService.signUp(
        email: email,
        password: password,
        name: name,
        grade: grade,
      );

      if (user != null) {
        _currentUser = user;
        await _loadUserStats();
        _setStatus(AuthStatus.authenticated);
        AppLogger.success('Auth Provider: Sign up successful');
        return true;
      } else {
        _setError('Ro\'yxatdan o\'tishda xatolik yuz berdi');
        AppLogger.warning('Auth Provider: Sign up failed - user is null');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Sign up error', e, stackTrace);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setStatus(AuthStatus.loading);
      clearError();

      AppLogger.info('Auth Provider: Signing in user');

      final user = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        await _loadUserStats();
        _setStatus(AuthStatus.authenticated);
        AppLogger.success('Auth Provider: Sign in successful');
        return true;
      } else {
        _setError('Kirish ma\'lumotlari noto\'g\'ri');
        AppLogger.warning('Auth Provider: Sign in failed - user is null');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Sign in error', e, stackTrace);
      _setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setStatus(AuthStatus.loading);
      AppLogger.info('Auth Provider: Signing out user');

      await _supabaseService.signOut();

      _currentUser = null;
      _userStats = null;
      _setStatus(AuthStatus.unauthenticated);

      AppLogger.success('Auth Provider: Sign out successful');
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Sign out error', e, stackTrace);
      _setError(e.toString());
    }
  }

  /// Parolni tiklash uchun elektron pochtaga havola yuboradi.
  Future<bool> resetPassword(String email) async {
    try {
      clearError();
      AppLogger.info('Auth Provider: Sending password reset to $email');
      await _supabaseService.resetPasswordForEmail(email);
      AppLogger.success('Auth Provider: Password reset email sent');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Password reset error', e, stackTrace);
      _setError(e.toString());
      return false;
    }
  }

  // =====================================================
  // USER DATA METHODS
  // =====================================================

  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    try {
      AppLogger.info('Auth Provider: Refreshing user data');

      final user = await _supabaseService.getUser(_currentUser!.id);
      if (user != null) {
        _currentUser = user;
        await _loadUserStats();
        notifyListeners();
        AppLogger.success('Auth Provider: User data refreshed');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Refresh user error', e, stackTrace);
    }
  }

  Future<void> _loadUserStats() async {
    if (_currentUser == null) return;

    try {
      AppLogger.info('Auth Provider: Loading user stats');

      _userStats = await _supabaseService.getUserStats(_currentUser!.id);
      AppLogger.success('Auth Provider: User stats loaded');
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Load stats error', e, stackTrace);
      _userStats = UserStats.empty();
    }
  }

  // =====================================================
  // UPDATE METHODS
  // =====================================================

  Future<bool> updateUserPoints(
    int points, {
    bool checkAchievements = true,
  }) async {
    if (_currentUser == null) return false;

    try {
      AppLogger.info('Auth Provider: Updating user points by $points');

      final updatedUser = _currentUser!.copyWith(
        points: _currentUser!.points + points,
        updatedAt: DateTime.now(),
      );

      final success = await _supabaseService.updateUser(updatedUser);
      if (success) {
        _currentUser = updatedUser;

        // Check for new achievements
        if (checkAchievements) {
          await _checkAndAwardAchievements();
        }

        await _loadUserStats();
        notifyListeners();
        AppLogger.success('Auth Provider: User points updated');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Update points error', e, stackTrace);
      return false;
    }
  }

  Future<bool> updateUserLevel(int level) async {
    if (_currentUser == null) return false;

    try {
      AppLogger.info('Auth Provider: Updating user level to $level');

      final updatedUser = _currentUser!.copyWith(
        level: level,
        updatedAt: DateTime.now(),
      );

      final success = await _supabaseService.updateUser(updatedUser);
      if (success) {
        _currentUser = updatedUser;
        await _loadUserStats();
        notifyListeners();
        AppLogger.success('Auth Provider: User level updated');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Update level error', e, stackTrace);
      return false;
    }
  }

  Future<bool> updateUserCoins(int coins) async {
    if (_currentUser == null) return false;

    try {
      AppLogger.info('Auth Provider: Updating user coins by $coins');

      final updatedUser = _currentUser!.copyWith(
        coins: _currentUser!.coins + coins,
        updatedAt: DateTime.now(),
      );

      final success = await _supabaseService.updateUser(updatedUser);
      if (success) {
        _currentUser = updatedUser;
        notifyListeners();
        AppLogger.success('Auth Provider: User coins updated');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Update coins error', e, stackTrace);
      return false;
    }
  }

  Future<bool> updateUserGems(int gems) async {
    if (_currentUser == null) return false;

    try {
      AppLogger.info('Auth Provider: Updating user gems by $gems');

      final updatedUser = _currentUser!.copyWith(
        gems: _currentUser!.gems + gems,
        updatedAt: DateTime.now(),
      );

      final success = await _supabaseService.updateUser(updatedUser);
      if (success) {
        _currentUser = updatedUser;
        notifyListeners();
        AppLogger.success('Auth Provider: User gems updated');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Update gems error', e, stackTrace);
      return false;
    }
  }

  Future<bool> updateStreak() async {
    if (_currentUser == null) return false;

    try {
      AppLogger.info('Auth Provider: Updating user streak');

      final updatedUser = _currentUser!.copyWith(
        streak: _currentUser!.streak + 1,
        updatedAt: DateTime.now(),
      );

      final success = await _supabaseService.updateUser(updatedUser);
      if (success) {
        _currentUser = updatedUser;
        await _loadUserStats();
        notifyListeners();
        AppLogger.success('Auth Provider: User streak updated');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Update streak error', e, stackTrace);
      return false;
    }
  }

  Future<bool> resetStreak() async {
    if (_currentUser == null) return false;

    try {
      AppLogger.info('Auth Provider: Resetting user streak');

      final updatedUser = _currentUser!.copyWith(
        streak: 0,
        updatedAt: DateTime.now(),
      );

      final success = await _supabaseService.updateUser(updatedUser);
      if (success) {
        _currentUser = updatedUser;
        notifyListeners();
        AppLogger.success('Auth Provider: User streak reset');
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Reset streak error', e, stackTrace);
      return false;
    }
  }

  // =====================================================
  // ACHIEVEMENTS
  // =====================================================

  Future<void> _checkAndAwardAchievements() async {
    if (_currentUser == null) return;

    try {
      AppLogger.info('Auth Provider: Checking achievements');
      await _supabaseService.checkAndAwardAchievements(_currentUser!.id);
      await refreshUser(); // Refresh to get updated coins/gems
      AppLogger.success('Auth Provider: Achievements checked');
    } catch (e, stackTrace) {
      AppLogger.error('Auth Provider: Check achievements error', e, stackTrace);
    }
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================

  // Calculate level from points
  static int calculateLevel(int points) {
    return (points / 100).floor() + 1;
  }

  // Check if user leveled up after adding points
  Future<bool> checkLevelUp(int newPoints) async {
    if (_currentUser == null) return false;

    final oldLevel = _currentUser!.level;
    final newLevel = calculateLevel(_currentUser!.points + newPoints);

    if (newLevel > oldLevel) {
      await updateUserLevel(newLevel);
      return true;
    }

    return false;
  }
}
