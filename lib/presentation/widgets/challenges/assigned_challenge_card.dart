import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        side: BorderSide(
          color:
              _getStatusColor(assignedChallenge.status).withValues(alpha: 50),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con estado y asignación
              Row(
                children: [
                  // Icono de estado
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.sm),
                    decoration: BoxDecoration(
                      color: _getStatusColor(assignedChallenge.status)
                          .withValues(alpha: 50),
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

                  const Spacer(),

                  // Asignado a (niño)
                  if (child != null) ...[
                    child!.avatarUrl != null
                        ? CachedAvatar(url: child!.avatarUrl, radius: 16)
                        : CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.withValues(alpha: 50),
                            child: const Icon(Icons.person,
                                size: 16, color: Colors.grey),
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
              ),
              const SizedBox(height: AppDimensions.sm),

              const Divider(),

              // Título y detalles del reto
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de categoría
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.sm),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 20),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusMd),
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
                                color: _getCategoryColor(challenge.category)
                                    .withValues(alpha: 50),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusSm),
                              ),
                              child: Text(
                                _getCategoryName(challenge.category),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getCategoryColor(challenge.category),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryLight,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusSm),
                              ),
                              child: Text(
                                _getFrequencyName(challenge.frequency),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Puntos
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: AppDimensions.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 50),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${assignedChallenge.pointsEarned}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        _formatDate(assignedChallenge.endDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: _isOverdue(assignedChallenge.endDate)
                              ? Colors.red
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.md),

              // Últimas evaluaciones o botón para evaluar
              if (assignedChallenge.evaluations.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${TrKeys.lastEvaluation.tr}: ${DateFormat('MMM d').format(assignedChallenge.evaluations.last.date)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    // Botón para evaluar
                    TextButton.icon(
                      onPressed: onEvaluate,
                      icon: const Icon(Icons.rate_review, size: 16),
                      label: Text(TrKeys.evaluateChallenge.tr),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                    ),
                  ],
                ),
              ] else
                // Botón para evaluar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onEvaluate,
                      icon: const Icon(Icons.rate_review, size: 16),
                      label: Text(TrKeys.evaluateChallenge.tr),
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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

  // Determinar si una fecha de finalización está vencida
  bool _isOverdue(DateTime endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(endDate.year, endDate.month, endDate.day);

    return dateOnly.isBefore(today);
  }

  // Formatear fecha para mostrar
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '${TrKeys.today.tr} (${DateFormat('MMM d').format(date)})';
    } else if (dateOnly == yesterday) {
      return '${TrKeys.yesterday.tr} (${DateFormat('MMM d').format(date)})';
    } else if (dateOnly == tomorrow) {
      return '${TrKeys.tomorrow.tr} (${DateFormat('MMM d').format(date)})';
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
    }
  }

  // Obtener icono de estado
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
    }
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
