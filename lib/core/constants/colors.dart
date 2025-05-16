import 'package:flutter/material.dart';

class AppColors {
  // Colores principales
  static const primary = Color(0xFF5C6BC0); // Indigo
  static const secondary = Color(0xFF26C6DA); // Cyan
  static const tertiary = Color(0xFFFFCA28); // Amber

  // Colores funcionales
  static const success = Color(0xFF66BB6A); // Verde
  static const warning = Color(0xFFFFB74D); // Naranja
  static const error = Color(0xFFEF5350); // Rojo
  static const info = Color(0xFF42A5F5); // Azul

  // Colores de texto (Light Theme)
  static const textDark = Color(0xFF212121); // Casi negro
  static const textMedium = Color(0xFF757575); // Gris medio
  static const textLight = Color(0xFFBDBDBD); // Gris claro

  // Colores de texto (Dark Theme)
  static const textLightDark = Color(0xFF9E9E9E); // Gris medio para dark mode

  // Colores de fondo (Light Theme)
  static const background = Color(0xFFF5F5F5); // Gris muy claro
  static const card = Colors.white; // Blanco
  static const inputFill = Color(0xFFF0F0F0); // Gris claro para inputs

  // Colores de fondo (Dark Theme)
  static const backgroundDark = Color(0xFF121212); // Negro material
  static const cardDark = Color(0xFF1E1E1E); // Gris muy oscuro
  static const inputFillDark = Color(0xFF2C2C2C); // Gris oscuro para inputs

  // Colores para gamificación
  static const bronze = Color(0xFFCD7F32); // Bronce
  static const silver = Color(0xFFC0C0C0); // Plata
  static const gold = Color(0xFFFFD700); // Oro

  // Colores para interfaces infantiles
  static const childPurple = Color(0xFF9C27B0);
  static const childBlue = Color(0xFF1E88E5);
  static const childGreen = Color(0xFF43A047);
  static const childOrange = Color(0xFFEF6C00);
  static const childPink = Color(0xFFEC407A);

  // Añadir estos colores para mejorar el contraste de la navegación
  static const navigationSelected =
      primary; // Usar el color primario para consistencia
  static const navigationUnselected = Color(
      0xFF757575); // Gris más oscuro para mejor contraste (antes era muy claro)
  static const navigationBackground = Colors.white;
  static const navigationBorder =
      Color(0xFFE0E0E0); // Borde sutil para mejor definición

  // Versiones claras de los colores principales (para fondos, chips, etc.)
  static const primaryLight = Color(0xFFE8EAF6); // Indigo 50
  static const secondaryLight = Color(0xFFE0F7FA); // Cyan 50
  static const tertiaryLight = Color(0xFFFFF8E1); // Amber 50

  // Versiones claras de colores funcionales
  static const successLight = Color(0xFFE8F5E9); // Verde 50
  static const warningLight = Color(0xFFFFF3E0); // Naranja 50
  static const errorLight = Color(0xFFFFEBEE); // Rojo 50
  static const infoLight = Color(0xFFE3F2FD); // Azul 50

  // Colores de estado para retos asignados (AssignedChallengeStatus)
  static const Color statusActive = Color(0xFF007BFF); // Azul brillante
  static const Color statusCompleted = Color(0xFF28A745); // Verde éxito
  static const Color statusFailed = Color(0xFFDC3545); // Rojo peligro
  static const Color statusPending =
      Color(0xFFFFC107); // Naranja/Amarillo advertencia
  static const Color statusInactive =
      Color(0xFF6c757d); // Gris para inactivo (ejemplo)

  static const systemNavBarColor =
      Color(0xFF212121); // Un gris muy oscuro, casi negro
}
