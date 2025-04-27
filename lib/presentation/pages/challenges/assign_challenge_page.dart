import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';

class AssignChallengePage extends StatefulWidget {
  const AssignChallengePage({Key? key}) : super(key: key);

  @override
  State<AssignChallengePage> createState() => _AssignChallengePageState();
}

class _AssignChallengePageState extends State<AssignChallengePage> {
  final ChallengeController challengeController =
      Get.find<ChallengeController>();
  final ChildProfileController childProfileController =
      Get.find<ChildProfileController>();

  // Variables locales para los formularios
  late DateTime startDate;
  late DateTime endDate;
  String evaluationFrequency = 'daily';
  FamilyChild? selectedChild;

  @override
  void initState() {
    super.initState();

    // Inicializar fechas
    startDate = DateTime.now();
    endDate = DateTime.now().add(const Duration(days: 7));

    // Cargar perfiles infantiles si no están cargados
    if (childProfileController.childProfiles.isEmpty) {
      childProfileController.loadChildProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si hay un reto seleccionado
    final Challenge? challenge = challengeController.selectedChallenge.value;

    if (challenge == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          TrKeys.error.tr,
          'No challenge selected for assignment',
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
        title: Text(TrKeys.assignChallengeTitle.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del reto
            _buildChallengeInfo(challenge),
            const SizedBox(height: AppDimensions.lg),

            const Divider(),
            const SizedBox(height: AppDimensions.lg),

            // Selector de niño
            Text(
              TrKeys.assignToChild.tr,
              style: const TextStyle(
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Obx(() {
              if (childProfileController.isLoadingProfiles.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (childProfileController.childProfiles.isEmpty) {
                return _buildNoChildrenMessage();
              }

              return _buildChildSelector();
            }),
            const SizedBox(height: AppDimensions.lg),

            // Selector de fechas
            Text(
              TrKeys.startDate.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.fontMd,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            InkWell(
              onTap: () => _selectStartDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.md,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 150)),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: AppDimensions.md),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(startDate),
                      style: const TextStyle(fontSize: AppDimensions.fontMd),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            Text(
              TrKeys.endDate.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.fontMd,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            InkWell(
              onTap: () => _selectEndDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.md,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 150)),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: AppDimensions.md),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(endDate),
                      style: const TextStyle(fontSize: AppDimensions.fontMd),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Frecuencia de evaluación
            Text(
              TrKeys.selectEvaluationFrequency.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.fontMd,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            _buildEvaluationFrequencySelector(),
            const SizedBox(height: AppDimensions.xl),

            // Mensaje de error
            Obx(() => challengeController.errorMessage.value.isNotEmpty
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
                            challengeController.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: AppDimensions.lg),

            // Botón de asignar
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: selectedChild != null &&
                            !challengeController.isAssigningChallenge.value
                        ? () => _assignChallenge(challenge)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.md),
                      backgroundColor: AppColors.primary,
                    ),
                    child: challengeController.isAssigningChallenge.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            TrKeys.assignChallenge.tr,
                            style: const TextStyle(
                              fontSize: AppDimensions.fontMd,
                              color: Colors.white,
                            ),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // Widget que muestra información del reto
  Widget _buildChallengeInfo(Challenge challenge) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de categoría
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: Icon(
                  _getCategoryIcon(challenge.category),
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      '${_getCategoryName(challenge.category)} · ${_getFrequencyName(challenge.frequency)}',
                      style: TextStyle(
                        fontSize: AppDimensions.fontSm,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: AppDimensions.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusSm),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: AppDimensions.xs),
                              Text(
                                challenge.points.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          '${challenge.ageRange['min']}-${challenge.ageRange['max']} ${TrKeys.years.tr}',
                          style: TextStyle(
                            fontSize: AppDimensions.fontSm,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            challenge.description,
            style: const TextStyle(fontSize: AppDimensions.fontMd),
          ),
        ],
      ),
    );
  }

  // Widget para seleccionar niño
  Widget _buildChildSelector() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 150)),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Column(
        children: [
          // Si hay un niño seleccionado, mostrarlo
          if (selectedChild != null)
            ListTile(
              leading: selectedChild!.avatarUrl != null
                  ? CachedAvatar(url: selectedChild!.avatarUrl, radius: 20)
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 50),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
              title: Text(selectedChild!.name),
              subtitle: Text('${selectedChild!.age} ${TrKeys.yearsOld.tr}'),
              trailing: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    selectedChild = null;
                  });
                },
              ),
            )
          else
            // Lista de niños para seleccionar
            Column(
              children: childProfileController.childProfiles.map((child) {
                // Verificar si la edad es apropiada para el reto
                final Challenge? challenge =
                    challengeController.selectedChallenge.value;
                final bool isAgeAppropriate = challenge != null &&
                    child.age >= (challenge.ageRange['min'] as int) &&
                    child.age <= (challenge.ageRange['max'] as int);

                return ListTile(
                  leading: child.avatarUrl != null
                      ? CachedAvatar(url: child.avatarUrl, radius: 20)
                      : CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 50),
                          child: const Icon(Icons.person,
                              color: AppColors.primary),
                        ),
                  title: Text(child.name),
                  subtitle: Row(
                    children: [
                      Text('${child.age} ${TrKeys.yearsOld.tr}'),
                      if (!isAgeAppropriate) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.warning_amber,
                            size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          TrKeys.ageAppropriate.tr,
                          style: TextStyle(
                              color: Colors.amber.shade700, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  trailing: const Icon(Icons.check_circle_outline),
                  onTap: () {
                    setState(() {
                      selectedChild = child;
                    });
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // Widget cuando no hay niños disponibles
  Widget _buildNoChildrenMessage() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 50),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
            size: 48,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            TrKeys.noChildrenAvailable.tr,
            style: const TextStyle(
              fontSize: AppDimensions.fontLg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            TrKeys.noChildrenAvailableMessage.tr,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.md),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              Get.toNamed('/create-child');
            },
            icon: const Icon(Icons.add),
            label: Text(TrKeys.createChildProfileFirst.tr),
          ),
        ],
      ),
    );
  }

  // Widget para seleccionar frecuencia de evaluación
  Widget _buildEvaluationFrequencySelector() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 150)),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: Text(TrKeys.dailyEvaluation.tr),
            subtitle: Text(
              'Evaluate challenge progress every day',
              style: TextStyle(
                  fontSize: AppDimensions.fontSm, color: Colors.grey.shade600),
            ),
            value: 'daily',
            groupValue: evaluationFrequency,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  evaluationFrequency = value;
                });
              }
            },
            activeColor: AppColors.primary,
          ),
          RadioListTile<String>(
            title: Text(TrKeys.weeklyEvaluation.tr),
            subtitle: Text(
              'Evaluate challenge progress once a week',
              style: TextStyle(
                  fontSize: AppDimensions.fontSm, color: Colors.grey.shade600),
            ),
            value: 'weekly',
            groupValue: evaluationFrequency,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  evaluationFrequency = value;
                });
              }
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // Método para seleccionar fecha de inicio
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        // Si la fecha de fin es menor que la de inicio, actualizarla
        if (endDate.isBefore(startDate)) {
          endDate = startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  // Método para seleccionar fecha de fin
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate.isBefore(startDate) ? startDate : endDate,
      firstDate: startDate,
      lastDate: startDate.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  // Método para asignar el reto
  Future<void> _assignChallenge(Challenge challenge) async {
    if (selectedChild == null) {
      return;
    }

    // Actualizar controlador de retos con los datos necesarios
    challengeController.selectedChildId.value = selectedChild!.id;
    challengeController.startDate.value = startDate;
    challengeController.endDate.value = endDate;
    challengeController.selectedEvaluationFrequency.value = evaluationFrequency;

    // Asignar reto
    await challengeController.assignChallengeToChild();

    // Si no hay error, volver a la pantalla anterior
    if (challengeController.errorMessage.value.isEmpty) {
      Get.back();
    }
  }

  // Funciones auxiliares para traducir categorías, frecuencias e íconos
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

  IconData _getCategoryIcon(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return Icons.clean_hands;
      case ChallengeCategory.school:
        return Icons.school;
      case ChallengeCategory.order:
        return Icons.cleaning_services;
      case ChallengeCategory.responsibility:
        return Icons.assignment_turned_in;
      case ChallengeCategory.help:
        return Icons.emoji_people;
      case ChallengeCategory.special:
        return Icons.celebration;
      case ChallengeCategory.sibling:
        return Icons.family_restroom;
    }
  }
}
