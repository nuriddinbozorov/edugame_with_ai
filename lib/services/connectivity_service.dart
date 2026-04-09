import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _init();
  }

  bool _isConnected = true;
  bool _wasOffline = false; // Qayta ulanganini ko'rsatish uchun
  StreamSubscription? _subscription;

  bool get isConnected => _isConnected;
  bool get wasOffline => _wasOffline;

  void _init() async {
    try {
      // Boshlang'ich holatni tekshir
      final result = await Connectivity().checkConnectivity();
      _isConnected = _hasConnection(result);
      notifyListeners();
    } catch (_) {
      // Plugin hali yuklanmagan — default true qoladi
    }

    try {
      // O'zgarishlarni tinglash
      _subscription = Connectivity().onConnectivityChanged.listen(
        (results) {
          final connected = _hasConnection(results);
          if (connected != _isConnected) {
            if (!_isConnected && connected) {
              _wasOffline = true;
            }
            _isConnected = connected;
            notifyListeners();
          }
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }

  /// "Tiklandi" xabari ko'rsatilganidan keyin flagni tozalash
  void clearWasOffline() {
    if (_wasOffline) {
      _wasOffline = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
