import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_typography.dart';
import '../ui/components/app_button.dart';
import '../ui/components/app_scaffold.dart';
import '../providers/app_state.dart';
import 'location_permission_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.name,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCooldown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() => _resendCooldown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp(); // Auto trigger validation on 6th digit
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOtp() async {
    final otpStr = _controllers.map((c) => c.text).join();
    if (otpStr.length != 6) return;

    final appState = Provider.of<AppState>(context, listen: false);

    final success = await appState.verifyOtp(
      widget.verificationId,
      otpStr,
      widget.name,
      widget.phoneNumber,
    );

    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedAuth', true);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP or Verification Failed.')),
      );
      // Clear inputs
      for (var c in _controllers) c.clear();
      if (_focusNodes.isNotEmpty) _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppState>().isLoading;

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            // Header row with back icon
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Verify OTP',
              style: AppTypography.textTheme.displayLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sent to +91 ${widget.phoneNumber}',
              style: AppTypography.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // OTP Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return Container(
                  width: 44,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.displaySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors
                          .transparent, // Ensure it inherits the container's color
                    ),
                    onChanged: (val) => _onDigitChanged(index, val),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xxl),

            if (isLoading)
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),

            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              text: _resendCooldown > 0
                  ? 'Resend via SMS in ${_resendCooldown}s'
                  : 'Resend via SMS',
              onPressed: _resendCooldown > 0
                  ? null
                  : () {
                      _startResendTimer();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Resend initiated')),
                      );
                    },
              variant: AppButtonVariant.secondary,
              icon: Icons.sms,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: _resendCooldown > 0
                  ? 'Send via WhatsApp in ${_resendCooldown}s'
                  : 'Send via WhatsApp',
              onPressed: _resendCooldown > 0
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('WhatsApp OTP'),
                          content: const Text(
                            'WhatsApp OTP delivery will be integrated later.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      _startResendTimer();
                    },
              variant: AppButtonVariant.outline,
              icon: Icons.chat,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.xl),

            Center(
              child: Text(
                'By choosing WhatsApp, you agree to receive messages from Wheelo on WhatsApp.',
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
