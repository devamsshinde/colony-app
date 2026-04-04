import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repository.dart';

/// Authentication state enum
enum AuthStatus {
  initial, // App just started, checking auth state
  loading, // Performing auth operation
  authenticated, // User is logged in
  unauthenticated, // User is not logged in
  error, // Error occurred
}

/// State class for authentication
class AuthStateData {
  final AuthStatus status;
  final User? user;
  final Map<String, dynamic>? profile;
  final String? errorMessage;

  const AuthStateData({
    this.status = AuthStatus.initial,
    this.user,
    this.profile,
    this.errorMessage,
  });

  AuthStateData copyWith({
    AuthStatus? status,
    User? user,
    Map<String, dynamic>? profile,
    String? errorMessage,
  }) {
    return AuthStateData(
      status: status ?? this.status,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}

/// StateNotifier for managing authentication state
class AuthStateNotifier extends ValueNotifier<AuthStateData> {
  final AuthRepository _authRepository;
  StreamSubscription<AuthState>? _authSubscription;

  AuthStateNotifier({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(const AuthStateData()) {
    _initializeAuth();
  }

  /// Initialize authentication state and listen to changes
  Future<void> _initializeAuth() async {
    value = value.copyWith(status: AuthStatus.loading);

    try {
      // Check if there's an existing session
      final user = _authRepository.getCurrentUser();

      if (user != null) {
        // User is logged in, fetch profile
        final profile = await _authRepository.getCurrentProfile();
        value = value.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          profile: profile,
        );
      } else {
        value = value.copyWith(status: AuthStatus.unauthenticated);
      }

      // Listen to auth state changes
      _authSubscription = _authRepository.onAuthStateChange.listen(
        _handleAuthStateChange,
        onError: (error) {
          debugPrint('Auth state change error: $error');
        },
      );
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      value = value.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  /// Handle auth state changes from Supabase
  void _handleAuthStateChange(AuthState authState) {
    final event = authState.event;
    final session = authState.session;

    debugPrint('Auth state changed: $event');

    switch (event) {
      case AuthChangeEvent.signedIn:
        if (session?.user != null) {
          _fetchProfileAndNotify(session!.user);
        }
        break;
      case AuthChangeEvent.signedOut:
        value = value.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          profile: null,
        );
        break;
      case AuthChangeEvent.tokenRefreshed:
        // Token refreshed, user still authenticated
        if (session?.user != null && value.user?.id != session!.user.id) {
          _fetchProfileAndNotify(session.user);
        }
        break;
      case AuthChangeEvent.userUpdated:
        if (session?.user != null) {
          value = value.copyWith(user: session!.user);
        }
        break;
      case AuthChangeEvent.passwordRecovery:
        // Handle password recovery if needed
        break;
      default:
        break;
    }
  }

  /// Fetch user profile and update state
  Future<void> _fetchProfileAndNotify(User user) async {
    try {
      final profile = await _authRepository.getCurrentProfile();
      value = value.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        profile: profile,
      );
    } catch (e) {
      debugPrint('Failed to fetch profile: $e');
      value = value.copyWith(status: AuthStatus.authenticated, user: user);
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    value = value.copyWith(status: AuthStatus.loading);

    try {
      final user = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
      );

      if (user != null) {
        // Fetch the profile
        final profile = await _authRepository.getCurrentProfile();
        value = value.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          profile: profile,
        );
        return true;
      } else {
        value = value.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Failed to create account.',
        );
        return false;
      }
    } catch (e) {
      value = value.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    value = value.copyWith(status: AuthStatus.loading);

    try {
      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        // Fetch the profile
        final profile = await _authRepository.getCurrentProfile();
        value = value.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          profile: profile,
        );
        return true;
      } else {
        value = value.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Login failed. Please try again.',
        );
        return false;
      }
    } catch (e) {
      value = value.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    value = value.copyWith(status: AuthStatus.loading);

    try {
      await _authRepository.signOut();
      value = value.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        profile: null,
      );
    } catch (e) {
      // Even if sign out fails, clear local state
      value = value.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        profile: null,
      );
    }
  }

  /// Send password reset email
  Future<bool> resetPassword({required String email}) async {
    value = value.copyWith(status: AuthStatus.loading);

    try {
      await _authRepository.resetPassword(email: email);
      value = value.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      value = value.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    if (value.user == null) return;

    try {
      final profile = await _authRepository.getCurrentProfile();
      value = value.copyWith(profile: profile);
    } catch (e) {
      debugPrint('Failed to refresh profile: $e');
    }
  }

  /// Clear error state
  void clearError() {
    if (value.hasError) {
      value = value.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );
    }
  }

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    return await _authRepository.isUsernameAvailable(username);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
