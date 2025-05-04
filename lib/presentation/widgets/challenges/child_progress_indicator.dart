// lib/presentation/widgets/challenges/child_progress_indicator.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/challenge_execution.dart';
import 'package:kidsdo/presentation/widgets/child/age_adapted_container.dart';

class ChildProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final int childAge;
  final Map<String, dynamic> settings;
  final Color color;
  final String label;
  final double height;
  final ChallengeExecution?
      execution; // Optional execution for detailed progress
  final bool isContinuous; // Whether this is a continuous challenge

  const ChildProgressIndicator({
    Key? key,
    required this.progress,
    required this.childAge,
    required this.settings,
    required this.color,
    required this.label,
    this.height = 20,
    this.execution,
    this.isContinuous = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AgeAdaptedContainer(
      childAge: childAge,
      settings: settings,
      padding: EdgeInsets.zero,
      defaultWidget: _buildDefaultProgressBar(),
      youngChildWidget: _buildYoungChildProgressBar(),
    );
  }

  Widget _buildDefaultProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress label with optional execution indicator
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.fontSm,
                color: color,
              ),
            ),

            // If this is showing a continuous challenge execution
            if (isContinuous && execution != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 50),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusSm),
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
                        TrKeys.currentPeriod.tr,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.xs),

        // Progress bar
        Stack(
          children: [
            // Background
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 100),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),

            // Progress - Use ClipRRect and FractionallySizedBox for safe calculation
            ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: SizedBox(
                width: double.infinity,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0),
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 100),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Percentage
            Center(
              child: SizedBox(
                height: height,
                child: Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: progress > 0.5 ? Colors.white : Colors.black,
                      fontSize: AppDimensions.fontXs,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // If we have execution information, show time progress
        if (execution != null && childAge > 6)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: _buildTimeProgress(execution!),
          ),
      ],
    );
  }

  Widget _buildYoungChildProgressBar() {
    // More visual and engaging version for young children
    final int progressPercent = (progress * 100).toInt();
    const int starsTotal = 5;
    final int starsFilled = (progress * starsTotal).round();

    return Column(
      children: [
        // Large label
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppDimensions.fontMd,
                color: color,
              ),
            ),

            // Small continuous indicator for kids
            if (isContinuous)
              const Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Icon(
                  Icons.refresh,
                  size: 18,
                  color: Colors.purple,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),

        // Progress stars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(starsTotal, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(
                index < starsFilled ? Icons.star : Icons.star_border,
                color: color,
                size: 32,
              ),
            );
          }),
        ),

        const SizedBox(height: AppDimensions.sm),

        // Decorative bar with animation
        Stack(
          children: [
            // Background
            Container(
              height: height * 1.5, // Larger
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 100),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusLg),
                border: Border.all(color: Colors.grey.withValues(alpha: 150)),
              ),
            ),

            // Progress
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: height * 1.5,
              width: double.infinity * progress,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusLg),
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 150), color],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 100),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),

            // Add decorative icons along the bar for kids
            if (progress > 0)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: height,
                    ),

                    // Show refresh icon for continuous challenges
                    if (isContinuous)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(
                          Icons.refresh,
                          color: Colors.purple,
                          size: height,
                        ),
                      ),
                  ],
                ),
              ),

            // Large percentage
            Center(
              child: SizedBox(
                height: height * 1.5,
                child: Center(
                  child: Text(
                    '$progressPercent%',
                    style: TextStyle(
                      color: progress > 0.4 ? Colors.white : Colors.black,
                      fontSize: AppDimensions.fontMd,
                      fontWeight: FontWeight.bold,
                      shadows: progress > 0.4
                          ? [
                              const Shadow(
                                color: Colors.black45,
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Simple time information for young kids
        if (execution != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildSimpleTimeInfo(execution!),
          ),
      ],
    );
  }

  // New widget to show time progress for older kids
  Widget _buildTimeProgress(ChallengeExecution execution) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(execution.startDate.year,
        execution.startDate.month, execution.startDate.day);
    final endDay = DateTime(
        execution.endDate.year, execution.endDate.month, execution.endDate.day);

    // Calculate total duration and elapsed duration
    final totalDuration = endDay.difference(startDay).inDays +
        1; // +1 to include both start and end days
    final elapsedDuration = today.difference(startDay).inDays + 1;
    final remainingDuration = endDay.difference(today).inDays;

    // Calculate time progress
    final timeProgress = elapsedDuration / totalDuration;

    // Text based on time left
    String timeText;
    Color timeColor;

    if (remainingDuration < 0) {
      // Past due
      timeText = TrKeys.timeExpired.tr;
      timeColor = Colors.red;
    } else if (remainingDuration == 0) {
      // Last day
      timeText = TrKeys.lastDay.tr;
      timeColor = Colors.red;
    } else if (remainingDuration == 1) {
      // One day left
      timeText = TrKeys.oneDayLeft.tr;
      timeColor = Colors.orange;
    } else if (remainingDuration <= 3) {
      // Few days left
      timeText = '$remainingDuration ${TrKeys.daysLeft.tr}';
      timeColor = Colors.orange;
    } else {
      // Plenty of time
      timeText = '$remainingDuration ${TrKeys.daysLeft.tr}';
      timeColor = Colors.green;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Time progress text
        Text(
          '${TrKeys.day.tr} $elapsedDuration/$totalDuration',
          style: TextStyle(
            fontSize: AppDimensions.fontXs,
            color: color,
          ),
        ),

        // Days remaining indicator
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: timeColor.withValues(alpha: 50),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                size: 10,
                color: timeColor,
              ),
              const SizedBox(width: 2),
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 10,
                  color: timeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Simple time info for young kids
  Widget _buildSimpleTimeInfo(ChallengeExecution execution) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDay = DateTime(
        execution.endDate.year, execution.endDate.month, execution.endDate.day);

    final daysLeft = endDay.difference(today).inDays;

    // Simple icons based on time left
    Widget timeWidget;

    if (daysLeft < 0) {
      // Past due
      timeWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.alarm_off,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            TrKeys.timeIsUp.tr,
            style: const TextStyle(
              fontSize: AppDimensions.fontMd,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      );
    } else if (daysLeft <= 1) {
      // Almost out of time
      timeWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            TrKeys.hurryUp.tr,
            style: const TextStyle(
              fontSize: AppDimensions.fontMd,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      );
    } else if (daysLeft <= 3) {
      // Getting close
      timeWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.hourglass_bottom,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            TrKeys.littleTimeLeft.tr,
            style: const TextStyle(
              fontSize: AppDimensions.fontMd,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      );
    } else {
      // Plenty of time
      timeWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            TrKeys.plentyOfTime.tr,
            style: const TextStyle(
              fontSize: AppDimensions.fontMd,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      );
    }

    return timeWidget;
  }
}
