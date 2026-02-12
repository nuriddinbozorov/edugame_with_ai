import 'package:intl/intl.dart';

class AppHelpers {
  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  // Format datetime
  static String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  // Format time
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Get time ago (e.g., "2 soat oldin")
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} yil oldin';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} oy oldin';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} kun oldin';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} soat oldin';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} daqiqa oldin';
    } else {
      return 'Hozirgina';
    }
  }

  // Format duration (seconds to mm:ss)
  static String formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Truncate string
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Format number with spaces (e.g., 1000000 -> 1 000 000)
  static String formatNumber(int number) {
    return NumberFormat('#,###', 'en_US').format(number).replaceAll(',', ' ');
  }

  // Get percentage
  static double getPercentage(int value, int total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  // Get grade color
  static String getGradeColor(double percentage) {
    if (percentage >= 90) return '4CAF50'; // Green
    if (percentage >= 75) return 'FBBC04'; // Yellow
    if (percentage >= 60) return 'FF9800'; // Orange
    return 'F44336'; // Red
  }

  // Get level title
  static String getLevelTitle(int level) {
    if (level >= 100) return 'Ustozlik';
    if (level >= 50) return 'Mutaxassis';
    if (level >= 25) return 'Ilg\'or';
    if (level >= 10) return 'Boshlang\'ich';
    return 'Yangi boshlovchi';
  }
}
