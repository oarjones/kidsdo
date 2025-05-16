import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/routes.dart';

class TimeRestrictionWidget extends StatelessWidget {
  final String message;
  final bool showHomeButton;

  const TimeRestrictionWidget({
    Key? key,
    required this.message,
    this.showHomeButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icono de bloqueo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time,
                  size: 60,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: AppDimensions.lg),

              // Título
              Text(
                'time_restriction_title'.tr,
                style: const TextStyle(
                  fontSize: AppDimensions.fontXl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.md),

              // Mensaje
              Text(
                message,
                style: const TextStyle(
                  fontSize: AppDimensions.fontLg,
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xl),

              // Sugerencia
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 20),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusLg),
                ),
                child: Column(
                  children: [
                    Text(
                      'time_restriction_suggestion'.tr,
                      style: TextStyle(
                        fontSize: AppDimensions.fontMd,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info.withValues(alpha: 200),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'time_restriction_suggestion_detail'.tr,
                      style: TextStyle(
                        fontSize: AppDimensions.fontSm,
                        color: AppColors.info.withValues(alpha: 200),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Botón para volver al inicio
              if (showHomeButton)
                ElevatedButton.icon(
                  onPressed: () => Get.offAllNamed(Routes.mainParent),
                  icon: const Icon(Icons.home),
                  label: Text('go_to_home'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.md,
                      horizontal: AppDimensions.lg,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
