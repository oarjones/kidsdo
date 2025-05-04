import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/challenge.dart';

class DurationSelectorWidget extends StatelessWidget {
  final Rx<ChallengeDuration> selectedDuration;
  final ValueChanged<ChallengeDuration?> onChanged;
  final bool isTemplate;
  final bool showExplanation;

  const DurationSelectorWidget({
    Key? key,
    required this.selectedDuration,
    required this.onChanged,
    this.isTemplate = false,
    this.showExplanation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.challengeDuration.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontMd,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),

        // Dropdown para seleccionar duración
        Obx(() => DropdownButtonFormField<ChallengeDuration>(
              value: selectedDuration.value,
              onChanged: (value) {
                if (value != null) {
                  // Verificar si intenta asignar punctual a una plantilla
                  if (value == ChallengeDuration.punctual && isTemplate) {
                    Get.snackbar(
                      TrKeys.warning.tr,
                      TrKeys.punctualTemplateWarning.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.amber.withValues(alpha: 0.1),
                      colorText: Colors.amber.shade900,
                    );
                    return;
                  }
                  onChanged(value);
                }
              },
              items: ChallengeDuration.values.map((duration) {
                return DropdownMenuItem<ChallengeDuration>(
                  value: duration,
                  child: Text(_getDurationName(duration)),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
            )),

        // Explicación de duración
        if (showExplanation) ...[
          const SizedBox(height: AppDimensions.sm),
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSm),
                  border: Border.all(
                    color: AppColors.info,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getDurationExplanation(selectedDuration.value),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  // Función para obtener el nombre de duración
  String _getDurationName(ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.weekly:
        return TrKeys.durationWeekly.tr;
      case ChallengeDuration.monthly:
        return TrKeys.durationMonthly.tr;
      case ChallengeDuration.quarterly:
        return TrKeys.durationQuarterly.tr;
      case ChallengeDuration.yearly:
        return TrKeys.durationYearly.tr;
      case ChallengeDuration.punctual:
        return TrKeys.durationPunctual.tr;
    }
  }

  // Función para obtener explicación de cada duración
  String _getDurationExplanation(ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.weekly:
        return TrKeys.durationWeeklyExplanation.tr;
      case ChallengeDuration.monthly:
        return TrKeys.durationMonthlyExplanation.tr;
      case ChallengeDuration.quarterly:
        return TrKeys.durationQuarterlyExplanation.tr;
      case ChallengeDuration.yearly:
        return TrKeys.durationYearlyExplanation.tr;
      case ChallengeDuration.punctual:
        return TrKeys.durationPunctualExplanation.tr;
    }
  }
}
