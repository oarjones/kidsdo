import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/assigned_challenge.dart';
import 'package:kidsdo/presentation/controllers/challenge_controller.dart';
import 'package:kidsdo/routes.dart';

class ChallengesPage extends GetView<ChallengeController> {
  const ChallengesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.challenges.tr),
        centerTitle: true,
      ),
      // Añadido SafeArea aquí
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            // ... (resto del Column sin cambios)
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de título con animación
              Text(
                TrKeys.challenges.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                TrKeys.challengesPageSubtitle.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Botones grandes
              _buildFeatureCard(
                title: TrKeys.activeChallenges.tr,
                description: TrKeys.challengesAsignedVisualEval.tr,
                icon: Icons.assignment,
                color: AppColors.primary,
                onTap: () => Get.toNamed(Routes.activeChallenges),
              ),

              const SizedBox(height: AppDimensions.lg),

              _buildFeatureCard(
                title: TrKeys.challengeLibrary.tr,
                description: TrKeys.exploreChallengeLibrary.tr,
                icon: Icons.menu_book,
                color: AppColors.secondary,
                onTap: () => Get.toNamed(Routes.challengeLibrary),
              ),

              const SizedBox(height: AppDimensions.lg),

              _buildFeatureCard(
                title: TrKeys.createChallenge.tr,
                description: TrKeys.createCustomChallenges.tr,
                icon: Icons.add_circle_outline,
                color: Colors.green,
                onTap: () => Get.toNamed(Routes.createChallenge),
              ),

              const Spacer(),

              // Estadísticas
              Obx(() => Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 20),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatistic(
                          label: TrKeys.activeChallengesLabel.tr,
                          value: controller.assignedChallenges
                              .where((c) =>
                                  c.status == AssignedChallengeStatus.active)
                              .length
                              .toString(),
                          icon: Icons.hourglass_top,
                          color: Colors.blue,
                        ),
                        _buildStatistic(
                          label: TrKeys.completedChallengesStat.tr,
                          value: controller.assignedChallenges
                              .where((c) =>
                                  c.status == AssignedChallengeStatus.completed)
                              .length
                              .toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        _buildStatistic(
                          label: TrKeys.libraryChallengesStat.tr,
                          value: controller.familyChallenges.length.toString(),
                          icon: Icons.menu_book,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(TrKeys.challenges.tr),
  //       centerTitle: true,
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(AppDimensions.lg),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Sección de título con animación
  //           Text(
  //             TrKeys.challenges.tr,
  //             style: const TextStyle(
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const SizedBox(height: AppDimensions.md),
  //           Text(
  //             TrKeys.challengesPageSubtitle.tr,
  //             style: TextStyle(
  //               fontSize: 16,
  //               color: Colors.grey.shade600,
  //             ),
  //           ),
  //           const SizedBox(height: AppDimensions.xl),

  //           // Botones grandes
  //           _buildFeatureCard(
  //             title: TrKeys.activeChallenges.tr,
  //             description: TrKeys.challengesAsignedVisualEval.tr,
  //             icon: Icons.assignment,
  //             color: AppColors.primary,
  //             onTap: () => Get.toNamed(Routes.activeChallenges),
  //           ),

  //           const SizedBox(height: AppDimensions.lg),

  //           _buildFeatureCard(
  //             title: TrKeys.challengeLibrary.tr,
  //             description: TrKeys.exploreChallengeLibrary.tr,
  //             icon: Icons.menu_book,
  //             color: AppColors.secondary,
  //             onTap: () => Get.toNamed(Routes.challengeLibrary),
  //           ),

  //           const SizedBox(height: AppDimensions.lg),

  //           _buildFeatureCard(
  //             title: TrKeys.createChallenge.tr,
  //             description: TrKeys.createCustomChallenges.tr,
  //             icon: Icons.add_circle_outline,
  //             color: Colors.green,
  //             onTap: () => Get.toNamed(Routes.createChallenge),
  //           ),

  //           const Spacer(),

  //           // Estadísticas
  //           Obx(() => Container(
  //                 padding: const EdgeInsets.all(AppDimensions.md),
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.withValues(alpha: 20),
  //                   borderRadius:
  //                       BorderRadius.circular(AppDimensions.borderRadiusMd),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     _buildStatistic(
  //                       label: TrKeys.activeChallengesLabel.tr,
  //                       value: controller.assignedChallenges
  //                           .where((c) =>
  //                               c.status == AssignedChallengeStatus.active)
  //                           .length
  //                           .toString(),
  //                       icon: Icons.hourglass_top,
  //                       color: Colors.blue,
  //                     ),
  //                     _buildStatistic(
  //                       label: TrKeys.completedChallengesStat.tr,
  //                       value: controller.assignedChallenges
  //                           .where((c) =>
  //                               c.status == AssignedChallengeStatus.completed)
  //                           .length
  //                           .toString(),
  //                       icon: Icons.check_circle,
  //                       color: Colors.green,
  //                     ),
  //                     _buildStatistic(
  //                       label: TrKeys.libraryChallengesStat.tr,
  //                       value: controller.familyChallenges.length.toString(),
  //                       icon: Icons.menu_book,
  //                       color: AppColors.secondary,
  //                     ),
  //                   ],
  //                 ),
  //               )),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 30),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
          border: Border.all(color: color.withValues(alpha: 50)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 5),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: color,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistic({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
