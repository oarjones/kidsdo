// lib/presentation/pages/child_access/child_challenges_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/domain/entities/challenge.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart';
import 'package:kidsdo/presentation/controllers/child_challenges_controller.dart';
import 'package:kidsdo/presentation/widgets/challenges/celebration_animation.dart';
import 'package:kidsdo/presentation/widgets/challenges/child_challenge_card.dart';
import 'package:kidsdo/presentation/widgets/challenges/child_progress_indicator.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';
import 'package:kidsdo/routes.dart';

class ChildChallengesPage extends StatefulWidget {
  const ChildChallengesPage({Key? key}) : super(key: key);

  @override
  State<ChildChallengesPage> createState() => _ChildChallengesPageState();
}

class _ChildChallengesPageState extends State<ChildChallengesPage>
    with SingleTickerProviderStateMixin {
  // Controllers
  late ChildChallengesController controller;
  late ChildAccessController accessController;

  // Animations
  late TabController _tabController;
  // Add "continuous" tab to the existing tabs
  final List<String> _tabs = [
    'all',
    'pending',
    'completed',
    'daily',
    'weekly',
    'continuous'
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    controller = Get.find<ChildChallengesController>();
    accessController = Get.find<ChildAccessController>();

    // Configure tabs
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.changeFilter(_tabs[_tabController.index]);
      }
    });

    // Load challenges if not loaded yet
    if (controller.assignedChallenges.isEmpty) {
      controller.loadChildChallenges();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Verify there's an active profile
      final FamilyChild? activeChild =
          accessController.activeChildProfile.value;
      if (activeChild == null) {
        // If no active profile, redirect to profile selection
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed(Routes.childProfileSelection);
        });
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Get child's theme color
      final Color themeColor = _getThemeColor(activeChild.settings);

      return Scaffold(
        appBar: _buildAppBar(activeChild, themeColor),
        // Use SafeArea to avoid system obstructions
        body: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Tab bar
                  Container(
                    color: themeColor.withValues(alpha: 20),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: themeColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: themeColor,
                      tabs: [
                        Tab(text: TrKeys.all.tr),
                        Tab(text: TrKeys.pending.tr),
                        Tab(text: TrKeys.completed.tr),
                        Tab(text: TrKeys.dailyChallenge.tr),
                        Tab(text: TrKeys.weeklyChallenge.tr),
                        // New tab for continuous challenges
                        Tab(text: TrKeys.continuousChallenge.tr),
                      ],
                      isScrollable: true,
                    ),
                  ),

                  // Summary and progress
                  _buildProgressSection(activeChild, themeColor),

                  // Challenges list
                  Expanded(
                    child: _buildChallengesList(activeChild),
                  ),
                ],
              ),

              // Loading indicator
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withValues(alpha: 50),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Celebration animation
              if (controller.showCelebration.value &&
                  controller.completedChallenge.value != null)
                CelebrationAnimation(
                  points: controller.pointsEarned.value,
                  message: TrKeys.challengeCompleted.tr,
                  onClose: () => controller.showCelebration.value = false,
                ),
            ],
          ),
        ),
        // Use BottomNavigationBar for consistent navigation in child interface
        bottomNavigationBar: _buildBottomNav(themeColor, activeChild.age),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(FamilyChild child, Color themeColor) {
    return AppBar(
      backgroundColor: themeColor,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Avatar with Hero
          Hero(
            tag: 'child_avatar_${child.id}',
            child: child.avatarUrl != null
                ? CachedAvatar(
                    url: child.avatarUrl,
                    radius: 18,
                  )
                : CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: const Icon(
                      Icons.child_care,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: AppDimensions.sm),

          // Name
          Text(
            child.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // Button to go back to dashboard
        IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => Get.offNamed(Routes.childDashboard),
          tooltip: TrKeys.menuHome.tr,
        ),
      ],
    );
  }

  Widget _buildProgressSection(FamilyChild child, Color themeColor) {
    final double progress = controller.getProgressPercentage();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      color: themeColor.withValues(alpha: 5),
      child: Column(
        children: [
          // Statistics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Total challenges
              _buildStatCard(
                icon: Icons.assignment,
                count: controller.assignedChallenges.length,
                label: TrKeys.totalChallenges.tr,
                color: themeColor,
              ),

              // Completed challenges
              _buildStatCard(
                icon: Icons.check_circle,
                count: controller.getCompletedChallengesCount(),
                label: TrKeys.completed.tr,
                color: Colors.green,
              ),

              // Points earned
              _buildStatCard(
                icon: Icons.star,
                count: controller.getTotalPointsEarned(),
                label: TrKeys.points.tr,
                color: Colors.amber,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.lg),

          // Progress indicator
          ChildProgressIndicator(
            progress: progress,
            childAge: child.age,
            settings: child.settings,
            color: themeColor,
            label: TrKeys.yourProgress.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.sm,
        horizontal: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontMd,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppDimensions.fontXs,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesList(FamilyChild child) {
    // Determine which list of challenges to show based on selected filter
    RxList<AssignedChallenge> currentList;
    switch (_tabs[_tabController.index]) {
      case 'pending':
        currentList = controller.pendingChallenges;
        break;
      case 'completed':
        currentList = controller.completedChallenges;
        break;
      case 'daily':
        currentList = controller.dailyChallenges;
        break;
      case 'weekly':
        currentList = controller.weeklyChallenges;
        break;
      case 'continuous':
        // New case for continuous challenges
        currentList = controller.continuousChallenges;
        break;
      case 'all':
      default:
        currentList = controller.assignedChallenges;
        break;
    }

    return Obx(() {
      if (controller.status.value == ChildChallengeStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: AppDimensions.md),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: AppDimensions.md),
              ElevatedButton(
                onPressed: controller.loadChildChallenges,
                child: Text(TrKeys.retry.tr),
              ),
            ],
          ),
        );
      }

      if (currentList.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.loadChildChallenges,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.md),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            final assignedChallenge = currentList[index];

            // Find corresponding challenge
            final challenge = controller.challenges
                .firstWhereOrNull((c) => c.id == assignedChallenge.challengeId);

            if (challenge == null) {
              return const SizedBox.shrink();
            }

            // Get the current execution if it exists
            final currentExecution = assignedChallenge.currentExecution;

            return ChildChallengeCard(
              assignedChallenge: assignedChallenge,
              challenge: challenge,
              childAge: child.age,
              settings: child.settings,
              isCompleted:
                  assignedChallenge.status == AssignedChallengeStatus.completed,
              isPending:
                  assignedChallenge.status == AssignedChallengeStatus.pending,
              isContinuous: assignedChallenge.isContinuous,
              currentExecution: currentExecution,
              onTap: () =>
                  _showChallengeDetails(assignedChallenge, challenge, child),
              onComplete: assignedChallenge.status ==
                      AssignedChallengeStatus.active
                  ? () =>
                      controller.markChallengeAsCompleted(assignedChallenge.id)
                  : null,
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    final FamilyChild? child = accessController.activeChildProfile.value;
    if (child == null) return const SizedBox.shrink();

    final Color themeColor = _getThemeColor(child.settings);

    // More kid-friendly message for continuous challenges tab
    String emptyMessage = _tabs[_tabController.index] == 'continuous'
        ? TrKeys.noContinuousChallengesYet.tr
        : _tabs[_tabController.index] == 'completed'
            ? TrKeys.noCompletedChallengesYet.tr
            : TrKeys.noChallengesMatchFilter.tr;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _tabs[_tabController.index] == 'continuous'
                ? Icons.update
                : Icons.assignment_outlined,
            size: 64,
            color: Colors.grey.withValues(alpha: 150),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            TrKeys.noChallengesFound.tr,
            style: TextStyle(
              fontSize: AppDimensions.fontLg,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
            child: Text(
              emptyMessage,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          if (_tabs[_tabController.index] != 'all')
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(0); // Go to "All" tab
              },
              icon: const Icon(Icons.filter_list_off),
              label: Text(TrKeys.showAllChallenges.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  void _showChallengeDetails(AssignedChallenge assignedChallenge,
      Challenge challenge, FamilyChild child) {
    final Color themeColor = _getThemeColor(child.settings);
    // Get current execution if available
    final currentExecution = assignedChallenge.currentExecution;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.borderRadiusLg)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppDimensions.lg),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSm),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Icon and category
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 50),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                  ),
                  child: Icon(
                    _getChallengeIcon(challenge.category),
                    color: themeColor,
                    size: 40,
                  ),
                ),

                const SizedBox(width: AppDimensions.md),

                // Title and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontLg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Row(
                        children: [
                          // Category tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 50),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusSm),
                            ),
                            child: Text(
                              _getCategoryName(challenge.category),
                              style: TextStyle(
                                fontSize: 12,
                                color: themeColor,
                              ),
                            ),
                          ),

                          // Add continuous challenge indicator if applicable
                          if (assignedChallenge.isContinuous)
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 50),
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.borderRadiusSm),
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
                                      TrKeys.neverEnds.tr,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status (icon)
                _buildStatusIcon(
                    currentExecution?.status ?? assignedChallenge.status,
                    size: 32),
              ],
            ),

            const SizedBox(height: AppDimensions.lg),

            // Description
            Text(
              challenge.description,
              style: const TextStyle(
                fontSize: AppDimensions.fontMd,
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            // Additional information
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 20),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMd),
              ),
              child: Column(
                children: [
                  // Points
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TrKeys.points.tr,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            challenge.points.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(),

                  // Frequency
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TrKeys.frequency.tr,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        _getFrequencyName(challenge.frequency),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  // Current period info (for younger kids)
                  if (currentExecution != null && child.age <= 6)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          TrKeys.currentPeriod.tr,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: themeColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateRangeSimple(
                                currentExecution.startDate,
                                currentExecution.endDate,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  // If continuous challenge and child is older, show more detailed info
                  if (assignedChallenge.isContinuous && child.age > 6) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          TrKeys.currentPeriod.tr,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          currentExecution != null
                              ? _formatDateRange(
                                  currentExecution.startDate,
                                  currentExecution.endDate,
                                )
                              : TrKeys.notStartedYet.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(),

                    // Add info about next period for continuous challenges
                    if (currentExecution != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            TrKeys.nextPeriodStarts.tr,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            _formatDate(currentExecution.endDate
                                .add(const Duration(days: 1))),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],

                  // For non-continuous challenges, just show dates
                  if (!assignedChallenge.isContinuous) ...[
                    // Dates
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          TrKeys.startDate.tr,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          _formatDate(assignedChallenge.startDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          TrKeys.endDate.tr,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          assignedChallenge.endDate != null
                              ? _formatDate(assignedChallenge.endDate!)
                              : TrKeys.neverEnds.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.xl),

            // Action buttons
            if (assignedChallenge.status == AssignedChallengeStatus.active)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.markChallengeAsCompleted(assignedChallenge.id);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: Text(TrKeys.markAsCompleted.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppDimensions.md),
                  ),
                ),
              )
            else if (assignedChallenge.status ==
                AssignedChallengeStatus.pending)
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 50),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        TrKeys.waitingForParentApproval.tr,
                        style: const TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (assignedChallenge.status ==
                AssignedChallengeStatus.completed)
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 50),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: AppDimensions.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TrKeys.challengeCompleted.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (assignedChallenge.evaluations.isNotEmpty)
                          Text(
                            '${TrKeys.pointsEarned.tr}: ${assignedChallenge.evaluations.last.points}',
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

            // For continuous challenges, show reminder about auto-renewal
            if (assignedChallenge.isContinuous &&
                (assignedChallenge.status ==
                        AssignedChallengeStatus.completed ||
                    assignedChallenge.status ==
                        AssignedChallengeStatus.pending)) ...[
              const SizedBox(height: AppDimensions.md),
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 30),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.update, color: Colors.purple),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        child.age <= 6
                            ? TrKeys.continuousChallengeInfoSimple.tr
                            : TrKeys.continuousChallengeInfo.tr,
                        style: const TextStyle(
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(Color themeColor, int childAge) {
    // Determine sizes based on age to improve usability
    double normalIconSize = childAge <= 5 ? 32.0 : 28.0;
    double activeIconSize = childAge <= 5 ? 36.0 : 30.0;
    double labelSize =
        childAge <= 5 ? AppDimensions.fontSm : AppDimensions.fontXs;

    return BottomNavigationBar(
      currentIndex: 1, // On challenges
      onTap: (index) {
        if (index == 0) {
          // Go to home
          Get.offNamed(Routes.childDashboard);
        } else if (index == 1) {
          // We're already on challenges
        } else {
          // For other options, show message
          Get.snackbar(
            TrKeys.comingSoon.tr,
            TrKeys.comingSoonMessage.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      selectedItemColor: themeColor,
      unselectedItemColor: AppColors.navigationUnselected,
      backgroundColor: Colors.white,
      elevation: 16,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: labelSize,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: labelSize,
      ),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: normalIconSize),
          activeIcon: Icon(Icons.home, size: activeIconSize),
          label: TrKeys.menuHome.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment, size: normalIconSize),
          activeIcon: Icon(Icons.assignment, size: activeIconSize),
          label: TrKeys.menuChallenges.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard, size: normalIconSize),
          activeIcon: Icon(Icons.card_giftcard, size: activeIconSize),
          label: TrKeys.menuAwards.tr,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events, size: normalIconSize),
          activeIcon: Icon(Icons.emoji_events, size: activeIconSize),
          label: TrKeys.menuAchievements.tr,
        ),
      ],
    );
  }

  Widget _buildStatusIcon(AssignedChallengeStatus status, {double size = 24}) {
    switch (status) {
      case AssignedChallengeStatus.completed:
        return Container(
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 50),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: size,
          ),
        );
      case AssignedChallengeStatus.failed:
        return Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 50),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.cancel,
            color: Colors.red,
            size: size,
          ),
        );
      case AssignedChallengeStatus.pending:
        return Container(
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 50),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.pending,
            color: Colors.orange,
            size: size,
          ),
        );
      case AssignedChallengeStatus.active:
        return Container(
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 50),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.pending,
            color: Colors.green,
            size: size,
          ),
        );
      case AssignedChallengeStatus.inactive:
        return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 98, 102, 98).withValues(alpha: 50),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.pending,
            color: const Color.fromARGB(255, 98, 102, 98).withValues(alpha: 50),
            size: size,
          ),
        );
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return TrKeys.today.tr;
    } else if (dateToCheck == today.add(const Duration(days: 1))) {
      return TrKeys.tomorrow.tr;
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return TrKeys.yesterday.tr;
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // New helper for formatting date ranges in a simple way for younger kids
  String _formatDateRangeSimple(DateTime start, DateTime end) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    // Calculate days remaining
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

  // New helper for formatting date ranges for older kids
  String _formatDateRange(DateTime start, DateTime end) {
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }
}
