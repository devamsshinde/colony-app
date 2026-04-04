import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../data/auth_repository.dart';
import '../../data/auth_state_notifier.dart';
import '../../../../core/config/dev_config.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? email;
  final VoidCallback? onVerified;
  final VoidCallback? onChangeEmail;

  const EmailVerificationScreen({
    super.key,
    this.email,
    this.onVerified,
    this.onChangeEmail,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();

  // State management
  bool _isLoading = false;
  bool _isVerified = false;
  String? _errorMessage;
  String? _successMessage;

  // Timer for resend
  Timer? _resendTimer;
  int _resendSeconds = 0;

  // Timer for auto-check
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _startAutoCheck();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendSeconds = 60;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startAutoCheck() {
    // Check every 5 seconds if email is verified
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isVerified) {
        timer.cancel();
        return;
      }

      try {
        // Refresh the session to check if email is verified
        _authRepository.getSession();
        if (_authRepository.isEmailVerified()) {
          timer.cancel();
          setState(() {
            _isVerified = true;
            _successMessage = 'Email verified successfully!';
          });

          // Update auth state
          if (mounted) {
            final authNotifier = context.read<AuthStateNotifier>();
            await authNotifier.refreshProfile();
          }

          // Navigate after short delay
          await Future.delayed(const Duration(milliseconds: 1500));

          if (mounted) {
            widget.onVerified?.call();
          }
        }
      } catch (e) {
        // Ignore errors during auto-check
      }
    });
  }

  Future<void> _resendVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authRepository.sendEmailVerification();

      setState(() {
        _successMessage = 'Verification email sent!';
      });

      _startResendTimer();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Force refresh session
      _authRepository.getSession();

      if (_authRepository.isEmailVerified()) {
        setState(() {
          _isVerified = true;
          _successMessage = 'Email verified successfully!';
        });

        // Update auth state
        if (mounted) {
          final authNotifier = context.read<AuthStateNotifier>();
          await authNotifier.refreshProfile();
        }

        // Navigate after short delay
        await Future.delayed(const Duration(milliseconds: 1000));

        if (mounted) {
          widget.onVerified?.call();
        }
      } else {
        setState(() {
          _errorMessage = 'Email not yet verified. Please check your inbox.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Dev bypass for email verification (only works in debug mode)
  Future<void> _devBypassVerification() async {
    if (!DevConfig.isDebugMode) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate successful verification
      setState(() {
        _isVerified = true;
        _successMessage = 'Email verified successfully! (Dev Mode)';
      });

      // Update auth state
      if (mounted) {
        final authNotifier = context.read<AuthStateNotifier>();
        await authNotifier.refreshProfile();
      }

      // Navigate after short delay
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        widget.onVerified?.call();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryDark = const Color(0xFF1B5A27);
    final textGrey = const Color(0xFF5F6E60);
    final bgColor1 = const Color(0xFFEEF9E9);
    final bgColor2 = const Color(0xFFE2F3D9);

    final email =
        widget.email ?? _authRepository.getCurrentUser()?.email ?? 'your email';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor1, bgColor2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF1B5A27),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 40),

                // Lottie Animation
                SizedBox(
                  height: 180,
                  child: _isVerified
                      ? Lottie.asset(
                          'assets/animations/success.json',
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.check_circle,
                              size: 100,
                              color: Colors.green,
                            );
                          },
                        )
                      : Lottie.asset(
                          'assets/animations/email_verification.json',
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.email_outlined,
                              size: 100,
                              color: primaryDark,
                            );
                          },
                        ),
                ),

                const SizedBox(height: 30),

                // Title
                Text(
                  _isVerified ? 'Email Verified!' : 'Check Your Email',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C3E2F),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isVerified
                      ? 'Your email has been verified.\nYou can now continue.'
                      : 'We\'ve sent a verification link to\n$email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: textGrey,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),

                // Error message
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Success message
                if (_successMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!_isVerified) ...[
                  // I've Verified Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 5,
                        shadowColor: primaryDark.withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'I\'ve Verified My Email',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Resend verification
                  if (_resendSeconds > 0)
                    Text(
                      'Resend email in $_resendSeconds seconds',
                      style: TextStyle(color: textGrey, fontSize: 14),
                    )
                  else
                    TextButton.icon(
                      onPressed: _isLoading ? null : _resendVerification,
                      icon: Icon(Icons.refresh, color: primaryDark),
                      label: Text(
                        'Resend Verification Email',
                        style: TextStyle(
                          color: primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Change email option
                  if (widget.onChangeEmail != null)
                    TextButton(
                      onPressed: widget.onChangeEmail,
                      child: Text(
                        'Change email address',
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Dev bypass button (only visible in debug mode)
                  if (DevConfig.showDevBypassButton && DevConfig.isDebugMode)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: TextButton.icon(
                        onPressed: _isLoading ? null : _devBypassVerification,
                        icon: Icon(
                          Icons.bug_report,
                          color: Colors.orange.shade700,
                        ),
                        label: Text(
                          'Skip Verification (Dev Mode)',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Dev mode indicator
                  if (DevConfig.isDebugMode)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.developer_mode,
                            size: 14,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Dev Mode: Email verification bypassed',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Auto-checking indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Auto-checking for verification...',
                          style: TextStyle(color: textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_isVerified) ...[
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.onVerified,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 5,
                        shadowColor: primaryDark.withOpacity(0.5),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
