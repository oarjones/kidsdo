import 'package:flutter/material.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';

enum AuthButtonType { primary, secondary, social }

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AuthButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double iconSize;
  final Color? backgroundColor;
  final Color? textColor;

  const AuthButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = AuthButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.iconSize = 24,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingButton();
    }

    switch (type) {
      case AuthButtonType.primary:
        return _buildPrimaryButton();
      case AuthButtonType.secondary:
        return _buildSecondaryButton();
      case AuthButtonType.social:
        return _buildSocialButton();
    }
  }

  Widget _buildLoadingButton() {
    return SizedBox(
      height: AppDimensions.buttonChildHeight,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? AppColors.primary.withValues(alpha: 0.7),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      height: AppDimensions.buttonChildHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: AppDimensions.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return SizedBox(
      height: AppDimensions.buttonChildHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          side: BorderSide(color: backgroundColor ?? AppColors.primary),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: AppDimensions.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton() {
    return SizedBox(
      height: AppDimensions.buttonChildHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon ?? Icons.login,
          size: iconSize,
          color: backgroundColor ?? Colors.black87,
        ),
        label: Text(
          text,
          style: TextStyle(
            fontSize: AppDimensions.fontMd,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.black87,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: backgroundColor != null
                ? backgroundColor!.withValues(alpha: 0.3)
                : Colors.grey.shade300,
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
