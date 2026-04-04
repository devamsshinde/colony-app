import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Repository for handling all authentication operations with Supabase
class AuthRepository {
  final SupabaseClient _supabase;

  /// Singleton instance
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  AuthRepository._internal() : _supabase = Supabase.instance.client;

  /// Custom exception for authentication errors
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password. Please try again.';
        case 'Email not confirmed':
          return 'Please verify your email before logging in.';
        case 'User already registered':
          return 'An account with this email already exists.';
        case 'Password should be at least 6 characters':
          return 'Password must be at least 6 characters long.';
        case 'Unable to validate email address':
          return 'Please enter a valid email address.';
        case 'User not found':
          return 'No account found with this email.';
        case 'Signups not allowed':
          return 'New registrations are currently disabled.';
        default:
          return error.message;
      }
    }
    if (error is PostgrestException) {
      return 'Database error: ${error.message}';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Sign up with email, password, full name, and username
  ///
  /// First checks if username is available, then creates the account
  /// and updates the profile with the provided details.
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    try {
      // 1. Check if username is already taken using the security definer function
      // This bypasses RLS policies since the user isn't authenticated yet
      final isAvailable = await _supabase.rpc(
        'check_username_available',
        params: {'p_username': username.toLowerCase()},
      );

      if (isAvailable != true) {
        throw Exception(
          'Username "$username" is already taken. Please choose another.',
        );
      }

      // 2. Create auth user with Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          'username': username.toLowerCase(),
        },
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception('Failed to create account. Please try again.');
      }

      // 3. The trigger handle_new_user() will auto-create a profile
      // But we need to update it with the correct full_name and username
      // Wait a moment for the trigger to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // 4. Update the profile with full_name and username
      await _supabase
          .from('profiles')
          .update({
            'full_name': fullName.trim(),
            'username': username.toLowerCase(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      return user;
    } on AuthException catch (e) {
      throw Exception(getErrorMessage(e));
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred during signup.');
    }
  }

  /// Sign in with email and password
  ///
  /// Authenticates the user, logs device info, and updates online status.
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Authenticate with Supabase Auth
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception('Login failed. Please try again.');
      }

      // 2. Log device info and check device limit
      await _logDevice(user.id);

      // 3. Update profile online status
      await _supabase
          .from('profiles')
          .update({
            'is_online': true,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      return user;
    } on AuthException catch (e) {
      throw Exception(getErrorMessage(e));
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred during login.');
    }
  }

  /// Sign out the current user
  ///
  /// Updates profile status before signing out.
  Future<void> signOut() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId != null) {
        // Update profile status before signing out
        await _supabase
            .from('profiles')
            .update({
              'is_online': false,
              'last_seen': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }

      // Sign out from Supabase Auth
      await _supabase.auth.signOut();
    } catch (e) {
      // Even if profile update fails, try to sign out
      try {
        await _supabase.auth.signOut();
      } catch (_) {
        // Ignore sign out errors
      }
    }
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        redirectTo: 'io.supabase.colony://reset-password',
      );
    } on AuthException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to send reset email. Please try again.');
    }
  }

  /// Get the current authenticated user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Get the current session
  Session? getSession() {
    return _supabase.auth.currentSession;
  }

  /// Stream of authentication state changes
  Stream<AuthState> get onAuthStateChange {
    return _supabase.auth.onAuthStateChange;
  }

  /// Log device information and check device limit
  ///
  /// Private method that:
  /// - Gets device info using device_info_plus
  /// - Checks if device has exceeded account limit (max 2 accounts)
  /// - Logs device info to device_logs table
  /// - Updates profile with device_id and device_model
  Future<void> _logDevice(String userId) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceId;
      String deviceModel;
      String osVersion;

      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
        deviceModel = iosInfo.model;
        osVersion = 'iOS ${iosInfo.systemVersion}';
      } else {
        // Web or other platforms
        final webInfo = await deviceInfo.webBrowserInfo;
        deviceId =
            webInfo.userAgent ?? 'web-${DateTime.now().millisecondsSinceEpoch}';
        deviceModel = 'Web Browser';
        osVersion = webInfo.platform ?? 'Unknown';
      }

      // Check device limit using RPC function
      final deviceLimitCheck = await _supabase.rpc(
        'check_device_limit',
        params: {'p_device_id': deviceId},
      );

      if (deviceLimitCheck == true) {
        // Device limit exceeded - sign out and throw error
        await _supabase.auth.signOut();
        throw Exception(
          'Maximum accounts reached on this device. Please use an existing account.',
        );
      }

      // Insert device log
      await _supabase.from('device_logs').insert({
        'user_id': userId,
        'device_id': deviceId,
        'device_model': deviceModel,
        'os_version': osVersion,
        'login_at': DateTime.now().toIso8601String(),
      });

      // Update profile with device info
      await _supabase
          .from('profiles')
          .update({'device_id': deviceId, 'device_model': deviceModel})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      // If RPC function doesn't exist, just log without limit check
      if (e.code == 'PGRST202') {
        // Function doesn't exist, skip device limit check
        debugPrint('Device limit check function not found, skipping...');
      } else {
        rethrow;
      }
    } catch (e) {
      // Don't fail login if device logging fails
      debugPrint('Device logging failed: $e');
    }
  }

  /// Check if a username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final result = await _supabase
          .from('profiles')
          .select('id')
          .eq('username', username.toLowerCase())
          .maybeSingle();

      return result == null;
    } catch (e) {
      // If check fails, assume username is available
      return true;
    }
  }

  /// Get current user's profile
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return profile;
    } catch (e) {
      return null;
    }
  }

  /// Update user's FCM token for push notifications
  Future<void> updateFcmToken(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Failed to update FCM token: $e');
    }
  }

  // =====================================================
  // PHONE OTP VERIFICATION METHODS
  // =====================================================

  /// Format phone number to international format
  ///
  /// Adds +91 prefix for Indian numbers if not present
  String _formatPhoneNumber(String phoneNumber) {
    final trimmed = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (trimmed.startsWith('+')) {
      return trimmed;
    } else if (trimmed.startsWith('91') && trimmed.length == 12) {
      return '+$trimmed';
    } else if (trimmed.length == 10) {
      return '+91$trimmed';
    }
    return '+$trimmed';
  }

  /// Send OTP to phone number
  ///
  /// Formats the phone number and sends OTP via Supabase Auth
  Future<void> sendPhoneOTP({required String phoneNumber}) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);

      await _supabase.auth.signInWithOtp(phone: formattedPhone);
    } on AuthException catch (e) {
      String errorMessage;
      switch (e.message) {
        case 'Invalid phone number format':
          errorMessage = 'Please enter a valid phone number.';
          break;
        case 'Rate limit exceeded':
          errorMessage =
              'Too many attempts. Please wait before requesting another OTP.';
          break;
        case 'SMS provider error':
          errorMessage = 'Failed to send SMS. Please try again.';
          break;
        default:
          errorMessage = e.message;
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to send OTP. Please try again.');
    }
  }

  /// Verify phone OTP
  ///
  /// Verifies the OTP and updates profile phone field on success
  Future<AuthResponse> verifyPhoneOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);

      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      // Update profile phone on successful verification
      if (response.user != null) {
        await _supabase
            .from('profiles')
            .update({
              'phone': formattedPhone,
              'phone_verified': true,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', response.user!.id);
      }

      return response;
    } on AuthException catch (e) {
      String errorMessage;
      switch (e.message) {
        case 'Token has expired or is invalid':
          errorMessage = 'Invalid or expired OTP. Please request a new one.';
          break;
        case 'Invalid OTP':
          errorMessage = 'Incorrect OTP. Please try again.';
          break;
        default:
          errorMessage = e.message;
      }
      throw Exception(errorMessage);
    }
  }

  /// Link phone number to existing account
  ///
  /// Verifies OTP and links phone to current user's account
  Future<void> linkPhoneToAccount({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('You must be logged in to link a phone number.');
      }

      final formattedPhone = _formatPhoneNumber(phoneNumber);

      // Check if phone is already used by another account
      final existingPhone = await _supabase
          .from('profiles')
          .select('id')
          .eq('phone', formattedPhone)
          .neq('id', userId)
          .maybeSingle();

      if (existingPhone != null) {
        throw Exception(
          'This phone number is already registered with another account.',
        );
      }

      // Verify OTP
      await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      // Update profile with phone
      await _supabase
          .from('profiles')
          .update({
            'phone': formattedPhone,
            'phone_verified': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } on AuthException catch (e) {
      throw Exception(getErrorMessage(e));
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    }
  }

  // =====================================================
  // EMAIL VERIFICATION METHODS
  // =====================================================

  /// Send email verification
  ///
  /// Resends verification email to current user
  Future<void> sendEmailVerification() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently logged in.');
      }

      final email = user.email;
      if (email == null) {
        throw Exception('Current user has no email address.');
      }

      await _supabase.auth.resend(type: OtpType.email, email: email);
    } on AuthException catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }

  /// Check if current user's email is verified
  bool isEmailVerified() {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    return user.emailConfirmedAt != null;
  }

  /// Check if current user's phone is verified
  ///
  /// Checks if profile has a verified phone number
  Future<bool> isPhoneVerified() async {
    try {
      final profile = await getCurrentProfile();
      if (profile == null) return false;
      return profile['phone_verified'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Get current user's phone number from profile
  Future<String?> getCurrentPhone() async {
    try {
      final profile = await getCurrentProfile();
      return profile?['phone'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Update user email
  ///
  /// Sends verification to new email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(email: newEmail));
    } on AuthException catch (e) {
      throw Exception(getErrorMessage(e));
    }
  }
}
