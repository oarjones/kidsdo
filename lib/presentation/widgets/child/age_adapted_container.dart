import 'package:flutter/material.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';

/// Widget contenedor que adapta su apariencia y contenido según la edad del niño
class AgeAdaptedContainer extends StatelessWidget {
  /// Edad del niño
  final int childAge;

  /// Widget hijo para niños más pequeños (3-5 años)
  final Widget? youngChildWidget;

  /// Widget hijo para niños intermedios (6-8 años)
  final Widget? midChildWidget;

  /// Widget hijo para niños mayores (9+ años)
  final Widget? olderChildWidget;

  /// Widget hijo por defecto (si no se especifica uno para la edad)
  final Widget defaultWidget;

  /// Opciones adicionales de personalización
  final Map<String, dynamic>? settings;

  /// Tamaño del contenedor
  final double? width;
  final double? height;

  /// Padding interno
  final EdgeInsetsGeometry? padding;

  /// Forma del contenedor
  final BoxShape shape;

  /// Radio de borde si la forma es un rectángulo
  final double borderRadius;

  /// Determina si se aplican animaciones más exageradas para niños pequeños
  final bool animationsEnabled;

  const AgeAdaptedContainer({
    Key? key,
    required this.childAge,
    this.youngChildWidget,
    this.midChildWidget,
    this.olderChildWidget,
    required this.defaultWidget,
    this.settings,
    this.width,
    this.height,
    this.padding,
    this.shape = BoxShape.rectangle,
    this.borderRadius = AppDimensions.borderRadiusLg,
    this.animationsEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      padding: padding ?? _getPaddingByAge(),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(_getBorderRadiusByAge())
            : null,
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(),
            blurRadius: _getShadowBlurRadius(),
            spreadRadius: _getShadowSpreadRadius(),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _getChildWidget(),
    );
  }

  /// Obtiene el widget hijo apropiado según la edad
  Widget _getChildWidget() {
    // Niños pequeños (3-5 años)
    if (childAge <= 5 && youngChildWidget != null) {
      return youngChildWidget!;
    }
    // Niños intermedios (6-8 años)
    else if (childAge <= 8 && midChildWidget != null) {
      return midChildWidget!;
    }
    // Niños mayores (9+ años)
    else if (childAge >= 9 && olderChildWidget != null) {
      return olderChildWidget!;
    }
    // Widget por defecto
    else {
      return defaultWidget;
    }
  }

  /// Obtiene el padding apropiado según la edad
  EdgeInsetsGeometry _getPaddingByAge() {
    if (childAge <= 5) {
      // Niños pequeños: padding más grande
      return const EdgeInsets.all(AppDimensions.lg);
    } else if (childAge <= 8) {
      // Niños intermedios: padding medio
      return const EdgeInsets.all(AppDimensions.md);
    } else {
      // Niños mayores: padding estándar
      return const EdgeInsets.all(AppDimensions.sm);
    }
  }

  /// Obtiene el radio de borde apropiado según la edad
  double _getBorderRadiusByAge() {
    if (childAge <= 5) {
      // Niños pequeños: bordes más redondeados
      return borderRadius * 1.5;
    } else if (childAge <= 8) {
      // Niños intermedios: bordes redondeados estándar
      return borderRadius;
    } else {
      // Niños mayores: bordes menos redondeados
      return borderRadius * 0.8;
    }
  }

  /// Obtiene el color de fondo apropiado
  Color _getBackgroundColor() {
    // Usar el color del tema de configuración si está disponible
    final String themeColor = settings?['color'] as String? ?? 'blue';

    // Obtener color base
    Color baseColor = _getColorFromTheme(themeColor);

    // Ajustar opacidad según edad
    double opacity = childAge <= 5 ? 0.2 : (childAge <= 8 ? 0.15 : 0.1);

    return baseColor.withValues(alpha: opacity);
  }

  /// Obtiene el color de sombra apropiado
  Color _getShadowColor() {
    // Usar el color del tema de configuración si está disponible
    final String themeColor = settings?['color'] as String? ?? 'blue';

    // Obtener color base
    Color baseColor = _getColorFromTheme(themeColor);

    // Ajustar opacidad según edad
    double opacity = childAge <= 5 ? 0.3 : (childAge <= 8 ? 0.2 : 0.1);

    return baseColor.withValues(alpha: opacity);
  }

  /// Obtiene el radio de desenfoque de sombra apropiado según la edad
  double _getShadowBlurRadius() {
    if (childAge <= 5) {
      // Niños pequeños: sombras más grandes
      return 10.0;
    } else if (childAge <= 8) {
      // Niños intermedios: sombras estándar
      return 6.0;
    } else {
      // Niños mayores: sombras más sutiles
      return 4.0;
    }
  }

  /// Obtiene el radio de dispersión de sombra apropiado según la edad
  double _getShadowSpreadRadius() {
    if (childAge <= 5) {
      // Niños pequeños: sombras más amplias
      return 2.0;
    } else if (childAge <= 8) {
      // Niños intermedios: sombras estándar
      return 1.0;
    } else {
      // Niños mayores: sombras más sutiles
      return 0.5;
    }
  }

  /// Obtiene el color a partir del tema seleccionado
  Color _getColorFromTheme(String themeColor) {
    switch (themeColor) {
      case 'purple':
        return AppColors.childPurple;
      case 'green':
        return AppColors.childGreen;
      case 'orange':
        return AppColors.childOrange;
      case 'pink':
        return AppColors.childPink;
      case 'blue':
      default:
        return AppColors.childBlue;
    }
  }
}
