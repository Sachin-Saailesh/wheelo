import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/pill_button.dart';
import 'home_screen.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  Future<void> _requestLocation(BuildContext context) async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasGrantedLocation', true);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location is required to show nearby rides.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pearlWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Big Location Icon Placeholder
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppTheme.skyBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 100,
                  color: AppTheme.skyBlue,
                ),
              ),
              const SizedBox(height: 48),

              Text(
                'Location Permission',
                style: Theme.of(
                  context,
                ).textTheme.displayMedium?.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                'We need your location to show you nearby vehicles and provide better service.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              PillButton(
                text: 'Allow Location Access',
                onPressed: () => _requestLocation(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
