import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showSlogan;

  const AppLogo({
    Key? key,
    this.size = 80,
    this.showText = true,
    this.showSlogan = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo animado/gradiente
        Container(
          height: size * 1.5,
          width: size * 1.5,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Colors.white,
                AppColors.primary,
              ],
              stops: [0.3, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.child_care,
              size: size,
              color: Colors.white,
            ),
          ),
        ),

        if (showText) ...[
          const SizedBox(height: AppDimensions.md),
          // Nombre de la aplicación
          Text(
            TrKeys.appName.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size / 2,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),

          if (showSlogan) ...[
            const SizedBox(height: AppDimensions.sm),
            // Eslogan
            Text(
              'app_slogan'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size / 4,
                color: AppColors.textMedium,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
