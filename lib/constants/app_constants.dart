import 'package:flutter/material.dart';

// =====================================================
// COLORS
// =====================================================
class AppColors {
  // Primary colors
  static const primary = Color(0xFF6C63FF);
  static const secondary = Color(0xFF4CAF50);
  static const accent = Color(0xFFFF6B9D);

  // Background colors
  static const background = Color(0xFFF5F7FA);
  static const cardBackground = Colors.white;
  static const scaffoldBackground = Color(0xFFFAFAFA);

  // Text colors
  static const textPrimary = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const textHint = Color(0xFFB2BEC3);

  // Status colors
  static const success = Color(0xFF00D9A5);
  static const warning = Color(0xFFFFB800);
  static const error = Color(0xFFFF4757);
  static const info = Color(0xFF3498DB);

  // Gradient colors
  static const gradientStart = Color(0xFF667EEA);
  static const gradientEnd = Color(0xFF764BA2);
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  // Subject colors
  static const mathematics = Color(0xFF4285F4);
  static const uzbekLanguage = Color(0xFFEA4335);
  static const english = Color(0xFFFBBC04);
  static const science = Color(0xFF34A853);
  static const history = Color(0xFF9C27B0);
  static const geography = Color(0xFF00ACC1);

  // Achievement colors
  static const gold = Color(0xFFFFD700);
  static const silver = Color(0xFFC0C0C0);
  static const bronze = Color(0xFFCD7F32);

  // Shadow
  static final shadowColor = Colors.black.withOpacity(0.1);
}

// =====================================================
// SIZES
// =====================================================
class AppSizes {
  // Padding
  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border radius
  static const double radiusTiny = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;
  static const double radiusExtraLarge = 28.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconExtraLarge = 48.0;

  // Button sizes
  static const double buttonHeight = 50.0;
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightLarge = 60.0;
}

// =====================================================
// STRINGS (O'zbek tilida)
// =====================================================
class AppStrings {
  // App info
  static const appName = 'EduGame';
  static const appTagline = 'O\'yinlar orqali o\'rganish';
  static const version = '1.0.0';

  // Welcome
  static const welcomeTitle = 'Xush kelibsiz!';
  static const welcomeSubtitle = 'O\'yinlar orqali o\'rganishni boshlang';
  static const getStarted = 'Boshlash';

  // Authentication
  static const login = 'Kirish';
  static const register = 'Ro\'yxatdan o\'tish';
  static const logout = 'Chiqish';
  static const email = 'Elektron pochta';
  static const password = 'Parol';
  static const confirmPassword = 'Parolni tasdiqlang';
  static const name = 'Ism';
  static const fullName = 'To\'liq ism';
  static const grade = 'Sinf';
  static const forgotPassword = 'Parolni unutdingizmi?';
  static const dontHaveAccount = 'Hisobingiz yo\'qmi?';
  static const alreadyHaveAccount = 'Hisobingiz bormi?';
  static const createAccount = 'Hisob yaratish';

  // Buttons
  static const submit = 'Yuborish';
  static const cancel = 'Bekor qilish';
  static const save = 'Saqlash';
  static const delete = 'O\'chirish';
  static const edit = 'Tahrirlash';
  static const continueBtn = 'Davom etish';
  static const skip = 'O\'tkazib yuborish';
  static const next = 'Keyingi';
  static const previous = 'Oldingi';
  static const finish = 'Tugatish';
  static const retry = 'Qayta urinish';
  static const close = 'Yopish';

  // Navigation
  static const home = 'Bosh sahifa';
  static const profile = 'Profil';
  static const settings = 'Sozlamalar';
  static const leaderboard = 'Yetakchilar';
  static const achievements = 'Yutuqlar';

  // Subjects
  static const subjects = 'Fanlar';
  static const mathematics = 'Matematika';
  static const uzbekLanguage = 'O\'zbek tili';
  static const english = 'Ingliz tili';
  static const science = 'Tabiatshunoslik';
  static const history = 'Tarix';
  static const geography = 'Geografiya';

  // Quiz
  static const startQuiz = 'Testni boshlash';
  static const question = 'Savol';
  static const questions = 'Savollar';
  static const answer = 'Javob';
  static const correctAnswer = 'To\'g\'ri javob';
  static const yourAnswer = 'Sizning javobingiz';
  static const selectAnswer = 'Javobni tanlang';
  static const nextQuestion = 'Keyingi savol';
  static const previousQuestion = 'Oldingi savol';
  static const submitAnswer = 'Javobni yuborish';
  static const skipQuestion = 'Savolni o\'tkazib yuborish';

