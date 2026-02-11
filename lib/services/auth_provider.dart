import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required int grade,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final user = await _supabaseService.signUp(
        email: email,
        password: password,
        name: name,
        grade: grade,
      );

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        setError('Ro\'yxatdan o\'tishda xatolik yuz berdi');
        return false;
      }
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    setLoading(true);
    setError(null);

    try {
      final user = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        setError('Kirish ma\'lumotlari noto\'g\'ri');
        return false;
      }
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    setLoading(true);
    try {
      await _supabaseService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateUserPoints(int points) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      points: _currentUser!.points + points,
    );

    final success = await _supabaseService.updateUser(updatedUser);
    if (success) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  Future<void> updateUserLevel(int level) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(level: level);
    final success = await _supabaseService.updateUser(updatedUser);
    if (success) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  Future<void> updateUserCoins(int coins) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      coins: _currentUser!.coins + coins,
    );

    final success = await _supabaseService.updateUser(updatedUser);
    if (success) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  Future<void> updateUserGems(int gems) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(gems: _currentUser!.gems + gems);

    final success = await _supabaseService.updateUser(updatedUser);
    if (success) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  Future<void> updateStreak() async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      streak: _currentUser!.streak + 1,
    );

    final success = await _supabaseService.updateUser(updatedUser);
    if (success) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    final user = await _supabaseService.getUser(_currentUser!.id);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }
}
