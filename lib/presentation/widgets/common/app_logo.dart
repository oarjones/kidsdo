// lib/presentation/widgets/common/app_logo.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SvgPicture
import 'package:get/get.dart'; // Solo si usas TrKeys.appSlogan y GetX para traducciones
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart'; // Para TrKeys.appSlogan

class AppLogo extends StatelessWidget {
  final double size;
  // final bool showText; // Eliminado, ya que el texto está en el SVG
  final bool showSlogan;
  final Color? sloganColor; // Color opcional para el eslogan

  const AppLogo({
    Key? key,
    this.size = 80, // Default size for the SVG image itself
    // this.showText = false, // No longer needed, default to false or remove
    this.showSlogan = false,
    this.sloganColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveSloganColor = sloganColor ?? AppColors.textMedium;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // SVG Logo (que ya incluye el nombre "KidsDo")
        SvgPicture.asset(
          'assets/images/kidsdo_logo.svg', // Path to your SVG logo
          width: size,
          height: size,
          semanticsLabel: 'KidsDo Logo', // Accessibility label
        ),

        // El Text widget para TrKeys.appName se elimina de aquí

        if (showSlogan) ...[
          const SizedBox(
              height: AppDimensions.md), // Espacio entre logo y eslogan
          // Slogan
          Text(
            TrKeys.appSlogan
                .tr, // Asegúrate de que esta clave exista en tus traducciones
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily:
                  'Poppins', // Asumiendo que Poppins es la fuente de tu app
              fontSize:
                  size * 0.12, // Ajusta la proporción según el balance visual
              color: effectiveSloganColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
