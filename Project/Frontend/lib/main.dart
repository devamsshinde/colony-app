import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/data/auth_state_notifier.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'features/auth/presentation/screens/email_verification_screen.dart';
import 'features/auth/presentation/screens/phone_verification_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthStateNotifier())],
      child: MaterialApp(
        title: 'Colony',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5631)),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const MainNavigationScreen(),
          '/email-verification': (context) => EmailVerificationScreen(
            email: ModalRoute.of(context)?.settings.arguments as String?,
          ),
          '/phone-verification': (context) => PhoneVerificationScreen(
            isOptional: true,
            onVerified: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            onSkip: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
        },
      ),
    );
  }
}

/// Wrapper widget that handles authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateNotifier>(
      builder: (context, authNotifier, child) {
        final authState = authNotifier.value;

        // Show splash screen while checking auth state
        if (authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading) {
          return const SplashScreen();
        }

        // Show main screen if authenticated
        if (authState.status == AuthStatus.authenticated &&
            authState.user != null) {
          return const MainNavigationScreen();
        }

        // Show login screen if not authenticated
        return const LoginScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF9E9), Color(0xFFE2F3D9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 64, color: const Color(0xFF1B5A27)),
              const SizedBox(height: 16),
              const Text(
                'Colony',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5A27),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Color(0xFF1B5A27)),
            ],
          ),
        ),
      ),
    );
  }
}
