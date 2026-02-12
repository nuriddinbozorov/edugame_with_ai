class Validators {
  // Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Elektron pochtani kiriting';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'To\'g\'ri elektron pochta manzilini kiriting';
    }

    return null;
  }

  // Password validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Parolni kiriting';
    }

    if (value.length < 6) {
      return 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
    }

    return null;
  }

  // Name validator
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ismni kiriting';
    }

    if (value.length < 2) {
      return 'Ism kamida 2 ta belgidan iborat bo\'lishi kerak';
    }

    if (value.length > 50) {
      return 'Ism 50 ta belgidan oshmasligi kerak';
    }

    return null;
  }

  // Grade validator
  static String? grade(int? value) {
    if (value == null) {
      return 'Sinfni tanlang';
    }

    if (value < 1 || value > 11) {
      return 'Sinf 1 dan 11 gacha bo\'lishi kerak';
    }

    return null;
  }

  // Generic required field validator
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Bu maydon'}ni to\'ldiring';
    }
    return null;
  }
}
