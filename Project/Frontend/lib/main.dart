import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/supabase_service.dart';
import 'core/services/location_service.dart';
import 'core/widgets/location_loading_screen.dart';
import 'features/auth/data/auth_state_notifier.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'features/auth/presentation/screens/email_verification_screen.dart';
import 'features/auth/presentation/screens/phone_verification_screen.dart';
import 'features/auth/presentation/screens/onboarding_flow_screen.dart';

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
          '/onboarding': (context) => const OnboardingFlowScreen(),
          '/email-verification': (context) => EmailVerificationScreen(
            email: ModalRoute.of(context)?.settings.arguments as String?,
          ),
          '/phone-verification': (context) => PhoneVerificationScreen(
            isOptional: true,
            onVerified: () {
              // Navigate to onboarding after phone verification
              Navigator.of(context).pushReplacementNamed('/onboarding');
            },
            onSkip: () {
              // Navigate to onboarding even if skipped
              Navigator.of(context).pushReplacementNamed('/onboarding');
            },
          ),
        },
      ),
    );
  }
}

/// Wrapper widget that handles authentication state and location tracking
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _isCheckingOnboarding = false;
  bool? _hasCompletedOnboarding;
  bool _isFetchingLocation = false;
  bool _locationFetched = false;

  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    // Register for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    _checkOnboardingStatus();
  }

  @override
  void dispose() {
    // Clean up observer
    WidgetsBinding.instance.removeObserver(this);
    // Stop location tracking when widget is disposed
    _locationService.stopTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - start tracking and set online
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        // App went to background - stop tracking and set offline
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        // App is being closed - cleanup
        _onAppDetached();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Do nothing for these states
        break;
    }
  }

  Future<void> _onAppResumed() async {
    // Start location tracking
    await _locationService.startTracking();
    // Set user as online
    await _locationService.setUserOnline();
  }

  Future<void> _onAppPaused() async {
    // Stop location tracking to save battery
    _locationService.stopTracking();
    // Set user as offline
    await _locationService.setUserOffline();
  }

  Future<void> _onAppDetached() async {
    // Stop tracking and set offline
    _locationService.stopTracking();
    await _locationService.setUserOffline();
  }

  Future<void> _checkOnboardingStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isCheckingOnboarding = true);

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('onboarding_completed')
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _hasCompletedOnboarding = response['onboarding_completed'] ?? false;
          _isCheckingOnboarding = false;
        });

        // If onboarding is complete, start location fetching
        if (_hasCompletedOnboarding == true) {
          _startLocationFetching();
        }
      }
    } catch (e) {
      // Profile doesn't exist or error - user needs onboarding
      if (mounted) {
        setState(() {
          _hasCompletedOnboarding = false;
          _isCheckingOnboarding = false;
        });
      }
    }
  }

  void _startLocationFetching() {
    setState(() {
      _isFetchingLocation = true;
    });
  }

  void _onLocationFetched() {
    setState(() {
      _isFetchingLocation = false;
      _locationFetched = true;
    });
  }

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

        // Show login screen if not authenticated
        if (authState.status != AuthStatus.authenticated ||
            authState.user == null) {
          return const LoginScreen();
        }

        // Still checking onboarding status - show splash
        if (_isCheckingOnboarding) {
          return const SplashScreen();
        }

        // If we haven't checked onboarding yet (_hasCompletedOnboarding is null),
        // show splash screen while we check
        if (_hasCompletedOnboarding == null) {
          // Trigger the check if not already checking
          if (!_isCheckingOnboarding) {
            _checkOnboardingStatus();
          }
          return const SplashScreen();
        }

        // Check if user has NOT completed onboarding
        if (_hasCompletedOnboarding == false) {
          return const OnboardingFlowScreen();
        }

        // User has completed onboarding - show location loading or home
        if (_isFetchingLocation && !_locationFetched) {
          return LocationLoadingScreen(
            onLocationFetched: _onLocationFetched,
            onLocationFailed: () {
              // Still proceed even if location fails
              _onLocationFetched();
            },
          );
        }

        // User is authenticated, has completed onboarding, and location is ready
        return const MainNavigationScreen();
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
