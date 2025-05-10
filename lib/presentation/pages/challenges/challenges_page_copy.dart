// lib/presentation/pages/challenges/challenges_page.dart

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de título
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
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 94, 93, 93),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Retos Activos - fondo azul sólido
              _buildFeatureCard(
                title: TrKeys.activeChallenges.tr,
                description: TrKeys.challengesAsignedVisualEval.tr,
                icon: Icons.assignment,
                color: AppColors.primary,
                onTap: () => Get.toNamed(Routes.activeChallenges),
              ),

              const SizedBox(height: AppDimensions.lg),

              // Biblioteca de Retos - fondo turquesa sólido
              _buildFeatureCard(
                title: TrKeys.challengeLibrary.tr,
                description: TrKeys.exploreChallengeLibrary.tr,
                icon: Icons.menu_book,
                color: AppColors.secondary,
                onTap: () => Get.toNamed(Routes.challengeLibrary),
              ),

              const SizedBox(height: AppDimensions.lg),

              // Crear reto - fondo verde sólido
              _buildFeatureCard(
                title: TrKeys.createChallenge.tr,
                description: TrKeys.createCustomChallenges.tr,
                icon: Icons.add,
                color: AppColors.success,
                onTap: () => Get.toNamed(Routes.createChallenge),
              ),

              const Spacer(),

              // Sección de estadísticas
              _buildStatsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.lg,
            horizontal: AppDimensions.xl,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 40),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono con fondo semitransparente
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 80),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppDimensions.md),

              // Texto en blanco
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha de navegación
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 40),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMd),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.lg,
            horizontal: AppDimensions.md,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 15),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatistic(
                icon: Icons.hourglass_top,
                value: controller.assignedChallenges
                    .where((c) => c.status == AssignedChallengeStatus.active)
                    .length
                    .toString(),
                label: TrKeys.activeChallengesLabel.tr,
                color: AppColors.primary,
              ),
              _buildStatistic(
                icon: Icons.check_circle,
                value: controller.assignedChallenges
                    .where((c) => c.status == AssignedChallengeStatus.completed)
                    .length
                    .toString(),
                label: TrKeys.completedChallengesStat.tr,
                color: AppColors.success,
              ),
              _buildStatistic(
                icon: Icons.menu_book,
                value: controller.familyChallenges.length.toString(),
                label: TrKeys.libraryChallengesStat.tr,
                color: AppColors.secondary,
              ),
            ],
          ),
        ));
  }

  Widget _buildStatistic({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 30),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.withValues(alpha: 180),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
