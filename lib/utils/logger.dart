import 'package:flutter/foundation.dart';

class AppLogger {
  static const bool _enableLogs = kDebugMode;

  static void info(String message, [String? tag]) {
    if (_enableLogs) {
      debugPrint('ℹ️ [${tag ?? 'INFO'}] $message');
    }
  }

  static void error(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
  ]) {
    if (_enableLogs) {
      debugPrint('❌ [${tag ?? 'ERROR'}] $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  static void warning(String message, [String? tag]) {
    if (_enableLogs) {
      debugPrint('⚠️ [${tag ?? 'WARNING'}] $message');
    }
  }

  static void success(String message, [String? tag]) {
    if (_enableLogs) {
      debugPrint('✅ [${tag ?? 'SUCCESS'}] $message');
    }
  }

  static void debug(String message, [String? tag]) {
    if (_enableLogs) {
      debugPrint('🐛 [${tag ?? 'DEBUG'}] $message');
    }
  }
}
