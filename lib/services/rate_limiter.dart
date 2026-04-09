import 'dart:collection';

/// Gemini bepul tier uchun sliding window rate limiter
/// Limit: 15 so'rov/daqiqa
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final Queue<DateTime> _requestTimes = Queue();

  RateLimiter({
    this.maxRequests = 15,
    this.window = const Duration(minutes: 1),
  });

  /// API chaqiruvidan oldin chaqiring — agar limit to'lsa kutadi
  Future<void> throttle() async {
    while (true) {
      final now = DateTime.now();
      // Oynadan tashqari so'rovlarni tozalash
      while (_requestTimes.isNotEmpty &&
          now.difference(_requestTimes.first) >= window) {
        _requestTimes.removeFirst();
      }

      if (_requestTimes.length < maxRequests) {
        _requestTimes.addLast(now);
        return;
      }

      // Eng qadimgi so'rov tugaguncha kutamiz
      final oldest = _requestTimes.first;
      final waitDuration = window - now.difference(oldest) + const Duration(milliseconds: 100);
      await Future.delayed(waitDuration);
    }
  }

  int get remainingRequests {
    final now = DateTime.now();
    while (_requestTimes.isNotEmpty &&
        now.difference(_requestTimes.first) >= window) {
      _requestTimes.removeFirst();
    }
    return maxRequests - _requestTimes.length;
  }
}
