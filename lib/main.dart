import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'app_router.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: const WheeloApp(),
    ),
  );
}

class WheeloApp extends StatelessWidget {
  const WheeloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wheelo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.generateRoute,
      home: const SplashScreen(), // Starts flow here
    );
  }
}

// Global Auth Router Guard
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _hasGrantedLocation = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming hasCompletedAuth is synced with Firebase state logically via Login
    _hasGrantedLocation = prefs.getBool('hasGrantedLocation') ?? false;

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.pearlWhite,
        body: Center(child: CircularProgressIndicator(color: AppTheme.skyBlue)),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.pearlWhite,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.skyBlue),
            ),
          );
        }

        // Auth Logic
        if (snapshot.hasData) {
          // Logged in
          if (_hasGrantedLocation) {
            // Already gave location, jump to home
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/home');
            });
            return const Scaffold(
              backgroundColor: AppTheme.pearlWhite,
            ); // placeholder while transitioning
          } else {
            // Prompt for location
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/location');
            });
            return const Scaffold(backgroundColor: AppTheme.pearlWhite);
          }
        }

        // Not authenticated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/login');
        });
        return const Scaffold(backgroundColor: AppTheme.pearlWhite);
      },
    );
  }
}
