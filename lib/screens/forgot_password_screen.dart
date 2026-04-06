import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../services/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);

    final success = await authProvider.resetPassword(
      _emailController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        setState(() => _emailSent = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.error ?? 'Xatolik yuz berdi',
            ),
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
        decoration: const BoxDecoration(
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
                  IconButton(
                    alignment: Alignment.centerLeft,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Icon(
                    Icons.lock_reset,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Parolni tiklash',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _emailSent
                        ? 'Elektron pochtangizni tekshiring'
                        : 'Elektron pochtangizni kiriting. Parolni yangilash havolasini yuboramiz.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_emailSent) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingLarge),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLarge),
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
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleResetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMedium,
                                    ),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Havolani yuborish',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingLarge),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.mark_email_read,
                            size: 48,
                            color: AppColors.success,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Havola yuborildi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _emailController.text.trim(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Kirish sahifasiga qaytish',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
