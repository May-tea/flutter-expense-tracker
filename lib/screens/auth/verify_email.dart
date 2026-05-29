import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils/screen_utils.dart';
import 'widgets/auth_snack_bar.dart';

final _firebase = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key, required this.email});

  final String email;

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await _firebase.currentUser?.reload();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = 60;

    _timer?.cancel();

    _timer = .periodic(const .new(milliseconds: 1000), (timer) {
      if (_resendCooldown == 0) {
        timer.cancel();
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    try {
      await _firebase.currentUser?.reload();

      final updatedUser = _firebase.currentUser;

      if (updatedUser != null && updatedUser.emailVerified) {
        await _firestore.collection('users').doc(updatedUser.uid).update({
          'isVerified': true,
        });

        if (!mounted) return;
        AuthSnackBar.show(
          context,
          isError: false,
          message: 'Email verified successfully',
        );
      } else {
        if (!mounted) return;
        AuthSnackBar.show(
          context,
          isError: true,
          message: 'Your email is not verified yet.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;

    setState(() => _isResending = true);

    try {
      final user = _firebase.currentUser;

      if (user == null) return;

      await user.sendEmailVerification();

      _startResendCooldown();

      if (!mounted) return;
      AuthSnackBar.show(
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

      AuthSnackBar.show(context, isError: true, message: message);
    } finally {
      setState(() => _isResending = false);
    }
  }

  Future<void> _signOut() async {
    await _firebase.signOut();

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context); // 411px
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
              ElevatedButton(
                onPressed: () {
                  if (_isResending || _resendCooldown > 0) return;
                  _resendEmail();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  minimumSize: .fromHeight(screenWidth * 0.12),
                ),
                child: _isResending
                    ? SizedBox(
                        width: screenWidth * 0.049,
                        height: screenWidth * 0.049,
                        child: CircularProgressIndicator(
                          strokeWidth: screenWidth * 0.006,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        _resendCooldown > 0
                            ? 'Resend in $_resendCooldown s'
                            : 'Resend Email',
                        style: .new(color: colorScheme.onPrimary),
                      ),
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
