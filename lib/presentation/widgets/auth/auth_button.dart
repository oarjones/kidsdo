import 'package:flutter/material.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart'; // Asegúrate de tener AppDimensions.lg y AppDimensions.md aquí

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
    // 1. Quitar SizedBox fijo
    // return SizedBox(
    //   height: AppDimensions.buttonChildHeight,
    //   child: ElevatedButton(
    return ElevatedButton(
      // Directamente el botón
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            backgroundColor ?? AppColors.primary.withValues(alpha: 0.7),
        // 2. Añadir padding explícito si es necesario (opcional)
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg, // Más espacio horizontal
          vertical: AppDimensions.md, // Espacio vertical
        ),
      ),
      child: const Center(
        // Usar un SizedBox para el indicator, pero no para el botón entero
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2.0,
          ),
        ),
      ),
      //   ), // Cierre del SizedBox original
    ); // Cierre del ElevatedButton
  }

  Widget _buildPrimaryButton() {
    // 1. Quitar SizedBox fijo
    // return SizedBox(
    //   height: AppDimensions.buttonChildHeight,
    //   child: ElevatedButton(
    return ElevatedButton(
      // Directamente el botón
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        // 2. Añadir padding explícito si es necesario (opcional)
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg, // Más espacio horizontal
          vertical:
              AppDimensions.md, // Espacio vertical (ajusta según necesites)
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppDimensions.fontMd,
          fontWeight: FontWeight.w600,
        ),
      ),
      //   ), // Cierre del SizedBox original
    ); // Cierre del ElevatedButton
  }

  Widget _buildSecondaryButton() {
    // 1. Quitar SizedBox fijo
    // return SizedBox(
    //   height: AppDimensions.buttonChildHeight,
    //   child: OutlinedButton(
    return OutlinedButton(
      // Directamente el botón
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        side: BorderSide(color: backgroundColor ?? AppColors.primary),
        // 2. Añadir padding explícito si es necesario (opcional)
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg, // Más espacio horizontal
          vertical: AppDimensions.md, // Espacio vertical
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppDimensions.fontMd,
          fontWeight: FontWeight.w600,
        ),
      ),
      //   ), // Cierre del SizedBox original
    ); // Cierre del OutlinedButton
  }

  Widget _buildSocialButton() {
    // 1. Quitar SizedBox fijo
    // return SizedBox(
    //   height: AppDimensions.buttonChildHeight,
    //   child: OutlinedButton.icon(
    return OutlinedButton.icon(
      // Directamente el botón
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
              ? backgroundColor!
                  .withAlpha(77) // Ajustado alpha para visibilidad
              : Colors.grey.shade300,
        ),
        backgroundColor: Colors.white,
        // 2. Añadir padding explícito si es necesario (opcional)
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg, // Más espacio horizontal
          vertical: AppDimensions.md, // Espacio vertical
        ),
      ),
      //   ), // Cierre del SizedBox original
    ); // Cierre del OutlinedButton.icon
  }
}
