import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';
import 'package:kidsdo/presentation/widgets/challenges/challenge_icon_selector.dart';

class CreateEditChallengePage extends GetView<ChallengeController> {
  final bool isEditing;

  const CreateEditChallengePage({
    Key? key,
    this.isEditing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si estamos editando, asegurarnos de que hay un reto seleccionado
    if (isEditing && controller.selectedChallenge.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          TrKeys.error.tr,
          'No challenge selected for editing',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 50),
          colorText: Colors.red,
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEditing ? TrKeys.editChallenge.tr : TrKeys.createChallenge.tr),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context),
              tooltip: TrKeys.delete.tr,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                TrKeys.challengeTitle.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontMd,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  hintText: TrKeys.enterChallengeTitle.tr,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 20),
                ),
                maxLength: 50,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppDimensions.md),

              // Descripción
              Text(
                TrKeys.description.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontMd,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: controller.descriptionController,
                decoration: InputDecoration(
                  hintText: TrKeys.enterChallengeDescription.tr,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 20),
                ),
                maxLength: 200,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppDimensions.md),

              // Categoría y Frecuencia en fila
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TrKeys.category.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimensions.fontMd,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Obx(() => DropdownButtonFormField<ChallengeCategory>(
                              value: controller.selectedCategory.value,
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedCategory.value = value;
                                }
                              },
                              items: ChallengeCategory.values.map((category) {
                                return DropdownMenuItem<ChallengeCategory>(
                                  value: category,
                                  child: Text(_getCategoryName(category)),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFFF5F5F5),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TrKeys.frequency.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimensions.fontMd,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Obx(() => DropdownButtonFormField<ChallengeFrequency>(
                              value: controller.selectedFrequency.value,
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedFrequency.value = value;
                                }
                              },
                              items: ChallengeFrequency.values.map((frequency) {
                                return DropdownMenuItem<ChallengeFrequency>(
                                  value: frequency,
                                  child: Text(_getFrequencyName(frequency)),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Color(0xFFF5F5F5),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),

              // Puntos
              Text(
                TrKeys.points.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontMd,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: controller.pointsController,
                decoration: InputDecoration(
                  hintText: TrKeys.enterPoints.tr,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 20),
                  prefixIcon: const Icon(Icons.star_outline),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimensions.lg),

              // Rango de edad
              Text(
                TrKeys.ageRange.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontMd,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue:
                          controller.selectedAgeRange['min'].toString(),
                      decoration: InputDecoration(
                        labelText: TrKeys.minAge.tr,
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 20),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final minAge = int.tryParse(value) ?? 3;
                        controller.selectedAgeRange['min'] = minAge;
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: TextFormField(
                      initialValue:
                          controller.selectedAgeRange['max'].toString(),
                      decoration: InputDecoration(
                        labelText: TrKeys.maxAge.tr,
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 20),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final maxAge = int.tryParse(value) ?? 12;
                        controller.selectedAgeRange['max'] = maxAge;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),

              // Selector de Icono
              Text(
                TrKeys.selectIcon.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontMd,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              ChallengeIconSelector(
                selectedIcon: controller.selectedIcon.value,
                onSelectIcon: (icon) {
                  controller.selectedIcon.value = icon;
                },
              ),
              const SizedBox(height: AppDimensions.lg),

              // Guardar como plantilla
              Obx(() => SwitchListTile(
                    title: Text(TrKeys.saveAsTemplate.tr),
                    subtitle: Text(TrKeys.saveAsTemplateDesc.tr),
                    value: controller.isTemplateChallenge.value,
                    onChanged: (value) {
                      controller.isTemplateChallenge.value = value;
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  )),

              const SizedBox(height: AppDimensions.xl),

              // Mensaje de error
              Obx(() => controller.errorMessage.value.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 50),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.borderRadiusMd),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: AppDimensions.sm),
                          Expanded(
                            child: Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),

              const SizedBox(height: AppDimensions.lg),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isCreatingChallenge.value ||
                              controller.isUpdatingChallenge.value
                          ? null
                          : () {
                              if (isEditing) {
                                controller.updateChallenge();
                              } else {
                                controller.createChallenge();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.md),
                      ),
                      child: controller.isCreatingChallenge.value ||
                              controller.isUpdatingChallenge.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              isEditing
                                  ? TrKeys.save.tr
                                  : TrKeys.createChallenge.tr,
                              style: const TextStyle(
                                  fontSize: AppDimensions.fontMd),
                            ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Diálogo de confirmación de eliminación
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TrKeys.delete.tr),
        content: Text(
            '${TrKeys.confirmDeleteProfile.tr}?\n${controller.selectedChallenge.value?.title ?? ""}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.selectedChallenge.value != null) {
                controller
                    .deleteChallenge(controller.selectedChallenge.value!.id)
                    .then((_) {
                  Get.back(); // Cerrar pantalla de edición
                });
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(TrKeys.delete.tr),
          ),
        ],
      ),
    );
  }

  // Funciones auxiliares para traducir categorías y frecuencias
  String _getCategoryName(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return TrKeys.categoryHygiene.tr;
      case ChallengeCategory.school:
        return TrKeys.categorySchool.tr;
      case ChallengeCategory.order:
        return TrKeys.categoryOrder.tr;
      case ChallengeCategory.responsibility:
        return TrKeys.categoryResponsibility.tr;
      case ChallengeCategory.help:
        return TrKeys.categoryHelp.tr;
      case ChallengeCategory.special:
        return TrKeys.categorySpecial.tr;
      case ChallengeCategory.sibling:
        return TrKeys.categorySibling.tr;
    }
  }

  String _getFrequencyName(ChallengeFrequency frequency) {
    switch (frequency) {
      case ChallengeFrequency.daily:
        return TrKeys.frequencyDaily.tr;
      case ChallengeFrequency.weekly:
        return TrKeys.frequencyWeekly.tr;
      case ChallengeFrequency.monthly:
        return TrKeys.frequencyMonthly.tr;
      case ChallengeFrequency.quarterly:
        return TrKeys.frequencyQuarterly.tr;
      case ChallengeFrequency.once:
        return TrKeys.frequencyOnce.tr;
    }
  }
}
