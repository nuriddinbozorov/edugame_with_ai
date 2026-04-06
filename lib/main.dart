import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_constants.dart';
import 'services/auth_provider.dart';
import 'services/supabase_service.dart';
import 'utils/logger.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    final supabaseService = SupabaseService();

    // TODO: O'z Supabase ma'lumotlaringizni bu yerga kiriting!
    // Supabase Dashboard > Settings > API dan oling
    const supabaseUrl = 'https://tnoijevkqjhgxzfewrtq.supabase.co';
    const supabaseAnonKey = 'sb_publishable_qsjhBJkP_upwr8VIf4AoeQ_JzEUeZJM';

    await supabaseService.initialize(supabaseUrl, supabaseAnonKey);
    AppLogger.success('App: Supabase initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('App: Failed to initialize Supabase', e, stackTrace);
  }

  // System UI configuration
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const EduGameApp());
}

class EduGameApp extends StatelessWidget {
  const EduGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,

        // Theme
        theme: ThemeData(
          useMaterial3: true,

          // Color scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
            background: AppColors.background,
            surface: AppColors.cardBackground,
          ),

          // Scaffold
          scaffoldBackgroundColor: AppColors.background,

          // Text theme
          textTheme: GoogleFonts.robotoTextTheme(),

          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: AppColors.textPrimary),
            titleTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),

          // Card theme
          cardTheme: CardThemeData(
            color: AppColors.cardBackground,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.cardBackground,

            // Borders
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),

            // Content padding
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingMedium,
            ),

            // Label style
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            hintStyle: TextStyle(color: AppColors.textHint),
          ),

          // Button themes
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: AppColors.primary.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge,
                vertical: AppSizes.paddingMedium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge,
                vertical: AppSizes.paddingMedium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Bottom navigation bar theme
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            elevation: 8,
            type: BottomNavigationBarType.fixed,
          ),

          // Progress indicator theme
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.primary,
          ),

          // Divider theme
          dividerTheme: DividerThemeData(
            color: AppColors.textSecondary.withOpacity(0.1),
            thickness: 1,
          ),
        ),

        // Home page - RootScreen orqali authentication tekshiradi
        home: const RootScreen(),
      ),
    );
  }
}

/// Birinchi ekran - avtentifikatsiya statusiga qarab login yoki home ko'rsatadi
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    // Build tamamlanganidan keyin kontekst ishlatib o'qish uchun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Birinchi martta ilovani yukladigimizda sessiya tekshiramiz
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Hozir yuklanmoqda - splash screen ko'rsatamiz
        if (authProvider.status == AuthStatus.loading) {
          return const SplashScreen();
        }

        // Foydalanuvchi autentifikatsiya qilgan - home screenga yo'naltiramiz
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        // Autentifikatsiya qilmagan - login screenga yo'naltiramiz
        return const LoginScreen();
      },
    );
  }
}

/// Splash screen - yuklanish vaqtida ko'rsatiladi
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
        child: const SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 100, color: Colors.white),
                SizedBox(height: 24),
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppStrings.appTagline,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 48),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 24),
                Text(
                  'Yuklanmoqda...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Demo start screen - faqat test uchun
// Keyin LoginScreen bilan almashtiring
class DemoStartScreen extends StatelessWidget {
  const DemoStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 100, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.appTagline,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Yuklanmoqda...',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'NOTE: Supabase URL va Anon Key ni main.dart faylida o\'zgartiring!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
