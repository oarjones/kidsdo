import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/presentation/controllers/language_controller.dart';

class LanguageSelectorAuth extends StatelessWidget {
  const LanguageSelectorAuth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LanguageController controller = Get.find<LanguageController>();

    // Utilizamos GetBuilder en lugar de Obx para manejar actualizaciones
    return GetBuilder<LanguageController>(
      init: controller,
      builder: (controller) {
        final currentLanguage = Get.locale?.languageCode ?? 'es';

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLanguageOption(
              code: 'es',
              name: 'Español',
              isSelected: currentLanguage == 'es',
              onTap: controller.changeToSpanish,
            ),
            const SizedBox(width: AppDimensions.md),
            _buildLanguageOption(
              code: 'en',
              name: 'English',
              isSelected: currentLanguage == 'en',
              onTap: controller.changeToEnglish,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required String code,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(AppDimensions.borderRadiusCircular),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              _getFlagEmoji(code),
              style: const TextStyle(
                fontSize: AppDimensions.fontMd,
              ),
            ),
            const SizedBox(width: AppDimensions.xs),
            Text(
              name,
              style: TextStyle(
                fontSize: AppDimensions.fontSm,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textMedium,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppDimensions.xs),
              const Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Obtener el emoji de la bandera a partir del código de idioma
  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'es':
        return '🇪🇸'; // Bandera de España
      case 'en':
        return '🇺🇸'; // Bandera de Estados Unidos
      default:
        return '🌐'; // Globo como fallback
    }
  }
}
