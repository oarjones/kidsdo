import 'package:flutter/material.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';

/// Tema específico para las pantallas de autenticación
class AuthTheme {
  // Tema para los contenedores de autenticación
  static BoxDecoration get containerDecoration {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Tema para los textos de título
  static TextStyle get titleStyle {
    return const TextStyle(
      fontSize: AppDimensions.fontHeading,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
    );
  }

  // Tema para los subtítulos
  static TextStyle get subtitleStyle {
    return const TextStyle(
      fontSize: AppDimensions.fontMd,
      color: AppColors.textMedium,
    );
  }

  // Tema para los textos de links
  static TextStyle get linkStyle {
    return const TextStyle(
      fontSize: AppDimensions.fontMd,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    );
  }

  // Tema para el fondo con degradado
  static BoxDecoration get gradientBackground {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF5C6BC0), // Indigo primario
          Color(0xFF3949AB), // Indigo más oscuro
        ],
      ),
    );
  }

  // Tema para la tarjeta de autenticación con fondo blanco
  static BoxDecoration get authCardDecoration {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    );
  }

  // Estilo para el divider con texto
  static Widget dividerWithText(String text) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.textLight,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textMedium,
              fontSize: AppDimensions.fontSm,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.textLight,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
