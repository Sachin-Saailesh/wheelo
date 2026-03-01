import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/location_permission_screen.dart';
import 'screens/home_screen.dart';
import 'screens/rent_vehicle_screen.dart';
import 'screens/host_registration_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      // Named route for OTP if needed, although it dynamically passes parameters in-place usually
      case '/location':
        return MaterialPageRoute(
          builder: (_) => const LocationPermissionScreen(),
        );
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/rent':
        return MaterialPageRoute(builder: (_) => const RentVehicleScreen());
      case '/host':
        return MaterialPageRoute(
          builder: (_) => const HostRegistrationScreen(),
        );
      // Fallback
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