  // Results
  static const results = 'Natijalar';
  static const score = 'Ball';
  static const yourScore = 'Sizning balingiz';
  static const totalScore = 'Jami ball';
  static const correct = 'To\'g\'ri!';
  static const incorrect = 'Noto\'g\'ri!';
  static const tryAgain = 'Qayta urinib ko\'ring';
  static const congratulations = 'Tabriklaymiz!';
  static const testCompleted = 'Test yakunlandi';
  static const passed = 'Muvaffaqiyatli!';
  static const failed = 'Yetarli emas';

  // Progress
  static const level = 'Daraja';
  static const points = 'Ball';
  static const coins = 'Tangalar';
  static const gems = 'Qimmatbaho toshlar';
  static const streak = 'Ketma-ketlik';
  static const progress = 'Taraqqiyot';
  static const total = 'Jami';
  static const completed = 'Bajarildi';
  static const inProgress = 'Jarayonda';
  static const locked = 'Yopiq';
  static const unlock = 'Ochish';
  static const nextLevel = 'Keyingi daraja';

  // Challenges
  static const dailyChallenge = 'Kunlik vazifa';
  static const weeklyChallenge = 'Haftalik vazifa';
  static const challenge = 'Vazifa';
  static const challenges = 'Vazifalar';

  // Time
  static const days = 'kun';
  static const hours = 'soat';
  static const minutes = 'daqiqa';
  static const seconds = 'soniya';
  static const timeLeft = 'Qolgan vaqt';
  static const timeUp = 'Vaqt tugadi';

  // Stats
  static const statistics = 'Statistika';
  static const rank = 'Reyting';
  static const ranking = 'Reytingdagi o\'rni';
  static const bestScore = 'Eng yaxshi natija';
  static const averageScore = 'O\'rtacha ball';
  static const totalTests = 'Jami testlar';
  static const testsCompleted = 'Bajarilgan testlar';

  // Messages
  static const loading = 'Yuklanmoqda...';
  static const noData = 'Ma\'lumot topilmadi';
  static const error = 'Xatolik';
  static const success = 'Muvaffaqiyatli';
  static const warning = 'Ogohlantirish';
  static const info = 'Ma\'lumot';
  static const comingSoon = 'Tez orada';
  static const underDevelopment = 'Ishlab chiqilmoqda';

  // Errors
  static const errorOccurred = 'Xatolik yuz berdi';
  static const tryAgainLater = 'Keyinroq qayta urinib ko\'ring';
  static const networkError = 'Internet bilan bog\'lanishda xatolik';
  static const serverError = 'Server xatosi';
  static const invalidCredentials = 'Noto\'g\'ri ma\'lumotlar';
  static const emailAlreadyExists =
      'Bu elektron pochta allaqachon ro\'yxatdan o\'tgan';
  static const weakPassword = 'Parol juda zaif';
  static const emailNotVerified = 'Elektron pochta tasdiqlanmagan';

  // Validation
  static const required = 'Bu maydon to\'ldirilishi shart';
  static const invalidEmail = 'Noto\'g\'ri elektron pochta';
  static const passwordTooShort = 'Parol juda qisqa';
  static const passwordsDontMatch = 'Parollar mos kelmayapti';
  static const invalidName = 'Noto\'g\'ri ism';
  static const invalidGrade = 'Noto\'g\'ri sinf';

  // Settings
  static const language = 'Til';
  static const notifications = 'Bildirishnomalar';
  static const sound = 'Ovoz';
  static const music = 'Musiqa';
  static const vibration = 'Tebranish';
  static const darkMode = 'Tungi rejim';
  static const about = 'Ilova haqida';
  static const terms = 'Foydalanish shartlari';
  static const privacy = 'Maxfiylik siyosati';
  static const help = 'Yordam';
  static const feedback = 'Fikr-mulohaza';
  static const rateApp = 'Ilovani baholang';
  static const share = 'Ulashish';

  // Other
  static const search = 'Qidirish';
  static const filter = 'Filtr';
  static const sort = 'Saralash';
  static const all = 'Hammasi';
  static const none = 'Yo\'q';
  static const yes = 'Ha';
  static const no = 'Yo\'q';
  static const ok = 'OK';
  static const confirm = 'Tasdiqlash';
}

// =====================================================
// DURATIONS
// =====================================================
class AppDurations {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const extraSlow = Duration(milliseconds: 1000);

  // Quiz durations
  static const questionTime = Duration(seconds: 30);
  static const resultDelay = Duration(seconds: 1);
}

// =====================================================
// ASSET PATHS
// =====================================================
class AppAssets {
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String animationsPath = 'assets/animations/';

  // Images
  static const String logo = '${imagesPath}logo.png';
  static const String emptyState = '${imagesPath}empty_state.png';
  static const String errorState = '${imagesPath}error_state.png';

  // Animations
  static const String confetti = '${animationsPath}confetti.json';
  static const String celebration = '${animationsPath}celebration.json';
}

// =====================================================
// API CONSTANTS
// =====================================================
class ApiConstants {
  // These should be in .env file
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
}
