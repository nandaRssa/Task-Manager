// ─────────────────────────────────────────────────────────────────────────────
// app_text_field.dart
// Styled text field yang dipakai di semua form.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool readOnly;
  final void Function()? onTap;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.textInputAction,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller       : controller,
      obscureText      : obscureText,
      keyboardType     : keyboardType,
      validator        : validator,
      maxLines         : maxLines,
      textInputAction  : textInputAction,
      onFieldSubmitted : onFieldSubmitted,
      readOnly         : readOnly,
      onTap            : onTap,
      style            : const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText   : label,
        hintText    : hint,
        prefixIcon  : prefixIcon,
        suffixIcon  : suffixIcon,
        filled      : true,
        fillColor   : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border      : OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide  : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide  : BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide  : BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide  : BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide  : BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical  : maxLines > 1 ? 16 : 0,
        ),
      ),
    );
  }
}
