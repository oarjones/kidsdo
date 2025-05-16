// lib/presentation/pages/rewards/rewards_management_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/reward.dart';
import 'package:kidsdo/presentation/controllers/auth_controller.dart';
import 'package:kidsdo/presentation/controllers/rewards_controller.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/presentation/widgets/common/empty_state_widget.dart';
import 'package:kidsdo/presentation/widgets/rewards/reward_card.dart';
import 'package:kidsdo/routes.dart';

class RewardsManagementPage extends StatelessWidget {
  const RewardsManagementPage({super.key});

  void _showDeleteConfirmationDialog(BuildContext context, Reward reward) {
    final controller = Get.find<RewardsController>();
    Get.dialog(
      AlertDialog(
        title: Text(Tr.t(TrKeys.confirmDeleteRewardTitle)),
        content: Text(Tr.tp(
            TrKeys.confirmDeleteRewardMessage, {'rewardName': reward.name})),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(Tr.t(TrKeys.cancel),
                style: const TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Cerrar diálogo
              controller.deleteReward(reward.id);
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(Tr.t(TrKeys.delete),
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final RewardsController controller = Get.find<RewardsController>();

    const appBarTitleStyle = TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: AppDimensions.fontLg,
      color: AppColors.textDark,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(Tr.t(TrKeys.rewardsTitle),
            style: appBarTitleStyle), // Título específico
        backgroundColor: AppColors.background,
        elevation: AppDimensions.elevationXs,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actionsIconTheme: const IconThemeData(color: AppColors.textMedium),
        actions: [
          // IconButton para Recompensas Predefinidas se mueve al PopupMenuButton
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'predefined_rewards') {
                Get.toNamed(Routes.predefinedRewardsLibrary);
                // Get.toNamed(Routes.predefinedRewards); // Asegúrate de tener esta ruta
                Get.snackbar(
                  TrKeys.predefinedRewardsTitle, // O un título más específico
                  Tr.t(TrKeys.predefinedRewardsTitle), // Mensaje temporal
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'predefined_rewards',
                child: ListTile(
                  leading: const Icon(Icons.explore_outlined,
                      color: AppColors.primary),
                  title: Text(Tr.t(TrKeys.predefinedRewardsTitle),
                      style: const TextStyle(fontFamily: 'Poppins')),
                ),
              ),
              // Aquí podrías añadir más opciones en el futuro
            ],
            icon: const Icon(Icons.more_vert), // Icono estándar de tres puntos
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final result = await Get.dialog<bool>(
                AlertDialog(
                  title: Text(Tr.t(TrKeys.logout)),
                  content: Text(Tr.t(TrKeys.logoutConfirmation)),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(Tr.t(TrKeys.cancel),
                          style: const TextStyle(color: AppColors.primary)),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: Text(Tr.t(TrKeys.logout),
                          style: const TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (result == true) {
                authController.logout();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.rewardsListStatus.value ==
                  RewardOperationStatus.loading &&
              controller.rewardsList.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (controller.rewardsListStatus.value ==
                  RewardOperationStatus.error &&
              controller.rewardsList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.rewardsListError.value.isNotEmpty
                          ? controller.rewardsListError.value
                          : Tr.t(TrKeys.error), // Mensaje de error genérico
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.error,
                          fontSize: AppDimensions.fontMd),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(Tr.t(TrKeys.retry)),
                      onPressed: () {
                        final sessionController = Get.find<SessionController>();
                        final familyId =
                            sessionController.currentUser.value?.familyId;
                        if (familyId != null) {
                          controller.fetchRewards(familyId);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            );
          }
          if (controller.rewardsList.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.emoji_events_outlined,
              title: Tr.t(TrKeys.noRewardsAvailable),
              message: Tr.t(TrKeys.addFirstReward),
              onRetry: () => Get.toNamed(Routes
                  .createReward), // Acción para crear la primera recompensa
              retryButtonText: Tr.t(TrKeys.createRewardTitle),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              final sessionController = Get.find<SessionController>();
              final familyId = sessionController.currentUser.value?.familyId;
              if (familyId != null) {
                controller.fetchRewards(familyId);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  AppDimensions.md,
                  AppDimensions.md,
                  AppDimensions.md,
                  AppDimensions.xxl + AppDimensions.md), // Espacio para el FAB
              itemCount: controller.rewardsList.length,
              itemBuilder: (context, index) {
                final reward = controller.rewardsList[index];
                return RewardCard(
                  reward: reward,
                  onEdit: () {
                    Get.toNamed(Routes.editReward, arguments: reward);
                  },
                  onDelete: () =>
                      _showDeleteConfirmationDialog(context, reward),
                );
              },
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(Routes.createReward);
        },
        icon: const Icon(Icons.add),
        label: Text(Tr.t(TrKeys.createRewardTitle),
            style: const TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: AppDimensions.elevationSm,
      ),
    );
  }
}
