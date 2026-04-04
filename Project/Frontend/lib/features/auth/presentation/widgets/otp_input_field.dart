import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable OTP input widget with 6 individual boxes
///
/// Features:
/// - Auto-focuses next box on input
/// - Backspace goes to previous box
/// - Paste support for full OTP
/// - Green border on filled boxes
/// - Error state with red border and shake animation
/// - Auto-submit callback when all 6 filled
class OtpInputField extends StatefulWidget {
  /// Number of OTP digits (default: 6)
  final int length;

  /// Callback when OTP is complete
  final VoidCallback? onCompleted;

  /// Callback when OTP changes
  final ValueChanged<String>? onChanged;

  /// Error message to display
  final String? errorText;

  /// Whether the input is enabled
  final bool enabled;

  /// Auto-submit when all digits are entered
  final bool autoSubmit;

  const OtpInputField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.autoSubmit = true,
  });

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField>
    with SingleTickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    // Shake animation for error
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  /// Get the current OTP value
  String get otp => _controllers.map((c) => c.text).join();

  /// Clear all fields
  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  /// Set OTP value (for testing or paste)
  void setOtp(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    for (int i = 0; i < widget.length && i < digits.length; i++) {
      _controllers[i].text = digits[i];
    }
    _handleChange();
  }

  /// Trigger error shake animation
  void showError() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  void _handleChange() {
    final otpValue = otp;
    widget.onChanged?.call(otpValue);

    if (otpValue.length == widget.length && widget.autoSubmit) {
      widget.onCompleted?.call();
    }
  }

  void _onKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      }
    }
  }

  void _onPaste(int index, ClipboardData? data) {
    if (data == null) return;
    final text = data.text?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    if (text.isEmpty) return;

    for (int i = 0; i < widget.length && i < text.length; i++) {
      _controllers[i].text = text[i];
    }

    final nextEmptyIndex = _controllers.indexWhere((c) => c.text.isEmpty);
    if (nextEmptyIndex != -1) {
      _focusNodes[nextEmptyIndex].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }

    _handleChange();
  }

  @override
  Widget build(BuildContext context) {
    final primaryDark = const Color(0xFF1B5A27);
    final hasError = widget.errorText != null;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * (hasError ? 1 : 0), 0),
          child: child,
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.length, (index) {
              return _buildOtpBox(
                index: index,
                primaryDark: primaryDark,
                hasError: hasError,
              );
            }),
          ),
          if (hasError) ...[
            const SizedBox(height: 8),
            Text(
              widget.errorText!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtpBox({
    required int index,
    required Color primaryDark,
    required bool hasError,
  }) {
    return SizedBox(
      width: 50,
      height: 60,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) => _onKeyPressed(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E2F),
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: widget.enabled ? Colors.white : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red.shade400
                    : Colors.grey.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade400 : primaryDark,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < widget.length - 1) {
              _focusNodes[index + 1].requestFocus();
            }
            _handleChange();
          },
          onSubmitted: (_) {
            if (index < widget.length - 1) {
              _focusNodes[index + 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}
