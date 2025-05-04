// lib/presentation/widgets/challenges/challenge_evaluation_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';
import 'package:kidsdo/presentation/widgets/challenges/execution_summary_widget.dart';

class ChallengeEvaluationDialog extends StatefulWidget {
  final AssignedChallenge assignedChallenge;
  final Challenge challenge;
  final FamilyChild? child;
  final ChallengeController challengeController;

  const ChallengeEvaluationDialog({
    Key? key,
    required this.assignedChallenge,
    required this.challenge,
    this.child,
    required this.challengeController,
  }) : super(key: key);

  @override
  State<ChallengeEvaluationDialog> createState() =>
      _ChallengeEvaluationDialogState();

  // Método estático para mostrar el diálogo
  static Future<void> show({
    required BuildContext context,
    required AssignedChallenge assignedChallenge,
    required Challenge challenge,
    FamilyChild? child,
    required ChallengeController challengeController,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // Evitar cerrar accidentalmente
      builder: (context) => ChallengeEvaluationDialog(
        assignedChallenge: assignedChallenge,
        challenge: challenge,
        child: child,
        challengeController: challengeController,
      ),
    );
  }
}

class _ChallengeEvaluationDialogState extends State<ChallengeEvaluationDialog> {
  // Estado local
  late AssignedChallengeStatus selectedEvaluationStatus;
  late TextEditingController noteController;
  late int assignedPoints;

  // Estado para ejecuciones
  ChallengeExecution? selectedExecution;
  int executionIndex = -1;

