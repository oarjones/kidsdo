// lib/presentation/widgets/common/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';

class BottomNavItem {
  final String labelKey;
  final String svgAssetPath;

  const BottomNavItem({
    required this.labelKey,
    required this.svgAssetPath,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  final double iconSizeInactive = AppDimensions.iconLg + 2.0; // 34.0 dp
  final double iconSizeActive = 42.0;
  final double labelFontSizeInactive = AppDimensions.fontXs + 1.0; // 13.0 dp
  final double labelFontSizeActive = AppDimensions.fontSm; // 14.0 dp

  // Altura base de la barra de navegación.
  // Aumentamos un poco para dar más espacio vertical y compensar el padding del sistema.
  final double navBarBaseHeight = 70.0;

  const CustomBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : assert(items.length >= 2 && items.length <= 5,
            "Items length must be between 2 and 5");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // `viewPadding` incluye obstrucciones como la barra de estado y la barra de navegación inferior del sistema.
    // `viewInsets` incluye obstrucciones como el teclado.
    // Para la barra de navegación, `viewPadding.bottom` es más relevante que `padding.bottom`.
    final double systemBottomSafeArea =
        MediaQuery.of(context).viewPadding.bottom;

    const Color activeColor = AppColors.primary;
    const Color inactiveColor = AppColors.textMedium;
    const Color backgroundColor =
        AppColors.navigationBackground; // Ej: Colors.white o Colors.grey[50]
    const Color borderColor = AppColors.navigationBorder;

    return Container(
      // La altura total será la altura base MÁS el padding de la zona segura inferior del sistema.
      height: navBarBaseHeight + systemBottomSafeArea,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(
          top: BorderSide(color: borderColor, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, -2.5),
          ),
        ],
      ),
      // El Row en sí no necesita padding inferior si el Container ya tiene la altura correcta.
      // El padding se aplicará DENTRO de cada item para el contenido (icono y texto).
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isActive = index == currentIndex;

          final double targetIconSize =
              isActive ? iconSizeActive : iconSizeInactive;
          final Color currentIconColor = isActive ? activeColor : inactiveColor;
          final Color currentLabelColor =
              isActive ? activeColor : inactiveColor;
          final FontWeight currentLabelWeight =
              isActive ? FontWeight.bold : FontWeight.w500;
          final double currentLabelSize =
              isActive ? labelFontSizeActive : labelFontSizeInactive;

          const Duration animationDuration = Duration(milliseconds: 300);
          const Curve animationCurve = Curves.easeOutCubic;

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTap(index),
                splashColor: activeColor.withValues(alpha: 0.12),
                highlightColor: activeColor.withValues(alpha: 0.06),
                child: Padding(
                  // Padding vertical para centrar el contenido y respetar la safe area inferior.
                  // El padding inferior del sistema ya está considerado en la altura del Container.
                  // Lo que necesitamos es que el contenido del Column no se dibuje sobre esa área.
                  padding: EdgeInsets.only(
                    top: AppDimensions.xs, // Pequeño padding superior
                    // Añadimos el systemBottomSafeArea al padding inferior del contenido del item
                    // para asegurar que el texto no quede debajo de la barra de sistema.
                    bottom: systemBottomSafeArea > 0
                        ? systemBottomSafeArea
                        : AppDimensions.xs,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centra el contenido del Column
                    mainAxisSize: MainAxisSize
                        .min, // Para que el Column no intente ocupar más espacio del necesario
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(height: iconSizeActive * 0.95),
                          AnimatedContainer(
                            duration: animationDuration,
                            curve: animationCurve,
                            width: targetIconSize,
                            height: targetIconSize,
                            transform: isActive
                                ? Matrix4.translationValues(
                                    0, -(targetIconSize * 0.30), 0)
                                : Matrix4.identity(),
                            transformAlignment: Alignment.center,
                            child: SvgPicture.asset(
                              item.svgAssetPath,
                              width: targetIconSize,
                              height: targetIconSize,
                              colorFilter: ColorFilter.mode(
                                  currentIconColor, BlendMode.srcIn),
                              semanticsLabel: Tr.t(item.labelKey),
                            ),
                          ),
                        ],
                      ),
                      AnimatedContainer(
                        // Contenedor para animar la transformación del texto
                        duration: animationDuration,
                        curve: animationCurve,
                        transform: isActive
                            ? Matrix4.translationValues(
                                0, -(targetIconSize * 0.22), 0)
                            : Matrix4.identity(),
                        transformAlignment: Alignment.center,
                        child: AnimatedDefaultTextStyle(
                          duration:
                              animationDuration, // La duración del estilo puede ser más corta
                          style: theme.textTheme.bodySmall!.copyWith(
                            fontSize: currentLabelSize,
                            color: currentLabelColor,
                            fontWeight: currentLabelWeight,
                          ),
                          curve: animationCurve,
                          child: Text(
                            Tr.t(item.labelKey),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
