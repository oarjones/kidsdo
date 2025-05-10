import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart'; // Para ChallengeDuration
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart'; // Para mostrar avatares de niños
import 'package:kidsdo/presentation/widgets/auth/auth_button.dart'; // Para botones de acción
import 'package:kidsdo/presentation/widgets/auth/auth_message.dart'; // Para mensajes de error

class BatchEvaluationPage extends StatefulWidget {
  const BatchEvaluationPage({Key? key}) : super(key: key);

  @override
  State<BatchEvaluationPage> createState() => _BatchEvaluationPageState();
}

class _BatchEvaluationPageState extends State<BatchEvaluationPage> {
  final ChallengeController challengeController =
      Get.find<ChallengeController>();
  final ChildProfileController childProfileController =
      Get.find<ChildProfileController>();

  TextEditingController get _unifiedEvaluationNoteController =>
      challengeController.unifiedEvaluationNoteController;

  AssignedChallengeStatus selectedEvaluationStatusToApply =
      AssignedChallengeStatus.completed;

  final Map<String, TextEditingController> _pointsTextControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Limpiar el estado específico de la página de evaluación por lotes (filtros, selecciones)
      challengeController.clearBatchEvaluationState();

      final currentUser = Get.find<SessionController>().currentUser.value;
      if (currentUser != null && currentUser.familyId != null) {
        // 1. Asegurar que los perfiles de los niños estén cargados.
        // ChildProfileController usualmente carga los perfiles del familyId del usuario actual.
        if (childProfileController.childProfiles.isEmpty ||
            childProfileController.childProfiles.first.familyId !=
                currentUser.familyId) {
          await childProfileController
              .loadChildProfiles(); // Esperar a que se carguen
        }

        // 2. Cargar todos los retos asignados para la familia.
        // Este método se encarga de poblar challengeController.assignedChallenges.
        try {
          await challengeController
              .loadAllAssignedChallengesForFamily(currentUser.familyId!);
        } catch (error) {
          challengeController.errorMessage.value =
              "Error al cargar retos asignados: ${error.toString()}";
        }
      } else {
        challengeController.errorMessage.value =
            "No se pudo identificar la familia para cargar los retos.";
      }

