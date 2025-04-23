import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final bool autoValidate;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.validator,
    this.errorText,
    this.autoValidate = false,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: obscureText && onToggleVisibility != null
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        errorText: errorText,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      enabled: enabled,
      validator: validator,
      autovalidateMode: autoValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onFieldSubmitted: onSubmitted,
    );
  }
}
