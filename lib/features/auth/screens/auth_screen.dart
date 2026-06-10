import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../core/validators/app_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../widgets/auth_text_form_field.dart';
import '../services/auth_service.dart';
import '../utils/auth_error_mapper.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = .instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = .new();
  final TextEditingController _usernameController = .new();
  final TextEditingController _passwordController = .new();

  AutovalidateMode _autoValidateMode = .disabled;
  bool _isLogin = true;
  bool _isAuthenticating = false;

  int _resetPasswordCooldown = 0;
  Timer? _resetPasswordTimer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();

      final savedMillis = prefs.getInt(AuthConstants.resetPasswordKey);

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
        await _authService.signIn(email: email, password: password);
      } else {
        await _authService.signUp(
          email: email,
          password: password,
          username: username,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = AuthErrorMapper.message(e.code);

      AppSnackBar.show(context, isError: true, message: message);
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
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

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      AppSnackBar.show(
        context,
        isError: true,
        message: 'Please enter your email first.',
      );
      return;
    }

    try {
      await _authService.resetPassword(email: email);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(
        AuthConstants.resetPasswordKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      setState(() => _resetPasswordCooldown = 60);

      _startResetPasswordCooldown();

      if (!mounted) return;

      AppSnackBar.show(
        context,
        isError: false,
        message:
            'If an account exists for this email, a reset link has been sent.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      AppSnackBar.show(
        context,
        isError: true,
        message: AuthErrorMapper.message(e.code),
      );
    } catch (_) {
      if (!mounted) return;

      AppSnackBar.show(context, isError: true, message: 'Something went wrong');
    }
  }

  void _toggleAuthMode() {
    if (_isAuthenticating) return;

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
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
                _isLogin ? AuthConstants.signIn : 'Create Account',
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
                      text: _isLogin ? 'Create now' : AuthConstants.signIn,
                      style: .new(
                        decoration: .underline,
                        decorationColor: colorScheme.primary,
                        color: _isAuthenticating
                            ? colorScheme.outline
                            : colorScheme.primary,
                        fontWeight: .bold,
                      ),
                      recognizer: _isAuthenticating
                          ? null
                          : (TapGestureRecognizer()..onTap = _toggleAuthMode),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: .symmetric(vertical: screenWidth * 0.097),
                child: AnimatedOpacity(
                  duration: const .new(milliseconds: 200),
                  opacity: _isAuthenticating ? 0.6 : 1,
                  child: AbsorbPointer(
                    absorbing: _isAuthenticating,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autoValidateMode,
                      child: Column(
                        spacing: screenWidth * 0.058,
                        children: [
                          AuthTextFormField(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: .emailAddress,
                            autofillHints: const [AutofillHints.email],
                            validator: AppValidators.email,
                          ),
                          AnimatedSize(
                            duration: const .new(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: _isLogin
                                ? const SizedBox()
                                : AuthTextFormField(
                                    label: 'Username',
                                    controller: _usernameController,
                                    keyboardType: .name,
                                    autofillHints: const [
                                      AutofillHints.username,
                                    ],
                                    textCapitalization: .sentences,
                                    validator: AppValidators.username,
                                  ),
                          ),
                          AuthTextFormField(
                            label: 'Password',
                            controller: _passwordController,
                            isPasswordFormField: true,
                            autofillHints: const [AutofillHints.password],
                            validator: AppValidators.password,
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
                ),
              ),
              AppButton(
                label: _isLogin ? AuthConstants.signIn : 'Sign Up',
                isLoading: _isAuthenticating,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
