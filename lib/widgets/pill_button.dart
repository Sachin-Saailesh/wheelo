import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double width;

  const PillButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: 56, // Generous touch target
      child: isOutlined
          ? OutlinedButton(
              onPressed: (isLoading || onPressed == null) ? null : onPressed,
              child: _buildContent(),
            )
          : ElevatedButton(
              onPressed: (isLoading || onPressed == null) ? null : onPressed,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: AppTheme.skyBlue.withOpacity(0.5),
                disabledForegroundColor: Colors.white70,
              ),
              child: _buildContent(),
            ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: isOutlined ? AppTheme.skyBlue : Colors.white,
        ),
      );
    }
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
