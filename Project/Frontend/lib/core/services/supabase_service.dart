import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

/// Supabase Service - Singleton class to manage Supabase client
///
/// This service provides a centralized way to access Supabase functionality
/// throughout the app. Initialize it in main.dart before running the app.
class SupabaseService {
  // Singleton instance
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  /// Whether Supabase has been initialized
  static bool _isInitialized = false;

  /// Initialize Supabase client
  ///
  /// Call this method in main.dart before runApp()
  /// ```dart
  /// await SupabaseService.initialize();
  /// ```
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
      debug: true, // Enable debug mode for development
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );

    _isInitialized = true;
  }

  /// Get the Supabase client instance
  ///
  /// Throws an error if Supabase hasn't been initialized
  SupabaseClient get client {
    if (!_isInitialized) {
      throw StateError(
        'Supabase has not been initialized. '
        'Call SupabaseService.initialize() before accessing the client.',
      );
    }
    return Supabase.instance.client;
  }

  /// Get the Supabase auth client
  GoTrueClient get auth {
    if (!_isInitialized) {
      throw StateError(
        'Supabase has not been initialized. '
        'Call SupabaseService.initialize() before accessing auth.',
      );
    }
    return Supabase.instance.client.auth;
  }

  /// Get the current authenticated user
  ///
  /// Returns null if no user is signed in
  User? get currentUser {
    if (!_isInitialized) return null;
    return Supabase.instance.client.auth.currentUser;
  }

  /// Get the current session
  ///
  /// Returns null if no active session
  Session? get currentSession {
    if (!_isInitialized) return null;
    return Supabase.instance.client.auth.currentSession;
  }

  /// Check if a user is currently signed in
  bool get isAuthenticated {
    if (!_isInitialized) return false;
    return Supabase.instance.client.auth.currentSession != null;
  }

  /// Stream of auth state changes
  ///
  /// Emits events when the user signs in, signs out, or token is refreshed
  Stream<AuthState> get authStateChanges {
    if (!_isInitialized) {
      throw StateError(
        'Supabase has not been initialized. '
        'Call SupabaseService.initialize() before accessing auth state.',
      );
    }
    return Supabase.instance.client.auth.onAuthStateChange;
  }

  /// Sign in with email and password
  ///
  /// Returns the auth response containing user and session
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithPassword(email: email, password: password);
  }

  /// Sign up with email and password
  ///
  /// Returns the auth response containing user and session
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return await auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );
  }

  /// Sign in with Google OAuth
  ///
  /// Opens the browser/Google app for authentication
  Future<bool> signInWithGoogle() async {
    try {
      await auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://reset-callback/',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Send a password reset email
  Future<void> resetPassword(String email) async {
    await auth.resetPasswordForEmail(email);
  }

  /// Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    return await auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Update user metadata
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> data) async {
    return await auth.updateUser(UserAttributes(data: data));
  }

  /// Get user by ID from the database
  ///
  /// Returns the user profile data or null if not found
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from(SupabaseConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Create or update user profile
  Future<void> upsertUserProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    String? bio,
  }) async {
    await client.from(SupabaseConstants.profilesTable).upsert({
      'id': userId,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
