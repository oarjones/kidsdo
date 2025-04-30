import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart';
import 'package:kidsdo/presentation/widgets/challenges/multi_child_selector_widget.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';

class BatchAssignChallengesPage extends StatefulWidget {
  const BatchAssignChallengesPage({Key? key}) : super(key: key);

  @override
  State<BatchAssignChallengesPage> createState() =>
      _BatchAssignChallengesPageState();
}

class _BatchAssignChallengesPageState extends State<BatchAssignChallengesPage> {
  final ChallengeController challengeController =
      Get.find<ChallengeController>();
  final ChildProfileController childProfileController =
      Get.find<ChildProfileController>();

  // Lista de IDs de niños seleccionados
  final RxList<String> selectedChildIds = <String>[].obs;

  // Variables para fechas y frecuencia
  late DateTime startDate;
  late DateTime endDate;
  String evaluationFrequency = 'daily';

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

    // Verificar si hay retos seleccionados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (challengeController.selectedChallengeIds.isEmpty) {
        Get.back();
        Get.snackbar(
          TrKeys.error.tr,
          'No challenges selected for assignment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 50),
          colorText: Colors.red,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.assignChallenge.tr),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen de retos seleccionados
              _buildSelectedChallengesSummary(),
              const SizedBox(height: AppDimensions.lg),

              const Divider(),
              const SizedBox(height: AppDimensions.lg),

              // Selector de niños
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selector de niños
                      MultiChildSelectorWidget(
                        selectedChildIds: selectedChildIds,
                        onChildToggle: _toggleChildSelection,
                      ),
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
                                DateFormat('EEEE, MMMM d, yyyy')
                                    .format(startDate),
                                style: const TextStyle(
                                    fontSize: AppDimensions.fontMd),
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
                                DateFormat('EEEE, MMMM d, yyyy')
                                    .format(endDate),
                                style: const TextStyle(
                                    fontSize: AppDimensions.fontMd),
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
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.sm),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.withValues(alpha: 150)),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMd),
                        ),
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: Text(TrKeys.dailyEvaluation.tr),
                              subtitle: Text(
                                'Evaluate challenge progress every day',
                                style: TextStyle(
                                    fontSize: AppDimensions.fontSm,
                                    color: Colors.grey.shade600),
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
                                    fontSize: AppDimensions.fontSm,
                                    color: Colors.grey.shade600),
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
                      ),
                    ],
                  ),
                ),
              ),

              // Mensaje de error
              Obx(() => challengeController.errorMessage.value.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.only(bottom: AppDimensions.md),
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

              // Botón de asignar
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: selectedChildIds.isNotEmpty &&
                              !challengeController.isAssigningChallenge.value
                          ? _assignChallenges
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
      ),
    );
  }

  // Widget para mostrar resumen de retos seleccionados
  Widget _buildSelectedChallengesSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: const Icon(Icons.assignment, color: AppColors.primary),
              ),
              const SizedBox(width: AppDimensions.md),
              Obx(() => Text(
                    '${challengeController.selectedChallengeIds.length} ${challengeController.selectedChallengeIds.length == 1 ? TrKeys.challenge.tr : TrKeys.challenges.tr} ${TrKeys.selected.tr.toLowerCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimensions.fontMd,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Obx(() {
            // Mostrar los títulos de los retos seleccionados (max 3)
            final selectedChallenges = challengeController.filteredChallenges
                .where((c) =>
                    challengeController.selectedChallengeIds.contains(c.id))
                .take(3)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...selectedChallenges.map((challenge) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              challenge.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (challengeController.selectedChallengeIds.length > 3)
                  Text(
                    '... ${TrKeys.andOthers.tr}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            );
          }),
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

  // Método para alternar la selección de un niño
  void _toggleChildSelection(String childId) {
    if (selectedChildIds.contains(childId)) {
      selectedChildIds.remove(childId);
    } else {
      selectedChildIds.add(childId);
    }
  }

  // Método para asignar los retos
  Future<void> _assignChallenges() async {
    if (selectedChildIds.isEmpty) {
      Get.snackbar(
        TrKeys.warning.tr,
        'Please select at least one child',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.withValues(alpha: 50),
        colorText: Colors.amber.shade900,
      );
      return;
    }

    // Obtener el ID de familia
    final sessionController = Get.find<SessionController>();
    final currentUser = sessionController.currentUser.value;

    if (currentUser == null || currentUser.familyId == null) {
      Get.snackbar(
        TrKeys.error.tr,
        'No family ID available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 50),
        colorText: Colors.red,
      );
      return;
    }

    // Configurar para asignación por lotes
    challengeController.isAssigningChallenge.value = true;
    challengeController.errorMessage.value = '';

    // Crear contador para retos asignados correctamente
    int successCount = 0;
    final selectedChallenges = challengeController.filteredChallenges
        .where((c) => challengeController.selectedChallengeIds.contains(c.id))
        .toList();

    // Asignar cada reto a cada niño seleccionado
    for (final challenge in selectedChallenges) {
      for (final childId in selectedChildIds) {
        final result = await challengeController.assignChallengeToChildImpl(
          challengeId: challenge.id,
          childId: childId,
          familyId: currentUser.familyId!,
          startDate: startDate,
          endDate: endDate,
          evaluationFrequency: evaluationFrequency,
        );

        result.fold(
          (failure) {
            // Si falla alguna asignación, mostrar el error pero continuar
            challengeController.errorMessage.value = failure.message;
          },
          (_) {
            // Incrementar contador si la asignación fue exitosa
            successCount++;
          },
        );
      }
    }

    // Finalizar el proceso de asignación
    challengeController.isAssigningChallenge.value = false;

    // Si al menos una asignación tuvo éxito, mostrar mensaje
    if (successCount > 0) {
      // Limpiar selección
      challengeController.clearSelection();

      // Mostrar mensaje de éxito
      Get.back();
      Get.snackbar(
        TrKeys.success.tr,
        'Assigned $successCount challenges successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 50),
        colorText: Colors.green,
      );
    }
  }
}
