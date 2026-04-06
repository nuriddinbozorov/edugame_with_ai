import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../services/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Xatolik yuz berdi'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    AppStrings.welcomeSubtitle,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // Login form
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: AppStrings.email,
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMedium,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Elektron pochtani kiriting';
                              }
                              if (!value.contains('@')) {
                                return 'To\'g\'ri elektron pochta kiriting';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: AppStrings.password,
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMedium,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Parolni kiriting';
                              }
                              if (value.length < 6) {
                                return 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                AppStrings.forgotPassword,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMedium,
                                      ),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          AppStrings.login,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Hisobingiz yo\'qmi?',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          AppStrings.register,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
