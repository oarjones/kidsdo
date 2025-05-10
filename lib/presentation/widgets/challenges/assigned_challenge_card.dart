// File: kidsdo_gemini/lib/presentation/widgets/challenges/assigned_challenge_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/widgets/challenges/execution_summary_widget.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';

class AssignedChallengeCard extends StatelessWidget {
  final AssignedChallenge assignedChallenge;
  final Challenge challenge;
  final FamilyChild? child;
  final VoidCallback onTap;
  final VoidCallback onEvaluate;

  const AssignedChallengeCard({
    Key? key,
    required this.assignedChallenge,
    required this.challenge,
    this.child,
    required this.onTap,
    required this.onEvaluate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtener la ejecución actual si existe
    final currentExecution = assignedChallenge.currentExecution;

    // Determinar fechas relevantes (de la ejecución actual o del reto completo)
    final DateTime startDate =
        currentExecution?.startDate ?? assignedChallenge.startDate;
    final DateTime? endDate =
        currentExecution?.endDate ?? assignedChallenge.endDate;

    // Eliminado el Card principal para que el Card alternado esté en la página principal
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera con estado y asignación
            _buildHeader(),

            const SizedBox(height: AppDimensions.sm),
            const Divider(),

            // Título y detalles del reto
            _buildChallengeInfo(),

            // Si hay una ejecución actual, mostrar información
            if (currentExecution != null && assignedChallenge.isContinuous)
              ..._buildExecutionInfo(currentExecution, startDate, endDate),

            const SizedBox(height: AppDimensions.md),

            // Mostrar ejecuciones o botón para evaluar
            _buildEvaluationSection(currentExecution, startDate, endDate),

            // Mostrar resumen de la ejecución actual
            if (assignedChallenge.executions.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.sm),
              ExecutionSummaryWidget(
                execution: assignedChallenge.currentExecution!,
                isCurrentExecution: true,
                challenge: challenge,
                assignedChallenge: assignedChallenge,
                showProgressBar: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    //final currentExecution = assignedChallenge.currentExecution;

    return Row(
      children: [
        // Icono de estado
        Container(
          padding: const EdgeInsets.all(AppDimensions.sm),
          decoration: BoxDecoration(
            color:
                _getStatusColor(assignedChallenge.status).withValues(alpha: 50),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(assignedChallenge.status),
            color: _getStatusColor(assignedChallenge.status),
            size: 20,
          ),
        ),
        const SizedBox(width: AppDimensions.sm),

        // Estado
        Text(
          _getStatusName(assignedChallenge.status),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getStatusColor(assignedChallenge.status),
          ),
        ),

        // Indicador de reto continuo si aplica
        if (assignedChallenge.isContinuous) ...[
          const SizedBox(width: AppDimensions.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 50),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.repeat,
                  color: Colors.indigo,
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  TrKeys.continuousChallenge.tr,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        ],

        const Spacer(),

        // Asignado a (niño)
        if (child != null) ...[
          child!.avatarUrl != null
              ? CachedAvatar(url: child!.avatarUrl, radius: 16)
              : CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.withValues(alpha: 50),
                  child: const Icon(Icons.person, size: 16, color: Colors.grey),
                ),
          const SizedBox(width: AppDimensions.xs),
          Text(
            child!.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChallengeInfo() {
    final currentExecution = assignedChallenge.currentExecution;
    final endDate = currentExecution?.endDate ?? assignedChallenge.endDate;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono de categoría
        Container(
          padding: const EdgeInsets.all(AppDimensions.sm),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 20),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
          ),
          child: Icon(
            _getCategoryIcon(challenge.category),
            color: Colors.grey.shade700,
            size: 24,
          ),
        ),
        const SizedBox(width: AppDimensions.sm),

        // Título y categoría
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.title,
                style: const TextStyle(
                  fontSize: AppDimensions.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.xs),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      // Color del chip de categoría - Ajustado para mejor contraste
                      color: _getCategoryColor(challenge.category)
                          .withValues(alpha: 50),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusSm),
                    ),
                    child: Text(
                      _getCategoryName(challenge.category),
                      style: TextStyle(
                        fontSize: 10,
                        // Color del texto del chip - Ajustado para mejor contraste
                        color: _getCategoryColor(challenge.category),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Puntos y fecha
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: AppDimensions.xs,
              ),
              decoration: BoxDecoration(
                // Color de fondo de puntos - Ajustado para mejor contraste
                color: Colors.blueGrey
                    .withValues(alpha: 50), // Cambiado de amber a blueGrey
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color del icono de puntos - Ajustado para mejor contraste
                  const Icon(
                    Icons.star,
                    color: Colors.blueGrey, // Cambiado de amber a blueGrey
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    "${assignedChallenge.pointsEarned}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      // Color del texto de puntos - Ajustado para mejor contraste
                      color: Colors.blueGrey, // Cambiado de amber a blueGrey
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.xs),

            // Si no es fecha nula, mostrar fecha de vencimiento
            if (endDate != null)
              Text(
                _formatDate(endDate),
                style: TextStyle(
                  fontSize: 12,
                  color:
                      _isOverdue(endDate) ? Colors.red : Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildExecutionInfo(ChallengeExecution currentExecution,
      DateTime startDate, DateTime? endDate) {
    return [
      const SizedBox(height: AppDimensions.sm),
      Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 20),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "${TrKeys.currentExecution.tr}: ${_formatDateRange(currentExecution.startDate, currentExecution.endDate)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xs),
            Row(
              children: [
                Icon(
                  Icons.format_list_numbered,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Execution ${assignedChallenge.executions.indexOf(currentExecution) + 1} of ${assignedChallenge.executions.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(currentExecution.status)
                        .withValues(alpha: 50),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusSm),
                  ),
                  child: Text(
                    _getStatusName(currentExecution.status),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(currentExecution.status),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildEvaluationSection(ChallengeExecution? currentExecution,
      DateTime startDate, DateTime? endDate) {
    final lastEvaluationDate =
        _getLastEvaluationDate(assignedChallenge, currentExecution);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Última evaluación (si existe)
        if (lastEvaluationDate.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.history,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                "${TrKeys.lastEvaluation.tr}: $lastEvaluationDate",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          )
        else
          const SizedBox(),

        // Botón para evaluar
        _shouldShowEvaluateButton(currentExecution)
            ? ElevatedButton.icon(
                onPressed: onEvaluate,
                icon: const Icon(Icons.rate_review, size: 16),
                label: Text(TrKeys.evaluateChallenge.tr),
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  bool _shouldShowEvaluateButton(ChallengeExecution? currentExecution) {
    // Si hay una ejecución actual, verificar si está completada o fallida
    if (currentExecution != null) {
      return currentExecution.status == AssignedChallengeStatus.active ||
          currentExecution.status == AssignedChallengeStatus.pending;
    }

    // Si no hay ejecución actual, verificar el estado general del reto
    return assignedChallenge.status == AssignedChallengeStatus.active ||
        assignedChallenge.status == AssignedChallengeStatus.pending;
  }

  // Obtener fecha de la última evaluación (de la ejecución actual o del reto completo)
  String _getLastEvaluationDate(
      AssignedChallenge challenge, ChallengeExecution? execution) {
    // Primero buscar en la ejecución actual
    if (execution != null && execution.evaluation != null) {
      return DateFormat('MMM d').format(execution.evaluation!.date);
    }

    // Si no hay evaluaciones en la ejecución actual, buscar en el reto completo
    if (challenge.executions.isNotEmpty &&
        challenge.executions.last.evaluation != null) {
      return DateFormat('MMM d')
          .format(challenge.executions.last.evaluation!.date);
    }

    return '';
  }

  // Formatear rango de fechas
  String _formatDateRange(DateTime start, DateTime end) {
    return "${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}";
  }

  // Determinar si una fecha de finalización está vencida
  bool _isOverdue(DateTime endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(endDate.year, endDate.month, endDate.day);

    return dateOnly.isBefore(today);
  }

  // Formatear fecha para mostrar
  String _formatDate(DateTime? date) {
    final actualDate = date ?? DateTime.now();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly =
        DateTime(actualDate.year, actualDate.month, actualDate.day);

    if (dateOnly == today) {
      return '${TrKeys.today.tr} (${DateFormat('MMM d').format(actualDate)})';
    } else if (dateOnly == yesterday) {
      return '${TrKeys.yesterday.tr} (${DateFormat('MMM d').format(actualDate)})';
    } else if (dateOnly == tomorrow) {
      return '${TrKeys.tomorrow.tr} (${DateFormat('MMM d').format(actualDate)})';
    } else if (dateOnly.isAfter(today)) {
      final difference = dateOnly.difference(today).inDays;
      return '$difference ${difference == 1 ? TrKeys.days.tr : TrKeys.daysLeft.tr}';
    } else {
      final difference = today.difference(dateOnly).inDays;
      return '$difference ${difference == 1 ? TrKeys.days.tr : TrKeys.daysAgo.tr}';
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

  // Obtener color de estado
  Color _getStatusColor(AssignedChallengeStatus status) {
    switch (status) {
      case AssignedChallengeStatus.active:
        return Colors.blue;
      case AssignedChallengeStatus.completed:
        return Colors.green;
      case AssignedChallengeStatus.failed:
        return Colors.red;
      case AssignedChallengeStatus.pending:
        return Colors.orange;
      case AssignedChallengeStatus.inactive:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(AssignedChallengeStatus status) {
    switch (status) {
      case AssignedChallengeStatus.active:
        return Icons.hourglass_top;
      case AssignedChallengeStatus.completed:
        return Icons.check_circle;
      case AssignedChallengeStatus.failed:
        return Icons.cancel;
      case AssignedChallengeStatus.pending:
        return Icons.pending;
      case AssignedChallengeStatus.inactive:
        return Icons.cancel_outlined;
    }
  }

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

  // Obtener color de categoría
  Color _getCategoryColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return Colors.blue;
      case ChallengeCategory.school:
        return Colors.purple;
      case ChallengeCategory.order:
        return Colors.teal;
      case ChallengeCategory.responsibility:
        return Colors.orange;
      case ChallengeCategory.help:
        return Colors.green;
      case ChallengeCategory.special:
        return Colors.pink;
      case ChallengeCategory.sibling:
        return Colors.indigo;
    }
  }

  // Obtener icono de categoría
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
