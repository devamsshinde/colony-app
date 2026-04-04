import 'package:flutter/foundation.dart';

/// Developer configuration for testing purposes
///
/// IMPORTANT: These settings are ONLY active in debug mode.
/// They are automatically disabled in release builds.
///
/// To use the developer OTP bypass:
/// 1. Run the app in debug mode (flutter run)
/// 2. Use the DEV_OTP_CODE when prompted for OTP verification
/// 3. The app will show a "Dev Mode" indicator when bypass is active
class DevConfig {
  /// Private constructor to prevent instantiation
  DevConfig._();

  /// Whether the app is running in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Developer OTP code for testing (only works in debug mode)
  /// Change this to any 6-digit code you prefer
  /// Current: 949294
  static const String devOtpCode = '949294';

  /// Whether to skip email verification in debug mode
  /// Set to true to auto-verify emails during development
  static const bool skipEmailVerification = true;

  /// Whether to skip phone verification in debug mode
  /// Set to true to auto-verify phone numbers during development
  static const bool skipPhoneVerification = true;

  /// Whether to show developer bypass options in UI
  /// When true, shows a "Use Dev OTP" button in verification screens
  static const bool showDevBypassButton = true;

  /// Check if developer OTP bypass should be available
  /// Returns true only in debug mode
  static bool get isOtpBypassEnabled => isDebugMode;

  /// Check if the provided OTP matches the developer OTP
  /// Only returns true in debug mode and when OTP matches
  static bool isValidDevOtp(String otp) {
    if (!isDebugMode) return false;
    return otp == devOtpCode;
  }

  /// Check if verification should be skipped for the given type
  /// Only returns true in debug mode
  static bool shouldSkipVerification(VerificationType type) {
    if (!isDebugMode) return false;
    switch (type) {
      case VerificationType.email:
        return skipEmailVerification;
      case VerificationType.phone:
        return skipPhoneVerification;
    }
  }

  /// Get a display string for dev mode indicator
  static String get devModeLabel => 'DEV MODE';
}

/// Types of verification that can be bypassed in dev mode
enum VerificationType { email, phone }
