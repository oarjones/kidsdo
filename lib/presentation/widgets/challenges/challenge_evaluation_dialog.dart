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
    final bool evaluatingExecution = selectedExecution != null;

    // Determinar fechas relevantes para mostrar
    final DateTime startDate =
        selectedExecution?.startDate ?? widget.assignedChallenge.startDate;
    final DateTime? endDate =
        selectedExecution?.endDate ?? widget.assignedChallenge.endDate;

    return AlertDialog(
      title: Text(TrKeys.evaluateChallengeTitle.tr),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del reto y niño
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
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(widget.child!.name),
                ],
              ),
            ],
            const SizedBox(height: AppDimensions.md),

            // Si es un reto continuo con múltiples ejecuciones
            if (widget.assignedChallenge.isContinuous &&
                widget.assignedChallenge.executions.length > 1) ...[
              Text(
                TrKeys.evaluatingExecution.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),

              // Selector de ejecución
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 150)),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSm),
                ),
                child: DropdownButton<int>(
                  value: executionIndex,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        executionIndex = value;
                        selectedExecution =
                            widget.assignedChallenge.executions[value];
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
                          i == widget.assignedChallenge.executions.length - 1
                              ? "${TrKeys.currentExecution.tr} (${_formatDateRange(widget.assignedChallenge.executions[i].startDate, widget.assignedChallenge.executions[i].endDate)})"
                              : "${TrKeys.execution.tr} ${i + 1} (${_formatDateRange(widget.assignedChallenge.executions[i].startDate, widget.assignedChallenge.executions[i].endDate)})",
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.md),
            ],

            // Información del período evaluado
            ...[
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      endDate != null
                          ? "${TrKeys.evaluationPeriod.tr}: ${_formatDateRange(startDate, endDate)}"
                          : "${TrKeys.startDate.tr}: ${DateFormat('MMM d, yyyy').format(startDate)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
            ],

            // Opciones de evaluación
            Text(
              TrKeys.status.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),

            Wrap(
              spacing: AppDimensions.sm,
              children: [
                // Opción Completado
                ChoiceChip(
                  label: Text(TrKeys.completed.tr),
                  selected: selectedEvaluationStatus ==
                      AssignedChallengeStatus.completed,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedEvaluationStatus =
                            AssignedChallengeStatus.completed;
                        assignedPoints = widget
                            .challenge.points; // Restaurar puntos originales
                      });
                    }
                  },
                  backgroundColor: Colors.grey.withValues(alpha: 50),
                  selectedColor: Colors.green.withValues(alpha: 100),
                  avatar: const Icon(Icons.check_circle,
                      color: Colors.green, size: 18),
                ),

                // Opción Fallido
                ChoiceChip(
                  label: Text(TrKeys.failed.tr),
                  selected: selectedEvaluationStatus ==
                      AssignedChallengeStatus.failed,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedEvaluationStatus =
                            AssignedChallengeStatus.failed;
                        assignedPoints = 0; // Cero puntos si falla
                      });
                    }
                  },
                  backgroundColor: Colors.grey.withValues(alpha: 50),
                  selectedColor: Colors.red.withValues(alpha: 100),
                  avatar: const Icon(Icons.cancel, color: Colors.red, size: 18),
                ),

                // Opción Pendiente
                ChoiceChip(
                  label: Text(TrKeys.pending.tr),
                  selected: selectedEvaluationStatus ==
                      AssignedChallengeStatus.pending,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedEvaluationStatus =
                            AssignedChallengeStatus.pending;
                        assignedPoints = 0; // Cero puntos si está pendiente
                      });
                    }
                  },
                  backgroundColor: Colors.grey.withValues(alpha: 50),
                  selectedColor: Colors.orange.withValues(alpha: 100),
                  avatar:
                      const Icon(Icons.pending, color: Colors.orange, size: 18),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            // Selector de puntos
            if (selectedEvaluationStatus ==
                AssignedChallengeStatus.completed) ...[
              Text(
                TrKeys.points.tr,
                style: const TextStyle(
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
                      max: widget.challenge.points *
                          1.5, // Permitir hasta un 50% más de puntos
                      divisions: widget.challenge.points *
                          3, // Divisiones para mayor precisión
                      label: assignedPoints.toString(),
                      onChanged: (value) {
                        setState(() {
                          assignedPoints = value.round();
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      assignedPoints.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Original: ${widget.challenge.points} ${TrKeys.points.tr}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.md),

            // Campo para nota
            Text(
              TrKeys.addNote.tr,
              style: const TextStyle(
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
                fillColor: Colors.grey.withValues(alpha: 20),
              ),
              maxLines: 3,
            ),

            // Si es un reto continuo, mostrar información sobre la siguiente ejecución
            if (widget.assignedChallenge.isContinuous &&
                (selectedEvaluationStatus ==
                        AssignedChallengeStatus.completed ||
                    selectedEvaluationStatus ==
                        AssignedChallengeStatus.failed) &&
                executionIndex ==
                    widget.assignedChallenge.executions.length - 1) ...[
              const SizedBox(height: AppDimensions.md),
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSm),
                  border: Border.all(color: AppColors.info),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            TrKeys.nextExecutionInfo.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      TrKeys.nextExecutionExplanation.tr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(TrKeys.cancel.tr),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);

            // Si estamos evaluando una ejecución específica
            if (evaluatingExecution && executionIndex >= 0) {
              widget.challengeController.evaluateExecution(
                assignedChallengeId: widget.assignedChallenge.id,
                executionIndex: executionIndex,
                status: selectedEvaluationStatus,
                points: assignedPoints,
                note:
                    noteController.text.isNotEmpty ? noteController.text : null,
              );
            } else {
              // Método legacy para compatibilidad
              widget.challengeController.evaluateAssignedChallenge(
                assignedChallengeId: widget.assignedChallenge.id,
                newStatus: selectedEvaluationStatus,
                points: assignedPoints,
                note:
                    noteController.text.isNotEmpty ? noteController.text : null,
              );
            }
          },
          child: Text(TrKeys.evaluateChallenge.tr),
        ),
      ],
    );
  }

  // Método para formatear rango de fechas
  String _formatDateRange(DateTime start, DateTime end) {
    return "${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}";
  }
}