      // 3. Aplicar los filtros de evaluación.
      // Esto mostrará los retos según los filtros por defecto (incluyendo el nuevo filtro de estado).
      challengeController.applyEvaluationFilters();
    });
  }

  @override
  void dispose() {
    _pointsTextControllers.forEach((key, controller) => controller.dispose());
    _pointsTextControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('batch_evaluation_page_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Lógica para mostrar un drawer o diálogo de filtros más avanzado si se desea.
              // Por ahora, los filtros principales están en _buildFilterSection.
              // Si se implementa un drawer, llamar a challengeController.applyEvaluationFilters() al cerrar.
            },
            tooltip: TrKeys.filterChallenges.tr,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final currentUser =
                  Get.find<SessionController>().currentUser.value;
              if (currentUser != null && currentUser.familyId != null) {
                challengeController
                    .loadAllAssignedChallengesForFamily(currentUser.familyId!)
                    .then((_) {
                  challengeController.applyEvaluationFilters();
                }).catchError((error) {
                  challengeController.errorMessage.value =
                      "Error al refrescar los retos: ${error.toString()}";
                  challengeController.applyEvaluationFilters();
                });
              }
            },
            tooltip: TrKeys.refresh.tr,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterSection(),
            Obx(() => challengeController.errorMessage.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                        vertical: AppDimensions.sm),
                    child: AuthMessage(
                      message: challengeController.errorMessage.value,
                      type: MessageType.error,
                      onDismiss: () =>
                          challengeController.errorMessage.value = '',
                    ),
                  )
                : const SizedBox.shrink()),
            Expanded(
              child: Obx(() {
                // Usar isLoadingAssignedChallenges para el estado de carga general de retos asignados
                if (challengeController.isLoadingAssignedChallenges.value &&
                    challengeController
                        .assignedChallengesForEvaluation.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (challengeController
                    .assignedChallengesForEvaluation.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  itemCount: challengeController
                      .assignedChallengesForEvaluation.length,
                  itemBuilder: (context, index) {
                    final assignedChallenge = challengeController
                        .assignedChallengesForEvaluation[index];
                    final child = childProfileController.childProfiles
                        .firstWhereOrNull(
                            (c) => c.id == assignedChallenge.childId);
                    return _buildAssignedChallengeEvaluationCard(
                        assignedChallenge, child);
                  },
                );
              }),
            ),
            Obx(() => challengeController
                    .selectedAssignedChallengeIdsForEvaluation.isNotEmpty
                ? _buildBatchEvaluationToolbar()
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Usar color del tema
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08), // Opacidad más sutil
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            TrKeys.filterChallenges.tr,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildChildFilter(),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _buildDurationFilter(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          TextField(
            // controller: challengeController.evaluationSearchController, // Si creas uno específico
            onChanged: (value) {
              challengeController.updateEvaluationSearchQuery(value);
            },
            decoration: InputDecoration(
              hintText: TrKeys.searchChallenges.tr,
              prefixIcon: const Icon(Icons.search),
              // suffixIcon: Obx(() => // Para limpiar el campo de búsqueda
              // challengeController.evaluationSearchQuery.value.isNotEmpty
              //         ? IconButton(
              //             icon: const Icon(Icons.clear),
              //             onPressed: () {
              //               // challengeController.evaluationSearchController.clear();
              //               challengeController.updateEvaluationSearchQuery('');
              //             },
              //           )
              //         : null),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
                borderSide:
                    BorderSide(color: Colors.grey.shade400), // Borde más suave
              ),
              enabledBorder: OutlineInputBorder(
                // Borde cuando no está enfocado
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                // Borde cuando está enfocado
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: AppDimensions.md), // Ajustar padding
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Obx(() {
            final hasActiveFilters = challengeController
                    .selectedChildrenIdsForEvaluation.isNotEmpty ||
                challengeController.filterDurationForEvaluation.value != null ||
                challengeController.evaluationSearchQuery.value.isNotEmpty;

            if (!hasActiveFilters) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: AppDimensions.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: AppDimensions.xs,
                      runSpacing: AppDimensions.xs,
                      children: [
                        ...challengeController.selectedChildrenIdsForEvaluation
                            .map((childId) {
                          final child = childProfileController.childProfiles
                              .firstWhereOrNull((c) => c.id == childId);
                          if (child == null) {
                            return const SizedBox.shrink();
                          }
                          return Chip(
                            label: Text(child.name),
                            avatar:
                                CachedAvatar(url: child.avatarUrl, radius: 10),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => challengeController
                                .toggleChildForEvaluationFilter(child.id),
                            backgroundColor:
                                AppColors.primaryLight.withValues(alpha: 0.7),
                            labelStyle:
                                const TextStyle(fontSize: AppDimensions.fontXs),
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                        if (challengeController
                                .filterDurationForEvaluation.value !=
                            null)
                          Chip(
                            label: Text(_getDurationName(challengeController
                                .filterDurationForEvaluation.value!)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => challengeController
                                .setFilterDurationForEvaluation(null),
                            backgroundColor:
                                AppColors.secondaryLight.withValues(alpha: 0.7),
                            labelStyle:
                                const TextStyle(fontSize: AppDimensions.fontXs),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (challengeController
                            .evaluationSearchQuery.value.isNotEmpty)
                          Chip(
                            label: Text(
                                '"${challengeController.evaluationSearchQuery.value}"'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => challengeController
                                .updateEvaluationSearchQuery(''),
                            backgroundColor: Colors.grey.shade300,
                            labelStyle:
                                const TextStyle(fontSize: AppDimensions.fontXs),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: challengeController.clearEvaluationFilters,
                    icon: const Icon(Icons.filter_list_off, size: 18),
                    label: Text(TrKeys.clearAllFilters.tr),
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: AppColors.primary // Color del texto
                        ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChildFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300), // Borde más suave
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Obx(() {
        final selectedIds =
            challengeController.selectedChildrenIdsForEvaluation;

        return DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
              value: 'batch_evaluation_filter_child_all'
                  .tr, // Siempre mostrar el hint
              hint: Text(
                'batch_evaluation_filter_child_all'.tr,
                overflow: TextOverflow.ellipsis,
              ),
              isExpanded: true,
              items: [
                DropdownMenuItem<String?>(
                  value: 'batch_evaluation_filter_child_all'
                      .tr, // Valor para el hint
                  child: Row(
                    children: [
                      Icon(Icons.group_outlined,
                          color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Text(
                          'batch_evaluation_filter_child_all'
                              .tr, // Mostrar "Todos" si no hay selección
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (childProfileController.childProfiles.isNotEmpty)
                  const DropdownMenuItem<String?>(
                    value: 'divider', // Usar un valor único para el divisor
                    enabled: false,
                    child: Divider(height: 0),
                  ),
                ...childProfileController.childProfiles.map((child) {
                  return DropdownMenuItem<String?>(
                    value: child.id, // El valor es el ID del niño
                    child: Row(
                      children: [
                        Icon(
                          selectedIds.contains(child.id)
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: selectedIds.contains(child.id)
                              ? AppColors.primary
                              : Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        CachedAvatar(url: child.avatarUrl, radius: 12),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                            child: Text(child.name,
                                overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                if (value == 'batch_evaluation_filter_child_all'.tr) {
                  // No hacer nada si se selecciona el hint
                } else if (value != null && value != 'divider') {
                  challengeController.toggleChildForEvaluationFilter(value);
                  // applyEvaluationFilters ya se llama dentro de toggleChildForEvaluationFilter
                }
                // Forzar reconstrucción del Dropdown para que el hint se actualice
                setState(() {});
              },
              selectedItemBuilder: (BuildContext context) {
                // Para mostrar el hint correctamente
                return [
                  DropdownMenuItem<String?>(
                    child: Row(
                      children: [
                        Icon(Icons.group_outlined,
                            color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: Text(
                            selectedIds.isEmpty
                                ? 'batch_evaluation_filter_child_all'.tr
                                : Tr.tp(
                                    'batch_evaluation_filter_child_selected',
                                    {'count': selectedIds.length.toString()}),
                            // 'batch_evaluation_filter_child_selected'
                            //   .trParams({
                            //   'count': selectedIds.length.toString()
                            // }),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Añadir placeholders para los otros items si es necesario para que selectedItemBuilder no falle
                  // Esto es un poco un hack para controlar el texto del botón del dropdown.
                  // Una solución más limpia podría ser un widget personalizado.
                  if (selectedIds.isNotEmpty) Container(),
                  if (childProfileController.childProfiles.isNotEmpty)
                    Container(),
                  ...childProfileController.childProfiles
                      .map((_) => Container())
                      .toList(),
                ];
              }),
        );
      }),
    );
  }

  Widget _buildDurationFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<ChallengeDuration?>(
              value: challengeController.filterDurationForEvaluation.value,
              hint: Text(
                'batch_evaluation_filter_duration'.tr,
                overflow: TextOverflow.ellipsis,
              ),
              isExpanded: true,
              items: [
                DropdownMenuItem<ChallengeDuration?>(
                  value: null, // Representa "Todos"
                  child: Row(
                    children: [
                      Icon(Icons.all_inclusive_outlined,
                          color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Text(
                          TrKeys.all.tr,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                ...ChallengeDuration.values
                    .map((duration) => DropdownMenuItem<ChallengeDuration>(
                          value: duration,
                          child: Row(
                            children: [
                              Icon(_getDurationIcon(duration),
                                  color: _getDurationColor(duration), size: 20),
                              const SizedBox(width: AppDimensions.sm),
                              Expanded(
                                child: Text(
                                  _getDurationName(duration),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
              onChanged: (value) {
                challengeController.setFilterDurationForEvaluation(value);
                // applyEvaluationFilters ya se llama dentro de setFilterDurationForEvaluation
              },
            ),
          )),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, // Icono más relevante
                size: 64,
                color: Colors.grey.withValues(alpha: 0.5)), // Opacidad
            const SizedBox(height: AppDimensions.md),
            Text(
              'batch_evaluation_empty_title'.tr,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
              child: Text(
                'batch_evaluation_empty_message'.tr,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton.icon(
              onPressed: () {
                // Acción para refrescar o ir a asignar retos
                final currentUser =
                    Get.find<SessionController>().currentUser.value;
                if (currentUser != null && currentUser.familyId != null) {
                  challengeController
                      .loadAllAssignedChallengesForFamily(currentUser.familyId!)
                      .then(
                          (_) => challengeController.applyEvaluationFilters());
                }
              },
              icon: const Icon(Icons.refresh),
              label: Text('batch_evaluation_empty_button_refresh'
                  .tr), // Texto más genérico
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white, // Color del texto e icono
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg, vertical: AppDimensions.sm),
                  textStyle: const TextStyle(fontSize: AppDimensions.fontMd)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedChallengeEvaluationCard(
      AssignedChallenge assignedChallenge, FamilyChild? child) {
    final isSelectedForEvaluation = challengeController
        .isAssignedChallengeSelectedForEvaluation(assignedChallenge.id);

    // Obtener el estado actual de la ejecución o del reto
    final status = assignedChallenge.currentStatus;

    return Card(
      elevation: isSelectedForEvaluation ? 3 : 1, // Sombra sutil
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        side: isSelectedForEvaluation
            ? const BorderSide(color: AppColors.primary, width: 1.5)
            : BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        onTap: () {
          challengeController.toggleAssignedChallengeSelectionForEvaluation(
              assignedChallenge.id);
        },
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAssignedChallengeEvaluationHeader(
                  assignedChallenge, child, status),
              const SizedBox(height: AppDimensions.sm),
              Divider(color: Colors.grey.shade200),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
                child: Text(
                  assignedChallenge.originalChallengeDescription,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              _buildAssignedChallengeEvaluationInfo(assignedChallenge),
              if (isSelectedForEvaluation) ...[
                const SizedBox(
                    height: AppDimensions
                        .md), // Más espacio antes de los campos de evaluación
                _buildEvaluationFields(assignedChallenge),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignedChallengeEvaluationHeader(
      AssignedChallenge assignedChallenge,
      FamilyChild? child,
      AssignedChallengeStatus status) {
    return Row(
      children: [
        Obx(() => Checkbox(
              value:
                  challengeController.isAssignedChallengeSelectedForEvaluation(
                      assignedChallenge.id),
              onChanged: (_) {
                challengeController
                    .toggleAssignedChallengeSelectionForEvaluation(
                        assignedChallenge.id);
              },
              activeColor: AppColors.primary,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )),
        const SizedBox(width: AppDimensions.xs), // Reducir espacio
        Container(
          padding: const EdgeInsets.all(AppDimensions.xs),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withValues(alpha: 0.15), // Opacidad
            shape: BoxShape.circle,
          ),
          child: Icon(_getStatusIcon(status),
              color: _getStatusColor(status), size: 18),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Text(
            assignedChallenge.originalChallengeTitle,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        if (child != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedAvatar(url: child.avatarUrl, radius: 12),
              const SizedBox(width: AppDimensions.xs),
              Text(child.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
      ],
    );
  }

  Widget _buildAssignedChallengeEvaluationInfo(
      AssignedChallenge assignedChallenge) {
    final currentExecution = assignedChallenge.currentExecution;
    final startDate =
        currentExecution?.startDate ?? assignedChallenge.startDate;
    // Para la fecha de fin, si es un reto continuo y no hay endDate en la ejecución, puede ser null.
    final endDate = currentExecution?.endDate ?? assignedChallenge.endDate;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 14, color: Colors.grey.shade600),
            const SizedBox(width: AppDimensions.xs),
            Text(
              // Usar Get.locale.languageCode para el formato de fecha
              endDate != null
                  ? _formatDateRange(
                      startDate, endDate, Get.locale?.languageCode)
                  : "${_formatDate(startDate, Get.locale?.languageCode)} - ${TrKeys.neverEnds.tr}",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.star_border_outlined,
                size: 16, color: Colors.amber.shade700), // Icono de estrella
            const SizedBox(width: AppDimensions.xs),
            Text(
              "${assignedChallenge.originalChallengePoints} ${TrKeys.points.tr}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEvaluationFields(AssignedChallenge assignedChallenge) {
    final String assignedChallengeId = assignedChallenge.id;
    final currentAdjustedPoints =
        challengeController.getAdjustedPointsForEvaluation(assignedChallengeId);

    // Sincronizar el controlador de texto si no existe o el valor difiere
    if (!_pointsTextControllers.containsKey(assignedChallengeId)) {
      _pointsTextControllers[assignedChallengeId] =
          TextEditingController(text: currentAdjustedPoints.toString());
      _pointsTextControllers[assignedChallengeId]!.addListener(() {
        final points = int.tryParse(
                _pointsTextControllers[assignedChallengeId]!.text) ??
            assignedChallenge
                .originalChallengePoints; // Default a puntos originales si el parseo falla
        challengeController.updateAdjustedPointsForEvaluation(
            assignedChallengeId, points);
      });
    } else {
      // Asegurar que el texto del controlador refleje el estado del ChallengeController
      // Esto es importante si los puntos se inicializan o cambian externamente.
      final controllerText = _pointsTextControllers[assignedChallengeId]!.text;
      final controllerPoints = int.tryParse(controllerText);
      if (controllerPoints != currentAdjustedPoints) {
        // Solo actualizar si es diferente para evitar bucles y pérdida de cursor
        _pointsTextControllers[assignedChallengeId]!.value = TextEditingValue(
          text: currentAdjustedPoints.toString(),
          selection: TextSelection.collapsed(
              offset: currentAdjustedPoints.toString().length),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: Colors.grey.shade200),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            Text('batch_evaluation_adjust_points'.tr,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: TextFormField(
                controller: _pointsTextControllers[assignedChallengeId],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.star, color: Colors.amber.shade700, size: 18),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md, vertical: AppDimensions.sm),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.5), // Color de fondo sutil
                  isDense: true,
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBatchEvaluationToolbar() {
    final selectedCount =
        challengeController.selectedAssignedChallengeIdsForEvaluation.length;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
          color: Theme.of(context)
              .scaffoldBackgroundColor, // Usar color de fondo del scaffold
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1), // Sombra más suave
              blurRadius: 8,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
              top: BorderSide(
                  color: Colors.grey.shade300, width: 1)) // Borde superior
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // 'batch_evaluation_toolbar_title'
            //     .trParams({'count': selectedCount.toString()}),
            Tr.tp('batch_evaluation_toolbar_title',
                {'count': selectedCount.toString()}),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Text('batch_evaluation_status'.tr,
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: DropdownButtonFormField<AssignedChallengeStatus>(
                  value: selectedEvaluationStatusToApply,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.md,
                        vertical: AppDimensions.sm +
                            2), // Un poco más de padding vertical
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusMd),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusMd),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusMd),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.5),
                  ),
                  items: [
                    // Solo permitir completar o fallar en lote
                    DropdownMenuItem<AssignedChallengeStatus>(
                        value: AssignedChallengeStatus.completed,
                        child: Text(TrKeys.completed.tr)),
                    DropdownMenuItem<AssignedChallengeStatus>(
                        value: AssignedChallengeStatus.failed,
                        child: Text(TrKeys.failed.tr)),
                    // Podríamos añadir "Pendiente" si se quiere revertir una evaluación accidental,
                    // pero para la evaluación inicial, "Completado" o "Fallido" son los principales.
                    // DropdownMenuItem<AssignedChallengeStatus>(
                    //     value: AssignedChallengeStatus.pending,
                    //     child: Text(TrKeys.pending.tr)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedEvaluationStatusToApply = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          TextFormField(
            controller: _unifiedEvaluationNoteController,
            decoration: InputDecoration(
              hintText:
                  TrKeys.evaluationNoteOptionalHint.tr, // Hint más descriptivo
              labelText: TrKeys.evaluationNote.tr,
              prefixIcon: Icon(Icons.notes_outlined, // Icono diferente
                  color: Colors.grey.shade600,
                  size: 20),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              filled: true,
              fillColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md, vertical: AppDimensions.md),
            ),
            maxLines: 2,
            minLines: 1, // Permitir que sea más pequeño
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(
              height: AppDimensions.lg), // Más espacio antes del botón
          AuthButton(
              text:
                  // 'batch_evaluation_button_text'
                  //     .trParams({'count': selectedCount.toString()})
                  Tr.tp('batch_evaluation_button_text',
                      {'count': selectedCount.toString()}),
              onPressed: challengeController.isEvaluatingChallenge.value
                  ? null
                  : () {
                      // Validar que haya retos seleccionados
                      if (challengeController
                          .selectedAssignedChallengeIdsForEvaluation.isEmpty) {
                        Get.snackbar(
                          TrKeys.warning.tr,
                          'batch_evaluation_no_challenges_selected_warning'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.amber.shade100,
                          colorText: Colors.amber.shade800,
                        );
                        return;
                      }
                      challengeController.evaluateSelectedChallenges(
                          status: selectedEvaluationStatusToApply);
                    },
              isLoading: challengeController.isEvaluatingChallenge.value,
              type: AuthButtonType.primary),
        ],
      ),
    );
  }

  // --- Métodos auxiliares ---

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

  IconData _getDurationIcon(ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.weekly:
        return Icons.calendar_view_week_outlined;
      case ChallengeDuration.monthly:
        return Icons.calendar_view_month_outlined;
      case ChallengeDuration.quarterly:
        return Icons.calendar_today_outlined; // Podría ser otro más específico
      case ChallengeDuration.yearly:
        return Icons.event_note_outlined;
      case ChallengeDuration.punctual:
        return Icons.event_available_outlined;
    }
  }

  Color _getDurationColor(ChallengeDuration duration) {
    // Usar colores del tema o colores más consistentes
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (duration) {
      case ChallengeDuration.weekly:
        return isDarkMode ? Colors.blueGrey.shade300 : Colors.blueGrey.shade700;
      case ChallengeDuration.monthly:
        return isDarkMode ? Colors.teal.shade300 : Colors.teal.shade700;
      case ChallengeDuration.quarterly:
        return isDarkMode ? Colors.cyan.shade300 : Colors.cyan.shade700;
      case ChallengeDuration.yearly:
        return isDarkMode
            ? Colors.lightGreen.shade300
            : Colors.lightGreen.shade700;
      case ChallengeDuration.punctual:
        return isDarkMode
            ? Colors.indigoAccent.shade100
            : Colors.indigoAccent.shade700;
    }
  }

  // String _getStatusName(AssignedChallengeStatus status) { // No se usa directamente en UI ahora
  //   switch (status) {
  //     case AssignedChallengeStatus.active:
  //       return TrKeys.active.tr;
  //     case AssignedChallengeStatus.completed:
  //       return TrKeys.completed.tr;
  //     case AssignedChallengeStatus.failed:
  //       return TrKeys.failed.tr;
  //     case AssignedChallengeStatus.pending:
  //       return TrKeys.pending.tr;
  //     case AssignedChallengeStatus.inactive:
  //       return TrKeys.inactive.tr;
  //   }
  // }

  Color _getStatusColor(AssignedChallengeStatus status) {
    // Usar colores del tema o colores más consistentes
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case AssignedChallengeStatus.active:
        return AppColors.statusActive; // Usar colores definidos si existen
      case AssignedChallengeStatus.completed:
        return AppColors.statusCompleted;
      case AssignedChallengeStatus.failed:
        return AppColors.statusFailed;
      case AssignedChallengeStatus.pending:
        return AppColors.statusPending;
      case AssignedChallengeStatus.inactive:
        return isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500;
    }
  }

  IconData _getStatusIcon(AssignedChallengeStatus status) {
    switch (status) {
      case AssignedChallengeStatus.active:
        return Icons.hourglass_top_outlined;
      case AssignedChallengeStatus.completed:
        return Icons.check_circle_outline;
      case AssignedChallengeStatus.failed:
        return Icons.cancel_outlined;
      case AssignedChallengeStatus.pending:
        return Icons.pending_outlined;
      case AssignedChallengeStatus.inactive:
        return Icons
            .pause_circle_outline_outlined; // Icono más adecuado para inactivo
    }
  }

  // String _getCategoryName(ChallengeCategory category) { // No se usa en esta página
  //   // ...
  // }

  String _formatDateRange(DateTime start, DateTime end, String? locale) {
    // Asegurar que el locale no sea null o vacío para DateFormat
    final effectiveLocale =
        (locale != null && locale.isNotEmpty) ? locale : null;
    try {
      return "${DateFormat('d MMM', effectiveLocale).format(start)} - ${DateFormat('d MMM, yyyy', effectiveLocale).format(end)}";
    } catch (e) {
      // Fallback si hay error con el locale específico
      return "${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM, yyyy').format(end)}";
    }
  }

  String _formatDate(DateTime date, String? locale) {
    final effectiveLocale =
        (locale != null && locale.isNotEmpty) ? locale : null;
    try {
      return DateFormat('d MMM, yyyy', effectiveLocale).format(date);
    } catch (e) {
      return DateFormat('d MMM, yyyy').format(date);
    }
  }
}
