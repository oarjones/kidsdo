// lib/presentation/widgets/challenges/execution_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';

class ExecutionSummaryWidget extends StatelessWidget {
  final ChallengeExecution execution;
  final bool isCurrentExecution;
  final Challenge? challenge;
  final AssignedChallenge? assignedChallenge;
  final bool showProgressBar;

  const ExecutionSummaryWidget({
    Key? key,
    required this.execution,
    this.isCurrentExecution = false,
    this.challenge,
    this.assignedChallenge,
    this.showProgressBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 10),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(
          color: _getStatusColor(execution.status).withValues(alpha: 100),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera con estado y fechas
            _buildExecutionHeader(),
            const SizedBox(height: AppDimensions.sm),

            // Barra de progreso si aplica
            if (showProgressBar && _shouldShowProgress()) ...[
              _buildProgressIndicator(),
              const SizedBox(height: AppDimensions.sm),
            ],

            // Evaluaciones realizadas
            if (execution.evaluation != null) ...[
              _buildEvaluationsList(),
            ] else ...[
              _buildNoEvaluationsPlaceholder(),
            ],

            // Puntos ganados
            _buildPointsSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Indicador de ejecución actual
            if (isCurrentExecution)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 50),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSm),
                ),
                child: Text(
                  TrKeys.currentExecution.tr,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (isCurrentExecution) const SizedBox(width: AppDimensions.sm),

            // Estado
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(execution.status).withValues(alpha: 50),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(execution.status),
                    size: 12,
                    color: _getStatusColor(execution.status),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _getStatusName(execution.status),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(execution.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.xs),

        // Fechas
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDateRange(execution.startDate, execution.endDate),
              style: TextStyle(
                fontSize: AppDimensions.fontSm,
                color: Colors.grey.shade700,
              ),
            ),
            // Indicador de duración
            if (_isDurationVisible()) ...[
              const SizedBox(width: 8),
              Text(
                "•",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(width: 4),
              Text(
                _getDurationString(),
                style: TextStyle(
                  fontSize: AppDimensions.fontSm,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _calculateProgress();
    final progressColor = _getProgressColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${(progress * 100).toInt()}% ${TrKeys.completed.tr}",
          style: TextStyle(
            fontSize: AppDimensions.fontSm,
            fontWeight: FontWeight.bold,
            color: progressColor,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.withValues(alpha: 50),
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildEvaluationsList() {
    // Solo mostrar si hay una evaluación
    if (execution.evaluation == null) {
      return _buildNoEvaluationsPlaceholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${TrKeys.evaluations.tr} (1)",
          style: const TextStyle(
            fontSize: AppDimensions.fontSm,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        _buildEvaluationItem(execution.evaluation!),
      ],
    );
  }

  Widget _buildEvaluationItem(ChallengeEvaluation evaluation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _getStatusColor(evaluation.status).withValues(alpha: 50),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(evaluation.status),
              size: 12,
              color: _getStatusColor(evaluation.status),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat.MMMd().add_jm().format(evaluation.date),
            style: const TextStyle(
              fontSize: AppDimensions.fontSm,
            ),
          ),
          const SizedBox(width: 8),
          if (evaluation.points > 0)
            Text(
              "+${evaluation.points}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          if (evaluation.note != null) ...[
            const Spacer(),
            Flexible(
              child: Text(
                evaluation.note!,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSm,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMedium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoEvaluationsPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            TrKeys.noEvaluationsYet.tr,
            style: TextStyle(
              fontSize: AppDimensions.fontSm,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSummary() {
    final pointsEarned = execution.evaluation?.points ?? 0;
    final expectedPoints = challenge?.points ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 10),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
        border: Border.all(color: Colors.amber.withValues(alpha: 100)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star,
            color: Colors.amber,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            "$pointsEarned",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            TrKeys.pointsEarned.tr,
            style: TextStyle(
              fontSize: AppDimensions.fontSm,
              color: Colors.grey.shade700,
            ),
          ),
          if (expectedPoints > 0 && pointsEarned > 0) ...[
            const Spacer(),
            Text(
              "${(pointsEarned / expectedPoints * 100).toInt()}%",
              style: TextStyle(
                fontSize: AppDimensions.fontSm,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Métodos auxiliares
  String _formatDateRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    if (startDate.isAtSameMomentAs(endDate)) {
      // Mismo día
      if (startDate.isAtSameMomentAs(today)) {
        return TrKeys.today.tr;
      } else {
        return DateFormat.MMMd().format(start);
      }
    } else if (start.year == end.year && start.month == end.month) {
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

  bool _shouldShowProgress() {
    // Mostrar progreso solo si la ejecución está activa y tiene fechas válidas
    return execution.status == AssignedChallengeStatus.active &&
        execution.startDate.isBefore(execution.endDate);
  }

  double _calculateProgress() {
    final now = DateTime.now();
    final start = execution.startDate;
    final end = execution.endDate;

    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(end)) return 1.0;

    final totalDuration = end.difference(start).inSeconds;
    final elapsed = now.difference(start).inSeconds;

    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  Color _getProgressColor() {
    if (execution.status == AssignedChallengeStatus.active) {
      return AppColors.primary;
    } else if (execution.status == AssignedChallengeStatus.completed) {
      return Colors.green;
    } else if (execution.status == AssignedChallengeStatus.failed) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  bool _isDurationVisible() {
    // Mostrar duración si el reto tiene información disponible
    return challenge != null || assignedChallenge != null;
  }

  String _getDurationString() {
    if (challenge == null && assignedChallenge == null) return '';

    // Calcular duración actual de la ejecución
    final duration = execution.endDate.difference(execution.startDate);
    final days = duration.inDays;

    if (days == 1) {
      return "1 ${TrKeys.day.tr}";
    } else if (days < 7) {
      return "$days ${TrKeys.days.tr}";
    } else if (days < 30) {
      final weeks = (days / 7).round();
      return "$weeks ${weeks == 1 ? TrKeys.week.tr : TrKeys.weeks.tr}";
    } else {
      final months = (days / 30).round();
      return "$months ${months == 1 ? TrKeys.month.tr : TrKeys.months.tr}";
    }
  }

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
        return Icons.play_circle_outline;
      case AssignedChallengeStatus.completed:
        return Icons.check_circle;
      case AssignedChallengeStatus.failed:
        return Icons.cancel;
      case AssignedChallengeStatus.pending:
        return Icons.pending;
      case AssignedChallengeStatus.inactive:
        return Icons.disabled_by_default;
    }
  }

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
