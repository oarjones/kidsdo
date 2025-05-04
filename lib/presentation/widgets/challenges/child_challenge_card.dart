// lib/presentation/widgets/challenges/child_challenge_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';
import 'package:kidsdo/presentation/widgets/child/age_adapted_container.dart';

class ChildChallengeCard extends StatelessWidget {
  final AssignedChallenge assignedChallenge;
  final Challenge challenge;
  final int childAge;
  final Map<String, dynamic> settings;
  final bool isCompleted;
  final bool isPending;
  final bool isContinuous;
  final ChallengeExecution? currentExecution;
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
    this.isContinuous = false,
    this.currentExecution,
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
              // Title and status
              Row(
                children: [
                  // If continuous, show refresh icon
                  if (isContinuous)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.purple,
                      ),
                    ),

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
                  _buildStatusIcon(
                      currentExecution?.status ?? assignedChallenge.status,
                      themeColor),
                ],
              ),

              if (isContinuous && childAge > 6)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Text(
                        "${TrKeys.currentPeriod.tr}: ",
                        style: const TextStyle(
                          fontSize: AppDimensions.fontXs,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        _formatDateSimple(
                          currentExecution?.startDate,
                          currentExecution?.endDate,
                        ),
                        style: const TextStyle(
                          fontSize: AppDimensions.fontXs,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppDimensions.sm),

              // Description
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

              // Points and completion button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Points
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

                  // Show days left for current execution (if applicable)
                  if (currentExecution != null &&
                      !isCompleted &&
                      !isPending &&
                      childAge > 6)
                    _buildDaysLeftIndicator(
                        currentExecution?.endDate, themeColor),

                  // Complete button (only if not completed or pending)
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

                  // If pending, show indicator
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

              // For continuous challenges that are completed, show renewal info
              if (isContinuous && isCompleted && childAge > 6)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.update,
                        size: 14,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          TrKeys.willRenewSoon.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.purple,
                          ),
                        ),
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

  Widget _buildYoungChildCard(Color themeColor) {
    // More visual version for young children (3-6 years)
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
              // Large colorful icon
              Stack(
                children: [
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

                  // Continuous indicator for young kids (small refresh badge)
                  if (isContinuous)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.refresh,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: AppDimensions.lg),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large title
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

                    // Large points
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
                        _buildStatusIcon(
                            currentExecution?.status ??
                                assignedChallenge.status,
                            themeColor,
                            size: 32),
                      ],
                    ),

                    // Show simple timing information for young kids (only if active)
                    if (currentExecution != null && !isCompleted && !isPending)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildSimpleTimingForKids(
                            currentExecution?.endDate, themeColor),
                      ),

                    // For continuous challenges, show simple renewal info
                    if (isContinuous && isCompleted)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.refresh,
                              size: 20,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              TrKeys.comesBackSoon.tr,
                              style: const TextStyle(
                                fontSize: AppDimensions.fontMd,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildStatusIcon(AssignedChallengeStatus status, Color themeColor,
      {double size = 24}) {
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

  // New widget for showing days left
  Widget _buildDaysLeftIndicator(DateTime? endDate, Color themeColor) {
    // If endDate is null (continuous challenge without end date)
    if (endDate == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 30),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.refresh,
              size: 12,
              color: Colors.purple,
            ),
            const SizedBox(width: 2),
            Text(
              TrKeys.continuousChallenge.tr,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Normal implementation for challenges with end date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    final daysLeft = end.difference(today).inDays;

    Color statusColor;
    if (daysLeft <= 1) {
      statusColor = Colors.red;
    } else if (daysLeft <= 3) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 30),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 12,
            color: statusColor,
          ),
          const SizedBox(width: 2),
          Text(
            daysLeft <= 0
                ? TrKeys.lastDay.tr
                : daysLeft == 1
                    ? TrKeys.oneDayLeft.tr
                    : '$daysLeft ${TrKeys.daysLeft.tr}',
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // New widget for showing simple timing for young kids
  Widget _buildSimpleTimingForKids(DateTime? endDate, Color themeColor) {
    // If endDate is null (continuous challenge without end date)
    if (endDate == null) {
      return Row(
        children: [
          const Icon(
            Icons.refresh,
            size: 20,
            color: Colors.purple,
          ),
          const SizedBox(width: 6),
          Text(
            TrKeys.neverEnds.tr,
            style: const TextStyle(
              fontSize: AppDimensions.fontMd,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      );
    }

    // Normal implementation for challenges with end date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    final daysLeft = end.difference(today).inDays;

    // Use different emoji based on days left
    IconData icon;
    Color color;
    String message;

    if (daysLeft <= 1) {
      icon = Icons.timer;
      color = Colors.red;
      message = TrKeys.hurryUp.tr;
    } else if (daysLeft <= 3) {
      icon = Icons.hourglass_bottom;
      color = Colors.orange;
      message = TrKeys.fewDaysLeft.tr;
    } else {
      icon = Icons.calendar_today;
      color = Colors.green;
      message = TrKeys.plentyOfTime.tr;
    }

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          message,
          style: TextStyle(
            fontSize: AppDimensions.fontMd,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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

  // Helper method to format dates in a simple way
  String _formatDateSimple(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return TrKeys.notStartedYet.tr;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDay = DateTime(end.year, end.month, end.day);

    final daysRemaining = endDay.difference(today).inDays;

    if (daysRemaining < 0) {
      return TrKeys.finished.tr;
    } else if (daysRemaining == 0) {
      return TrKeys.lastDay.tr;
    } else if (daysRemaining == 1) {
      return TrKeys.oneDayLeft.tr;
    } else if (daysRemaining <= 7) {
      return '$daysRemaining ${TrKeys.daysLeft.tr}';
    } else {
      return TrKeys.manyDaysLeft.tr;
    }
  }
}
