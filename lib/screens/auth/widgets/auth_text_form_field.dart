import 'package:flutter/material.dart';

import '../../../utils/screen_utils.dart';

class AuthTextFormField extends StatefulWidget {
  const AuthTextFormField({
    super.key,
    required this._formKey,
    required this._controller,
    required this._textCapitalization,
    required this._autofillHints,
    required this._keyboardType,
    this._isPasswordFormField = false,
    required this._validator,
  });

  final String _formKey;
  final TextEditingController _controller;
  final TextCapitalization _textCapitalization;
  final Iterable<String> _autofillHints;
  final TextInputType? _keyboardType;
  final bool? _isPasswordFormField;
  final String? Function(String?)? _validator;

  @override
  State<AuthTextFormField> createState() => _AuthTextFormFieldState();
}

class _AuthTextFormFieldState extends State<AuthTextFormField> {
  bool _obscureText = true;

  InputDecoration _inputDecoration(String label, BuildContext context) {
    final screenWidth = ScreenUtils.width(context); // 411px
    final colorScheme = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
      borderRadius: .circular(screenWidth * 0.024),
    );

    return InputDecoration(
      label: Text(
        label,
        style: .new(
          fontSize: screenWidth * 0.035,
          color: colorScheme.secondary,
        ),
      ),
      focusedBorder: border.copyWith(
        borderSide: .new(color: colorScheme.primary, width: 2),
      ),
      enabledBorder: border.copyWith(
        borderSide: .new(color: colorScheme.primary, width: 1.25),
      ),
      errorBorder: border.copyWith(
        borderSide: .new(color: colorScheme.error, width: 1.25),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: .new(color: colorScheme.error, width: 2),
      ),
      suffixIcon: widget._isPasswordFormField!
          ? IconButton(
              onPressed: () {
                setState(() => _obscureText = !_obscureText);
              },
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(widget._formKey),
      controller: widget._controller,
      autocorrect: false,
      textCapitalization: widget._textCapitalization,
      autofillHints: widget._autofillHints,
      keyboardType: widget._keyboardType,
      enableSuggestions: false,
      obscureText: widget._isPasswordFormField! ? _obscureText : false,
      decoration: _inputDecoration(widget._formKey, context),
      validator: widget._validator,
    );
  }
}
