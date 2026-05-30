import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/screen_utils.dart';
import 'widgets/auth_exception.dart';
import 'widgets/auth_snack_bar.dart';
import 'widgets/auth_text_form_field.dart';

final _firebase = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  AutovalidateMode _autoValidateMode = .disabled;
  bool _isLogin = true;
  bool _isAuthenticating = false;
  int _resetPasswordCooldown = 0;
  Timer? _resetPasswordTimer;
  static const _resetPasswordKey = 'last_password_reset_sent_at';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();

      final savedMillis = prefs.getInt(_resetPasswordKey);

      if (savedMillis == null) return;

      final sentAt = DateTime.fromMillisecondsSinceEpoch(savedMillis);

      final elapsed = DateTime.now().difference(sentAt).inSeconds;

      final remaining = 60 - elapsed;

      if (!mounted) return;
      if (remaining > 0) {
        setState(() => _resetPasswordCooldown = remaining);

        _startResetPasswordCooldown(remaining);
      }
    });
  }

  @override
  void dispose() {
    _resetPasswordTimer?.cancel();

    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _toggleAuthMode() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();

    setState(() {
      _isLogin = !_isLogin;
      _autoValidateMode = .disabled;

      _emailController.clear();
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  void _startResetPasswordCooldown([int? seconds]) {
    if (seconds != null) {
      _resetPasswordCooldown = seconds;
    }

    _resetPasswordTimer?.cancel();

    _resetPasswordTimer = .periodic(const .new(seconds: 1), (timer) {
      if (_resetPasswordCooldown <= 0) {
        timer.cancel();
      } else {
        setState(() => _resetPasswordCooldown--);
      }
    });
  }

  Future<void> _submit() async {
    if (_isAuthenticating) return;

    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      if (_autoValidateMode != AutovalidateMode.onUserInteraction) {
        setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
      }
      return;
    }

    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isAuthenticating = true);

    try {
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredentials.user!;

        await user.updateDisplayName(username);

        await user.sendEmailVerification();

        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'isVerified': false,
          'createdAt': Timestamp.now(),
          'lastVerificationEmailSentAt': Timestamp.now(),
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = AuthException.authErrorMessage(e.code);
      AuthSnackBar.show(context, isError: true, message: message);
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      AuthSnackBar.show(
        context,
        isError: true,
        message: 'Please enter your email first.',
      );
      return;
    }

    try {
      await _firebase.sendPasswordResetEmail(email: email);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(
        _resetPasswordKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      setState(() => _resetPasswordCooldown = 60);

      _startResetPasswordCooldown();

      if (!mounted) return;
      AuthSnackBar.show(
        context,
        isError: false,
        message:
            'If an account exists for this email, a reset link has been sent.',
      );
    } catch (_) {
      if (!mounted) return;
      AuthSnackBar.show(
        context,
        isError: false,
        message:
            'If an account exists for this email, a reset link has been sent.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context); // 411px
    final screenHeight = ScreenUtils.height(context); // 923px
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      body: Center(
        child: Padding(
          padding: .symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: .stretch,
            mainAxisSize: .min,
            children: [
              Text(
                _isLogin ? 'Sign in' : 'Create Account',
                style: .new(fontSize: screenWidth * 0.06, fontWeight: .bold),
              ),
              Text.rich(
                TextSpan(
                  text: _isLogin
                      ? 'Don\'t have an account? '
                      : 'Already have an account? ',
                  style: .new(fontSize: screenWidth * 0.035),
                  children: [
                    TextSpan(
                      text: _isLogin ? 'Create now' : 'Sign in',
                      style: .new(
                        decoration: .underline,
                        decorationColor: colorScheme.primary,
                        color: colorScheme.primary,
                        fontWeight: .bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _toggleAuthMode,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: .symmetric(vertical: screenWidth * 0.097),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidateMode,
                  child: Column(
                    spacing: screenWidth * 0.058,
                    children: [
                      AuthTextFormField(
                        formKey: 'Email',
                        controller: _emailController,
                        textCapitalization: .none,
                        autofillHints: const [AutofillHints.email],
                        keyboardType: .emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Email is required.';
                          }

                          final regex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );

                          if (!regex.hasMatch(email)) {
                            return 'Enter a valid email address.';
                          }

                          return null;
                        },
                      ),
                      AnimatedSize(
                        duration: const .new(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: _isLogin
                            ? const SizedBox()
                            : AuthTextFormField(
                                formKey: 'Username',
                                controller: _usernameController,
                                textCapitalization: .sentences,
                                autofillHints: const [AutofillHints.username],
                                keyboardType: .name,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 4) {
                                    return 'Please enter at least 4 characters.';
                                  }
                                  return null;
                                },
                              ),
                      ),
                      AuthTextFormField(
                        formKey: 'Password',
                        controller: _passwordController,
                        textCapitalization: .sentences,
                        autofillHints: const [AutofillHints.password],
                        keyboardType: .name,
                        isPasswordFormField: true,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                      ),
                      if (_isLogin)
                        Row(
                          mainAxisAlignment: .end,
                          children: [
                            GestureDetector(
                              onTap:
                                  (_isAuthenticating ||
                                      _resetPasswordCooldown > 0)
                                  ? null
                                  : _resetPassword,
                              child: Text(
                                _resetPasswordCooldown > 0
                                    ? 'Reset in $_resetPasswordCooldown s'
                                    : 'Forgot Password?',
                                style: .new(
                                  decoration: .underline,
                                  decorationColor: colorScheme.primary,
                                  fontWeight: .bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_isAuthenticating) return;
                  _submit();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  minimumSize: .fromHeight(screenWidth * 0.12),
                ),
                child: _isAuthenticating
                    ? SizedBox(
                        width: screenWidth * 0.049,
                        height: screenWidth * 0.049,
                        child: CircularProgressIndicator(
                          strokeWidth: screenWidth * 0.006,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        _isLogin ? 'Sign in' : 'Sign up',
                        style: .new(color: colorScheme.onPrimary),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
