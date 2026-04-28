import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_app/core/router/app_router.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final StreamController<ErrorAnimationType> _errorController = StreamController<ErrorAnimationType>();
  
  int _countdownValue = 60;
  Timer? _timer;
  bool _isResendEnabled = false;
  bool _isConfirmEnabled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _errorController.close();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _countdownValue = 60;
      _isResendEnabled = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue == 0) {
        setState(() {
          _isResendEnabled = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _countdownValue--;
        });
      }
    });
  }

  void _onConfirmPressed() {
    if (_otpController.text.length == 4) {
      // Mock verification success and go to Reset Password
      context.pushNamed(AppRoute.resetPassword.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please enter the 4-digit code sent to your email.',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 64),
            // OTP Fields
            Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
              child: PinCodeTextField(
                appContext: context,
                length: 4,
                obscureText: false,
                animationType: AnimationType.fade,
                backgroundColor: Colors.transparent,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 70,
                  fieldWidth: 65,
                  activeFillColor: Colors.white.withOpacity(0.1),
                  inactiveFillColor: Colors.white.withOpacity(0.05),
                  selectedFillColor: Colors.white.withOpacity(0.15),
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  selectedColor: Colors.white,
                  borderWidth: 1.5,
                ),
                cursorColor: Colors.white,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                errorAnimationController: _errorController,
                controller: _otpController,
                keyboardType: TextInputType.number,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                onCompleted: (v) {
                  setState(() => _isConfirmEnabled = true);
                  _onConfirmPressed(); // Auto-submit
                },
                onChanged: (value) {
                  setState(() {
                    _isConfirmEnabled = value.length == 4;
                  });
                },
                beforeTextPaste: (text) => true,
              ),
            ),
            const SizedBox(height: 32),
            // Resend Timer
            Center(
              child: Column(
                children: [
                  Text(
                    _isResendEnabled ? "Didn't receive code?" : "Resend code in ${_countdownValue}s",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  if (_isResendEnabled)
                    TextButton(
                      onPressed: _startTimer,
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            // Confirm Button
            ElevatedButton(
              onPressed: _isConfirmEnabled ? _onConfirmPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white24,
                disabledForegroundColor: Colors.white54,
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
