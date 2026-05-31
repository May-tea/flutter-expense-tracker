import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  // Services
  final AuthService _authService = .instance;
  final UserService _userService = .instance;

  // UI State
  bool _isChecking = false;
  bool _isResending = false;

  // Cooldown
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _loadCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  Future<void> _loadCooldown() async {
    final remaining = await _userService.getVerificationEmailCooldown();

    if (!mounted) return;

    if (remaining > 0) {
      setState(() => _resendCooldown = remaining);

      _startResendCooldown(remaining);
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    try {
      final isVerified = await _authService.isEmailVerified();

      if (isVerified) {
        if (!mounted) return;

        AppSnackBar.show(
          context,
          isError: false,
          message: 'Email verified successfully',
        );

        await _userService.markUserAsVerified();
      } else {
        if (!mounted) return;

        AppSnackBar.show(
          context,
          isError: true,
          message: 'Your email is not verified yet.',
        );
      }
    } on FirebaseException catch (_) {
      if (!mounted) return;

      AppSnackBar.show(
        context,
        isError: true,
        message: 'Something went wrong.',
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _startResendCooldown([int? seconds]) {
    if (seconds != null) {
      _resendCooldown = seconds;
    }

    _timer?.cancel();

    _timer = .periodic(const .new(seconds: 1), (timer) {
      if (_resendCooldown <= 0) {
        timer.cancel();
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;

    setState(() => _isResending = true);

    try {
      await _authService.resendVerificationEmail();

      _startResendCooldown(AuthConstants.verificationCooldownSeconds);

      if (!mounted) return;

      AppSnackBar.show(
        context,
        isError: false,
        message: 'Verification email sent again.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Something went wrong.';

      if (e.code == 'too-many-requests') {
        message = 'Please wait before requesting another email';
      }

      AppSnackBar.show(context, isError: true, message: message);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        automaticallyImplyLeading: false,
        title: Text(
          'Verify your email',
          style: .new(color: colorScheme.onPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: Icon(Icons.logout, color: colorScheme.onPrimary),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: .symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: .stretch,
            mainAxisSize: .min,
            children: [
              Icon(Icons.email_outlined, size: screenWidth * 0.2),
              SizedBox(height: screenWidth * 0.049),
              Text(
                'We sent a verification email to:\n${widget.email}',
                textAlign: .center,
                style: .new(fontSize: screenWidth * 0.042),
              ),
              SizedBox(height: screenWidth * 0.049),
              Text(
                'Please verify your email to continue.',
                textAlign: .center,
                style: .new(fontSize: screenWidth * 0.042),
              ),
              SizedBox(height: screenWidth * 0.073),
              AppButton(
                label: _resendCooldown > 0
                    ? 'Resend in $_resendCooldown s'
                    : 'Resend Email',
                isLoading: _isResending,
                onPressed: _resendEmail,
              ),
              SizedBox(height: screenWidth * 0.03),
              TextButton(
                onPressed: _isChecking ? null : _checkVerification,
                child: _isChecking
                    ? SizedBox(
                        width: screenWidth * 0.049,
                        height: screenWidth * 0.049,
                        child: CircularProgressIndicator(
                          strokeWidth: screenWidth * 0.006,
                        ),
                      )
                    : const Text('I have verified'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