  @override
  void initState() {
    super.initState();

    // Inicializar estado
    selectedEvaluationStatus = AssignedChallengeStatus.completed;
    noteController = TextEditingController();
    assignedPoints = widget.challenge.points;

    // Determinar la ejecución a evaluar
    if (widget.assignedChallenge.executions.isNotEmpty) {
      // Seleccionar la ejecución actual (última activa o pendiente)
      selectedExecution = widget.assignedChallenge.currentExecution;
      // Encontrar su índice
      executionIndex = selectedExecution != null
          ? widget.assignedChallenge.executions.indexOf(selectedExecution!)
          : widget.assignedChallenge.executions.length - 1;
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determinar si estamos evaluando una ejecución específica o el reto completo
    final bool hasExecutions = widget.assignedChallenge.executions.isNotEmpty;

    // Determinar fechas relevantes para mostrar
    final DateTime startDate =
        selectedExecution?.startDate ?? widget.assignedChallenge.startDate;
    final DateTime? endDate =
        selectedExecution?.endDate ?? widget.assignedChallenge.endDate;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXl),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera del diálogo
              Row(
                children: [
                  Expanded(
                    child: Text(
                      TrKeys.evaluateChallengeTitle.tr,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontXl,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),

              // Información del reto y niño
              _buildChallengeInfo(),
              const SizedBox(height: AppDimensions.lg),

              // Selector de ejecución (si hay múltiples)
              if (hasExecutions &&
                  widget.assignedChallenge.executions.length > 1) ...[
                _buildExecutionSelector(),
                const SizedBox(height: AppDimensions.lg),
              ],

              // Resumen de la ejecución actual
              if (selectedExecution != null) ...[
                ExecutionSummaryWidget(
                  execution: selectedExecution!,
                  isCurrentExecution: selectedExecution ==
                      widget.assignedChallenge.currentExecution,
                  challenge: widget.challenge,
                  assignedChallenge: widget.assignedChallenge,
                ),
                const SizedBox(height: AppDimensions.lg),
              ],

              // Resumen de puntos total del reto
              _buildTotalPointsSummary(),
              const SizedBox(height: AppDimensions.lg),

              // Opciones de evaluación
              _buildEvaluationOptions(),
              const SizedBox(height: AppDimensions.lg),

              // Selector de puntos
              if (selectedEvaluationStatus ==
                  AssignedChallengeStatus.completed) ...[
                _buildPointsSelector(),
                const SizedBox(height: AppDimensions.lg),
              ],

              // Campo para nota
              _buildNoteField(),

              // Información sobre retos continuos
              if (widget.assignedChallenge.isContinuous &&
                  (selectedEvaluationStatus ==
                          AssignedChallengeStatus.completed ||
                      selectedEvaluationStatus ==
                          AssignedChallengeStatus.failed) &&
                  executionIndex ==
                      widget.assignedChallenge.executions.length - 1) ...[
                const SizedBox(height: AppDimensions.lg),
                _buildContinuousChallengeInfo(),
              ],

              const SizedBox(height: AppDimensions.xl),

              // Botones de acción
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.challenge.title,
          style: const TextStyle(
            fontSize: AppDimensions.fontLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.child != null) ...[
          const SizedBox(height: AppDimensions.xs),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: widget.child!.avatarUrl != null
                    ? NetworkImage(widget.child!.avatarUrl!)
                    : null,
                child: widget.child!.avatarUrl == null
                    ? Icon(Icons.person,
                        size: 16, color: Colors.grey.withValues(alpha: 150))
                    : null,
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                widget.child!.name,
                style: const TextStyle(
                  fontSize: AppDimensions.fontMd,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildExecutionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.selectExecutionToEvaluate.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontMd,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
            border: Border.all(color: Colors.grey.withValues(alpha: 150)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: executionIndex,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    executionIndex = value;
                    selectedExecution =
                        widget.assignedChallenge.executions[value];
                    // Reiniciar estado de evaluación
                    selectedEvaluationStatus =
                        AssignedChallengeStatus.completed;
                    assignedPoints = widget.challenge.points;
                  });
                }
              },
              items: [
                for (int i = 0;
                    i < widget.assignedChallenge.executions.length;
                    i++)
                  DropdownMenuItem<int>(
                    value: i,
                    child: Text(
                      _getExecutionLabel(
                          i, widget.assignedChallenge.executions[i]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getExecutionLabel(int index, ChallengeExecution execution) {
    final isCurrentExecution =
        execution == widget.assignedChallenge.currentExecution;
    final dateRange = _formatDateRange(execution.startDate, execution.endDate);

    String label;
    if (index == widget.assignedChallenge.executions.length - 1) {
      label = "${TrKeys.currentExecution.tr} ($dateRange)";
    } else {
      label = "${TrKeys.execution.tr} ${index + 1} ($dateRange)";
    }

    // Agregar estado de la ejecución
    final statusText = _getStatusName(execution.status);
    return "$label - $statusText";
  }

  Widget _buildTotalPointsSummary() {
    final int totalPoints = widget.assignedChallenge.pointsEarned;
    final int pointsForThisExecution = selectedExecution?.evaluations
            .fold<int>(0, (sum, eval) => sum + eval.points) ??
        0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TrKeys.challengePointsSummary.tr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TrKeys.totalPointsAccumulated.tr),
              Text(
                totalPoints.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontLg,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TrKeys.pointsThisExecution.tr),
              Text(
                pointsForThisExecution.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.evaluateExecution.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontMd,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: [
            // Opción Completado
            _buildEvaluationChip(
              label: TrKeys.completed.tr,
              status: AssignedChallengeStatus.completed,
              color: Colors.green,
              icon: Icons.check_circle,
            ),

            // Opción Fallido
            _buildEvaluationChip(
              label: TrKeys.failed.tr,
              status: AssignedChallengeStatus.failed,
              color: Colors.red,
              icon: Icons.cancel,
            ),

            // Opción Pendiente
            _buildEvaluationChip(
              label: TrKeys.pending.tr,
              status: AssignedChallengeStatus.pending,
              color: Colors.orange,
              icon: Icons.pending,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEvaluationChip({
    required String label,
    required AssignedChallengeStatus status,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = selectedEvaluationStatus == status;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            selectedEvaluationStatus = status;
            // Ajustar puntos según estado
            if (status == AssignedChallengeStatus.completed) {
              assignedPoints = widget.challenge.points;
            } else {
              assignedPoints = 0;
            }
          });
        }
      },
      backgroundColor: color.withValues(alpha: 10),
      selectedColor: color.withValues(alpha: 20),
      checkmarkColor: color,
      side: BorderSide(
        color: isSelected ? color : color.withValues(alpha: 100),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildPointsSelector() {
    final maxPoints = (widget.challenge.points * 1.5).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.assignPoints.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontMd,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            Expanded(
              child: Slider(
                value: assignedPoints.toDouble(),
                min: 0,
                max: maxPoints.toDouble(),
                divisions: maxPoints,
                label: assignedPoints.toString(),
                onChanged: (value) {
                  setState(() {
                    assignedPoints = value.round();
                  });
                },
                activeColor: Colors.amber,
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(
                assignedPoints.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontLg,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: AppDimensions.md),
          child: Text(
            '${TrKeys.original.tr}: ${widget.challenge.points} ${TrKeys.points.tr}',
            style: const TextStyle(
              fontSize: AppDimensions.fontSm,
              color: AppColors.textMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TrKeys.addNote.tr,
          style: const TextStyle(
            fontSize: AppDimensions.fontMd,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        TextField(
          controller: noteController,
          decoration: InputDecoration(
            hintText: TrKeys.evaluationNote.tr,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 10),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildContinuousChallengeInfo() {
    // Calcular fecha de próxima ejecución
    final lastExecution = widget.assignedChallenge.executions.last;
    final nextStartDate = lastExecution.endDate.add(const Duration(days: 1));
    final nextEndDate = _calculateNextEndDate(nextStartDate);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(color: AppColors.info),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.repeat,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  TrKeys.continuousChallengeInfo.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            TrKeys.nextExecutionStartsAt.tr,
            style: const TextStyle(
              color: AppColors.info,
            ),
          ),
          Text(
            "${DateFormat.yMMMMd().format(nextStartDate)} - ${DateFormat.yMMMMd().format(nextEndDate)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(TrKeys.cancel.tr),
        ),
        const SizedBox(width: AppDimensions.sm),
        ElevatedButton(
          onPressed: () => _submitEvaluation(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
            ),
          ),
          child: Text(TrKeys.evaluateChallenge.tr),
        ),
      ],
    );
  }

  void _submitEvaluation() {
    // Cerrar diálogo
    Navigator.pop(context);

    // Realizar evaluación
    if (widget.assignedChallenge.executions.isNotEmpty && executionIndex >= 0) {
      // Evaluar ejecución específica
      widget.challengeController.evaluateExecution(
        assignedChallengeId: widget.assignedChallenge.id,
        executionIndex: executionIndex,
        status: selectedEvaluationStatus,
        points: assignedPoints,
        note: noteController.text.isNotEmpty ? noteController.text : null,
      );
    }
    // else {
    //   // Método legacy para compatibilidad
    //   widget.challengeController.evaluateAssignedChallenge(
    //     assignedChallengeId: widget.assignedChallenge.id,
    //     newStatus: selectedEvaluationStatus,
    //     points: assignedPoints,
    //     note: noteController.text.isNotEmpty ? noteController.text : null,
    //   );
    // }
  }

  DateTime _calculateNextEndDate(DateTime startDate) {
    // Basarse en la duración del challenge
    return widget.challengeController.calculateEndDate(
      startDate: startDate,
      duration: widget.challenge.duration,
    );
  }

  // Método para formatear rango de fechas
  String _formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      // Mismo mes
      return "${start.day}-${end.day} ${DateFormat.LLL().format(start)}";
    } else if (start.year == end.year) {
      // Mismo año, diferente mes
      return "${DateFormat.MMMd().format(start)} - ${DateFormat.MMMd().format(end)}";
    } else {
      // Diferentes años
      return "${DateFormat.yMMMd().format(start)} - ${DateFormat.yMMMd().format(end)}";
    }
  }

  // Obtener nombre de estado
  String _getStatusName(AssignedChallengeStatus status) {
    switch (status) {
      case AssignedChallengeStatus.active:
        return TrKeys.active.tr;
      case AssignedChallengeStatus.completed:
        return TrKeys.completed.tr;
      case AssignedChallengeStatus.failed:
        return TrKeys.failed.tr;
      case AssignedChallengeStatus.pending:
        return TrKeys.pending.tr;
      case AssignedChallengeStatus.inactive:
        return TrKeys.inactive.tr;
    }
  }
}
