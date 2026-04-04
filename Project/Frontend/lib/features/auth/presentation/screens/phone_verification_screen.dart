import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../data/auth_repository.dart';
import '../../data/auth_state_notifier.dart';
import '../widgets/otp_input_field.dart';
import '../../../../core/config/dev_config.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final bool isOptional;
  final VoidCallback? onVerified;
  final VoidCallback? onSkip;

  const PhoneVerificationScreen({
    super.key,
    this.isOptional = true,
    this.onVerified,
    this.onSkip,
  });

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<OtpInputFieldState> _otpKey = GlobalKey<OtpInputFieldState>();
  final AuthRepository _authRepository = AuthRepository();

  // Country code (default India)
  String _countryCode = '+91';
  String _selectedCountryFlag = '🇮🇳';

  // State management
  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;
  String? _successMessage;
  String? _otpError;

  // Timer for resend
  Timer? _resendTimer;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _resendTimer?.cancel();
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

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your phone number';
      });
      return;
    }

    if (phone.length < 10) {
      setState(() {
        _errorMessage = 'Please enter a valid phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final fullPhone = '$_countryCode$phone';
      await _authRepository.sendPhoneOTP(phoneNumber: fullPhone);

      setState(() {
        _otpSent = true;
        _successMessage = 'OTP sent to $fullPhone';
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

  Future<void> _verifyOTP() async {
    final otp = _otpKey.currentState?.otp ?? '';

    if (otp.length != 6) {
      setState(() {
        _otpError = 'Please enter the complete OTP';
      });
      _otpKey.currentState?.showError();
      return;
    }

    setState(() {
      _isLoading = true;
      _otpError = null;
      _errorMessage = null;
    });

    try {
      // Check for developer OTP bypass (only works in debug mode)
      if (DevConfig.isValidDevOtp(otp)) {
        // Dev bypass - skip actual verification
        if (mounted) {
          final authNotifier = context.read<AuthStateNotifier>();
          await authNotifier.refreshProfile();
        }

        setState(() {
          _successMessage = 'Phone verified successfully! (Dev Mode)';
        });

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          widget.onVerified?.call();
        }
        return;
      }

      final fullPhone = '$_countryCode${_phoneController.text.trim()}';
      await _authRepository.verifyPhoneOTP(phoneNumber: fullPhone, otp: otp);

      // Update auth state
      if (mounted) {
        final authNotifier = context.read<AuthStateNotifier>();
        await authNotifier.refreshProfile();
      }

      setState(() {
        _successMessage = 'Phone verified successfully!';
      });

      // Navigate after short delay
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        widget.onVerified?.call();
      }
    } catch (e) {
      setState(() {
        _otpError = e.toString().replaceAll('Exception: ', '');
      });
      _otpKey.currentState?.showError();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changePhoneNumber() {
    setState(() {
      _otpSent = false;
      _errorMessage = null;
      _successMessage = null;
      _otpError = null;
    });
    _otpKey.currentState?.clear();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryDark = const Color(0xFF1B5A27);
    final textGrey = const Color(0xFF5F6E60);
    final bgColor1 = const Color(0xFFEEF9E9);
    final bgColor2 = const Color(0xFFE2F3D9);

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

                const SizedBox(height: 20),

                // Lottie Animation
                SizedBox(
                  height: 150,
                  child: Lottie.asset(
                    'assets/animations/phone_verification.json',
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.phone_android,
                        size: 100,
                        color: primaryDark,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Title
                Text(
                  _otpSent ? 'Verify OTP' : 'Phone Verification',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C3E2F),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _otpSent
                      ? 'Enter the 6-digit code sent to\n$_countryCode${_phoneController.text}'
                      : 'Add your phone number for better\naccount security',
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

                if (!_otpSent) ...[
                  // Phone input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Country code selector
                        GestureDetector(
                          onTap: _showCountryPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 18,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _selectedCountryFlag,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _countryCode,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E2F),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFFB5C1B6),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Phone number',
                              hintStyle: TextStyle(
                                color: Color(0xFFB5C1B6),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Send OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOTP,
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
                                  'Send OTP',
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

                if (_otpSent) ...[
                  // OTP Input
                  OtpInputField(
                    key: _otpKey,
                    length: 6,
                    errorText: _otpError,
                    onCompleted: _verifyOTP,
                  ),

                  const SizedBox(height: 20),

                  // Change number link
                  TextButton(
                    onPressed: _changePhoneNumber,
                    child: Text(
                      'Change phone number',
                      style: TextStyle(
                        color: primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOTP,
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
                                  'Verify',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.check, size: 20),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Resend OTP
                  if (_resendSeconds > 0)
                    Text(
                      'Resend OTP in $_resendSeconds seconds',
                      style: TextStyle(color: textGrey, fontSize: 14),
                    )
                  else
                    TextButton(
                      onPressed: _sendOTP,
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 30),

                // Skip for now (if optional)
                if (widget.isOptional && !_otpSent)
                  TextButton(
                    onPressed: widget.onSkip,
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Country',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E2F),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildCountryOption('🇮🇳', 'India', '+91'),
                    _buildCountryOption('🇺🇸', 'United States', '+1'),
                    _buildCountryOption('🇬🇧', 'United Kingdom', '+44'),
                    _buildCountryOption('🇦🇪', 'UAE', '+971'),
                    _buildCountryOption('🇸🇬', 'Singapore', '+65'),
                    _buildCountryOption('🇦🇺', 'Australia', '+61'),
                    _buildCountryOption('🇨🇦', 'Canada', '+1'),
                    _buildCountryOption('🇩🇪', 'Germany', '+49'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountryOption(String flag, String name, String code) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: Text(code, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
        setState(() {
          _selectedCountryFlag = flag;
          _countryCode = code;
        });
        Navigator.pop(context);
      },
    );
  }
}
