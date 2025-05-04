// lib/presentation/widgets/challenges/challenge_execution_indicator.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';

class ChallengeExecutionIndicator extends StatelessWidget {
  final AssignedChallenge assignedChallenge;

  const ChallengeExecutionIndicator({
    Key? key,
    required this.assignedChallenge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentExecution = assignedChallenge.currentExecution;

    if (currentExecution == null && !assignedChallenge.isContinuous) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del indicador
            Row(
              children: [
                Icon(
                  assignedChallenge.isContinuous ? Icons.repeat : Icons.event,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  assignedChallenge.isContinuous
                      ? TrKeys.continuousChallenge.tr
                      : TrKeys.currentExecution.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimensions.fontMd,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.md),

            // Información de la ejecución actual
            if (currentExecution != null) ...[
              _buildExecutionInfo(currentExecution),
              const SizedBox(height: AppDimensions.md),
              _buildExecutionProgress(currentExecution),
            ] else ...[
              // Para retos no continuos o cuando no hay ejecución actual
              _buildBasicInfo(),
            ],

            // Indicador de siguiente ejecución
            if (assignedChallenge.isContinuous)
              ..._buildNextExecutionInfo(currentExecution),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionInfo(ChallengeExecution execution) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        color: _getStatusColor(execution.status).withValues(alpha: 20),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
        border: Border.all(
          color: _getStatusColor(execution.status).withValues(alpha: 50),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 16,
                color: _getStatusColor(execution.status),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${DateFormat('MMM d').format(execution.startDate)} - ${DateFormat('MMM d, yyyy').format(execution.endDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(execution.status),
                  ),
                ),
              ),
            ],
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
                  color: _getStatusColor(execution.status),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSm),
                ),
                child: Text(
                  _getStatusName(execution.status),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                'Execution ${assignedChallenge.executions.indexOf(execution) + 1} of ${assignedChallenge.executions.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (execution.evaluations.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.xs),
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${execution.evaluations.length} ${execution.evaluations.length == 1 ? 'evaluation' : 'evaluations'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExecutionProgress(ChallengeExecution execution) {
    final now = DateTime.now();
    final total = execution.endDate.difference(execution.startDate).inDays;
    final elapsed = now.difference(execution.startDate).inDays;
    final progress = (elapsed / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withValues(alpha: 50),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatusColor(execution.status),
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          '${(progress * 100).toInt()}% complete',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Container(
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
                Icons.calendar_today,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '${TrKeys.startDate.tr}: ${DateFormat('MMM d, yyyy').format(assignedChallenge.startDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          if (assignedChallenge.endDate != null) ...[
            const SizedBox(height: AppDimensions.xs),
            Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${TrKeys.endDate.tr}: ${DateFormat('MMM d, yyyy').format(assignedChallenge.endDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildNextExecutionInfo(ChallengeExecution? currentExecution) {
    if (currentExecution == null) return [];

    // Determinar si se mostrará automáticamente la próxima ejecución
    final bool willCreateNext =
        currentExecution.status == AssignedChallengeStatus.completed ||
            currentExecution.status == AssignedChallengeStatus.failed;

    if (!willCreateNext) return [];

    // Calcular fechas de la próxima ejecución
    final nextStartDate = currentExecution.endDate.add(const Duration(days: 1));

    return [
      const SizedBox(height: AppDimensions.md),
      Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.infoLight,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
          border: Border.all(color: AppColors.info.withValues(alpha: 50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Next execution will start:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xs),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.info.withValues(alpha: 150),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(nextStartDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info.withValues(alpha: 150),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
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
}
