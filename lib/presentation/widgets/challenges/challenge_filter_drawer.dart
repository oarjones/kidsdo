import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';

class ChallengeFilterDrawer extends GetView<ChallengeController> {
  const ChallengeFilterDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TrKeys.filterChallenges.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),

              const Divider(),

              // Contenido con scroll
              Expanded(
                child: ListView(
                  children: [
                    // Filtro por categoría
                    _buildSectionTitle(TrKeys.category.tr),
                    _buildCategoryFilter(),

                    const SizedBox(height: 24),

                    // Filtro por frecuencia
                    _buildSectionTitle(TrKeys.frequency.tr),
                    _buildFrequencyFilter(),

                    const SizedBox(height: 24),

                    // Filtro por rango de edad
                    _buildSectionTitle(TrKeys.ageRange.tr),
                    _buildAgeRangeFilter(),

                    const SizedBox(height: 24),

                    // Opción para mostrar solo apropiados por edad
                    _buildAgeAppropriateFilter(),
                  ],
                ),
              ),

              const Divider(),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                        Navigator.pop(context);
                      },
                      child: Text(TrKeys.resetFilters.tr),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(TrKeys.applyFilters.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construir título de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Filtro por categoría
  Widget _buildCategoryFilter() {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Opción "Todas las categorías"
            FilterChip(
              label: Text(TrKeys.allCategories.tr),
              selected: controller.filterCategory.value == null,
              onSelected: (selected) {
                if (selected) {
                  controller.setFilterCategory(null);
                }
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
            ),

            // Opciones para cada categoría
            ...ChallengeCategory.values.map((category) => FilterChip(
                  label: Text(_getCategoryName(category)),
                  selected: controller.filterCategory.value == category,
                  onSelected: (selected) {
                    if (selected) {
                      controller.setFilterCategory(category);
                    } else if (controller.filterCategory.value == category) {
                      controller.setFilterCategory(null);
                    }
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: AppColors.primaryLight,
                  checkmarkColor: AppColors.primary,
                )),
          ],
        ));
  }

  // Filtro por frecuencia
  Widget _buildFrequencyFilter() {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Opción "Todas las frecuencias"
            FilterChip(
              label: Text(TrKeys.allFrequencies.tr),
              selected: controller.filterFrequency.value == null,
              onSelected: (selected) {
                if (selected) {
                  controller.setFilterFrequency(null);
                }
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: AppColors.secondaryLight,
              checkmarkColor: AppColors.secondary,
            ),

            // Opciones para cada frecuencia
            ...ChallengeFrequency.values.map((frequency) => FilterChip(
                  label: Text(_getFrequencyName(frequency)),
                  selected: controller.filterFrequency.value == frequency,
                  onSelected: (selected) {
                    if (selected) {
                      controller.setFilterFrequency(frequency);
                    } else if (controller.filterFrequency.value == frequency) {
                      controller.setFilterFrequency(null);
                    }
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: AppColors.secondaryLight,
                  checkmarkColor: AppColors.secondary,
                )),
          ],
        ));
  }

  // Filtro por rango de edad
  Widget _buildAgeRangeFilter() {
    return Column(
      children: [
        // Mostrar rango seleccionado
        Obx(() => Text(
              "${controller.filterMinAge.value} - ${controller.filterMaxAge.value} ${TrKeys.years.tr}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )),

        const SizedBox(height: 8),

        // Slider para rango de edad
        Obx(() => RangeSlider(
              values: RangeValues(
                controller.filterMinAge.value.toDouble(),
                controller.filterMaxAge.value.toDouble(),
              ),
              min: 0,
              max: 18,
              divisions: 18,
              labels: RangeLabels(
                controller.filterMinAge.value.toString(),
                controller.filterMaxAge.value.toString(),
              ),
              onChanged: (values) {
                controller.setAgeRange(
                  values.start.round(),
                  values.end.round(),
                );
              },
              activeColor: AppColors.info,
              inactiveColor: Colors.grey.shade300,
            )),

        // Texto explicativo
        Text(
          TrKeys.ageRangeExplanation.tr,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // Filtro para mostrar solo retos apropiados para la edad
  Widget _buildAgeAppropriateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y selector de edad
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TrKeys.ageAppropriate.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(TrKeys.childAge.tr),
                const SizedBox(width: 8),
                Obx(() => DropdownButton<int>(
                      value: controller.selectedChildAge.value,
                      items: List.generate(
                              16, (index) => index + 3) // De 3 a 18 años
                          .map((age) => DropdownMenuItem<int>(
                                value: age,
                                child: Text(age.toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedChildAge.value = value;
                          controller.applyFilters();
                        }
                      },
                      isDense: true,
                    )),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Switch para activar/desactivar
        Obx(() => SwitchListTile(
              value: controller.showOnlyAgeAppropriate.value,
              onChanged: (value) {
                controller.toggleAgeAppropriate(value);
              },
              title: Text(TrKeys.showOnlyAgeAppropriate.tr),
              subtitle: Text(TrKeys.ageAppropriateExplanation.tr),
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.success,
            )),
      ],
    );
  }

  // Obtener nombre de categoría
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

  // Obtener nombre de frecuencia
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
