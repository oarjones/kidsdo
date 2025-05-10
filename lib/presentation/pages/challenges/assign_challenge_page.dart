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
import 'package:kidsdo/presentation/widgets/challenges/celebration_animation.dart';
import 'package:kidsdo/presentation/widgets/challenges/multi_child_selector_widget.dart';

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
  final RxList<FamilyChild> selectedChildren = <FamilyChild>[].obs;
  bool isContinuous = false; // Variable para retos continuos
  bool showCelebration = false;

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

    // Determinar si es un reto puntual
    final bool isPunctualChallenge =
        challenge.duration == ChallengeDuration.punctual;

    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.assignChallengeTitle.tr),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del reto
                  _buildChallengeInfo(challenge),
                  const SizedBox(height: AppDimensions.lg),

                  const Divider(),
                  const SizedBox(height: AppDimensions.lg),

                  // Selector de niño (ahora usando MultiChildSelectorWidget)
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

                    // Usar el widget MultiChildSelectorWidget para selección
                    return MultiChildSelectorWidget(
                      children: childProfileController.childProfiles,
                      challenge: challenge,
                      onSelectionChanged: (children) {
                        // Actualizar sin setState
                        selectedChildren.clear();
                        selectedChildren.addAll(children);
                      },
                    );
                  }),
                  const SizedBox(height: AppDimensions.lg),

                  // OPCIÓN DE RETO CONTINUO (mostrar solo si NO es un reto puntual)
                  if (!isPunctualChallenge) ...[
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        color: isContinuous
                            ? AppColors.primaryLight
                            : Colors.grey.withValues(alpha: 20),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.borderRadiusMd),
                        border: Border.all(
                          color: isContinuous
                              ? AppColors.primary
                              : Colors.grey.withValues(alpha: 50),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  TrKeys.continuousChallenge.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppDimensions.fontMd,
                                  ),
                                ),
                              ),
                              Switch(
                                value: isContinuous,
                                onChanged: (value) {
                                  setState(() {
                                    isContinuous = value;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                          Text(
                            TrKeys.continuousChallengeExplanation.tr,
                            style: TextStyle(
                              fontSize: AppDimensions.fontSm,
                              color: isContinuous
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                            ),
                          ),
                          if (isContinuous) ...[
                            const SizedBox(height: AppDimensions.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.sm,
                                vertical: AppDimensions.xs,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusSm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.repeat,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getDurationText(challenge.duration),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                  ],

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
                        border: Border.all(
                            color: Colors.grey.withValues(alpha: 150)),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.borderRadiusMd),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppColors.primary),
                          const SizedBox(width: AppDimensions.md),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(startDate),
                            style:
                                const TextStyle(fontSize: AppDimensions.fontMd),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // Fecha de fin (solo visible si no es continuo)
                  if (!isContinuous) ...[
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
                          border: Border.all(
                              color: Colors.grey.withValues(alpha: 150)),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMd),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: AppColors.primary),
                            const SizedBox(width: AppDimensions.md),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(endDate),
                              style: const TextStyle(
                                  fontSize: AppDimensions.fontMd),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                  ] else ...[
                    // Si es continuo, mostrar mensaje informativo en lugar de fecha fin
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.sm),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.borderRadiusSm),
                        border: Border.all(
                            color: AppColors.info.withValues(alpha: 100)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              TrKeys.neverEnds.tr,
                              style: const TextStyle(
                                color: AppColors.info,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                  ],

                  // Mensaje de error
                  Obx(() => challengeController.errorMessage.value.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(AppDimensions.md),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 50),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusMd),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
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

                  // Botón de asignar - CORREGIDO
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                          onPressed: selectedChildren.isNotEmpty &&
                                  !challengeController
                                      .isAssigningChallenge.value
                              ? () => _assignChallenge(challenge)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.md),
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                Colors.grey.withValues(alpha: 100),
                          ),
                          child: challengeController.isAssigningChallenge.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
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
          ),

          // Animación de celebración
          if (showCelebration)
            CelebrationAnimation(
              points: challenge.points,
              message: TrKeys.challengeAssignedMessage.tr,
              onClose: () {
                setState(() {
                  showCelebration = false;
                });
                Get.back(); // Volver a la pantalla anterior
              },
            ),
        ],
      ),
    );
  }

  // Método para asignar el reto - MODIFICADO PARA MÚLTIPLES NIÑOS
  Future<void> _assignChallenge(Challenge challenge) async {
    if (selectedChildren.isEmpty) {
      return;
    }

    // Usar una frecuencia de evaluación predeterminada
    final evaluationFrequency =
        challenge.duration == ChallengeDuration.weekly ? 'weekly' : 'daily';

    // Mostrar indicador de carga
    challengeController.isAssigningChallenge.value = true;

    try {
      // Asignar el reto a cada niño seleccionado
      for (final child in selectedChildren) {
        // Limpiar mensaje de error previo
        challengeController.errorMessage.value = '';

        // Configurar datos para este niño
        challengeController.selectedChildId.value = child.id;
        challengeController.startDate.value = startDate;
        challengeController.endDate.value = endDate;
        challengeController.selectedEvaluationFrequency.value =
            evaluationFrequency;
        challengeController.isContinuousChallenge.value = isContinuous;

        // Llamar directamente al método de implementación para asignar el reto
        final result = await challengeController.assignChallengeToChildImpl(
          challengeId: challenge.id,
          childId: child.id,
          familyId: child.familyId,
          startDate: startDate,
          endDate: isContinuous ? null : endDate,
          evaluationFrequency: evaluationFrequency,
          isContinuous: isContinuous,
        );

        // Verificar si hubo error
        await result.fold(
          (failure) {
            // Si falla la asignación para un niño, mostrar error pero continuar con los demás
            Get.snackbar(
              TrKeys.error.tr,
              'Error assigning challenge to ${child.name}: ${failure.message}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withValues(alpha: 50),
              colorText: Colors.red,
            );
          },
          (assignedChallenge) async {
            // Añadir a la lista de retos asignados
            challengeController.assignedChallenges.add(assignedChallenge);
          },
        );
      }

      // Si todo fue exitoso, mostrar celebración
      setState(() {
        showCelebration = true;
      });
    } catch (e) {
      // Manejar errores generales
      Get.snackbar(
        TrKeys.error.tr,
        'Error assigning challenges: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 50),
        colorText: Colors.red,
      );
    } finally {
      // Siempre ocultar indicador de carga
      challengeController.isAssigningChallenge.value = false;
    }
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
                      '${_getCategoryName(challenge.category)} · ${_getDurationName(challenge.duration)}',
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

  // Método para obtener texto descriptivo de la duración
  String _getDurationText(ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.weekly:
        return TrKeys.durationWeeklyRepeat.tr;
      case ChallengeDuration.monthly:
        return TrKeys.durationMonthlyRepeat.tr;
      case ChallengeDuration.quarterly:
        return TrKeys.durationQuarterlyRepeat.tr;
      case ChallengeDuration.yearly:
        return TrKeys.durationYearlyRepeat.tr;
      case ChallengeDuration.punctual:
        return TrKeys.durationPunctualRepeat.tr;
    }
  }

  // Método para obtener nombre de categoría
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

  // Método para obtener nombre de duración
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

  // Método para obtener icono de categoría
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
