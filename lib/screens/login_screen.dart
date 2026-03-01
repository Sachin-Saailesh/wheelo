import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design/app_colors.dart';
import '../design/app_typography.dart';
import '../design/app_spacing.dart';
import '../ui/components/app_button.dart';
import '../ui/components/app_text_field.dart';
import '../ui/components/app_scaffold.dart';
import '../providers/app_state.dart';

import 'otp_screen.dart';
import 'location_permission_screen.dart'; // fallback if needed

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        _isPhoneValid = _phoneController.text.trim().length == 10;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Save name locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cachedUserName', _nameController.text.trim());

      final appState = Provider.of<AppState>(context, listen: false);

      await appState.sendOtp(
        phone: _phoneController.text.trim(),
        name: _nameController.text.trim(),
        onCodeSent: (String verId, int? token) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OtpScreen(
                  phoneNumber: _phoneController.text.trim(),
                  name: _nameController.text.trim(),
                  verificationId: verId,
                ),
              ),
            );
          }
        },
        onError: (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification Failed: ${e.message}')),
            );
          }
        },
        onAutoVerified: (cred) async {
          if (mounted) {
            // Auto-verified locally or instantly by Play Services
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('hasCompletedAuth', true);

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const LocationPermissionScreen(),
              ),
              (route) => false,
            );
          }
        },
      );
    }
  }

  void _handleGoogleSignIn() async {
    final appState = Provider.of<AppState>(context, listen: false);
    bool success = await appState.signInWithGoogle();

    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedAuth', true);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppState>().isLoading;

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Hero
              Text(
                'Wheelo',
                style: AppTypography.textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Designed for Seamless Experience',
                style: AppTypography.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xxl),

              Text(
                'Create an account',
                style: AppTypography.textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter your details to continue',
                style: AppTypography.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Name Field
              AppTextField(
                controller: _nameController,
                labelText: 'Full Name',
                hintText: 'e.g. Priya Sharma',
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter your name'
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Email Field
              AppTextField(
                controller: _emailController,
                labelText: 'Email (Optional)',
                hintText: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Phone Field
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 2,
                    ), // align with text field visually
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+91',
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      hintText: 'Enter 10 digit number',
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.trim().length != 10) {
                          return 'Enter 10 valid digits';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppButton(
                text: 'Continue',
                onPressed: _isPhoneValid ? _handleLogin : null,
                isLoading: isLoading,
                isFullWidth: true,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Social Options
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(Icons.g_mobiledata, _handleGoogleSignIn),
                  const SizedBox(width: AppSpacing.lg),
                  _buildSocialIcon(Icons.email_outlined, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email login coming soon')),
                    );
                  }),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTypography.textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'By continuing you agree to our\n'),
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Redirecting to Terms of Service...',
                                ),
                              ),
                            );
                          },
                      ),
                      const TextSpan(text: ' & '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Redirecting to Privacy Policy...',
                                ),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceHighlight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Icon(icon, color: AppColors.primary, size: 32),
      ),
    );
  }
}
