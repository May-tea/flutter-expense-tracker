import 'package:flutter/material.dart';

import 'auth_input_decoration.dart';

class AuthTextFormField extends StatefulWidget {
  const AuthTextFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.autofillHints,
    this.textCapitalization = .none,
    this.isPasswordFormField = false,
  });

  final String label;
  final TextEditingController controller;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;
  final bool isPasswordFormField;
  final String? Function(String?)? validator;

  @override
  State<AuthTextFormField> createState() => _AuthTextFormFieldState();
}

class _AuthTextFormFieldState extends State<AuthTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(widget.label),
      controller: widget.controller,
      autocorrect: false,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      keyboardType: widget.keyboardType,
      enableSuggestions: false,
      obscureText: widget.isPasswordFormField ? _obscureText : false,
      decoration: AuthInputDecoration.build(
        context,
        label: widget.label,
        suffixIcon: widget.isPasswordFormField
            ? IconButton(
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : null,
      ),
      validator: widget.validator,
    );
  }
}
