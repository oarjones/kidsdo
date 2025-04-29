import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/presentation/widgets/child/age_adapted_container.dart';

class ChildChallengeCard extends StatelessWidget {
  final AssignedChallenge assignedChallenge;
  final Challenge challenge;
  final int childAge;
  final Map<String, dynamic> settings;
  final bool isCompleted;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback? onComplete;

  const ChildChallengeCard({
    Key? key,
    required this.assignedChallenge,
    required this.challenge,
    required this.childAge,
    required this.settings,
    this.isCompleted = false,
    this.isPending = false,
    required this.onTap,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color themeColor = _getThemeColor(settings);

    return AgeAdaptedContainer(
      childAge: childAge,
      settings: settings,
      defaultWidget: _buildDefaultCard(themeColor),
      youngChildWidget: _buildYoungChildCard(themeColor),
    );
  }

  Widget _buildDefaultCard(Color themeColor) {
    return Card(
      elevation: AppDimensions.elevationSm,
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y estado
              Row(
                children: [
                  Expanded(
                    child: Text(
                      challenge.title,
                      style: TextStyle(
                        fontSize: AppDimensions.fontMd,
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  _buildStatusIcon(themeColor),
                ],
              ),

              const SizedBox(height: AppDimensions.sm),

              // Descripción
              Text(
                challenge.description,
                style: TextStyle(
                  fontSize: AppDimensions.fontSm,
                  color: isCompleted ? Colors.grey : AppColors.textMedium,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppDimensions.md),

              // Puntos y botón de completar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Puntos
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.grey.withValues(alpha: 50)
                          : themeColor.withValues(alpha: 50),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusSm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: isCompleted ? Colors.grey : themeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          challenge.points.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.grey : themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botón de completar (solo si no está completado ni pendiente)
                  if (!isCompleted && !isPending && onComplete != null)
                    ElevatedButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(TrKeys.markAsCompleted.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusSm),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: 0,
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                    ),

                  // Si está pendiente, mostrar indicador
                  if (isPending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: AppDimensions.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 50),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.borderRadiusSm),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            TrKeys.pendingApproval.tr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
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

  Widget _buildYoungChildCard(Color themeColor) {
    // Versión más visual para niños pequeños (3-6 años)
    return Card(
      elevation: AppDimensions.elevationMd,
      margin: const EdgeInsets.only(bottom: AppDimensions.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icono grande y colorido
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.grey.withValues(alpha: 50)
                      : themeColor.withValues(alpha: 50),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getChallengeIcon(challenge.category),
                    size: 40,
                    color: isCompleted ? Colors.grey : themeColor,
                  ),
                ),
              ),

              const SizedBox(width: AppDimensions.lg),

              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título grande
                    Text(
                      challenge.title,
                      style: TextStyle(
                        fontSize: AppDimensions.fontLg,
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.sm),

                    // Puntos grandes
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 24,
                          color: isCompleted ? Colors.grey : themeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          challenge.points.toString(),
                          style: TextStyle(
                            fontSize: AppDimensions.fontLg,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.grey : themeColor,
                          ),
                        ),
                        const Spacer(),
                        _buildStatusIcon(themeColor, size: 32),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(Color themeColor, {double size = 24}) {
    if (isCompleted) {
      return Icon(
        Icons.check_circle,
        color: Colors.green,
        size: size,
      );
    } else if (isPending) {
      return Icon(
        Icons.pending,
        color: Colors.orange,
        size: size,
      );
    } else {
      return Icon(
        Icons.circle_outlined,
        color: themeColor,
        size: size,
      );
    }
  }

  IconData _getChallengeIcon(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.hygiene:
        return Icons.wash;
      case ChallengeCategory.school:
        return Icons.school;
      case ChallengeCategory.order:
        return Icons.cleaning_services;
      case ChallengeCategory.responsibility:
        return Icons.volunteer_activism;
      case ChallengeCategory.help:
        return Icons.emoji_people;
      case ChallengeCategory.special:
        return Icons.emoji_events;
      case ChallengeCategory.sibling:
        return Icons.people;
    }
  }

  Color _getThemeColor(Map<String, dynamic> settings) {
    final String colorKey = settings['color'] as String? ?? 'blue';

    switch (colorKey) {
      case 'purple':
        return AppColors.childPurple;
      case 'green':
        return AppColors.childGreen;
      case 'orange':
        return AppColors.childOrange;
      case 'pink':
        return AppColors.childPink;
      case 'blue':
      default:
        return AppColors.childBlue;
    }
  }
}
