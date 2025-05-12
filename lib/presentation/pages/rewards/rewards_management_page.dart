import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/reward.dart';
import 'package:kidsdo/presentation/controllers/rewards_controller.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/presentation/widgets/common/empty_state_widget.dart'; // Asumiendo que tienes un widget así
import 'package:kidsdo/presentation/widgets/rewards/reward_card.dart';
import 'package:kidsdo/routes.dart'; // Para la navegación

class RewardsManagementPage extends GetView<RewardsController> {
  const RewardsManagementPage({super.key});

  void _showDeleteConfirmationDialog(BuildContext context, Reward reward) {
    Get.dialog(
      AlertDialog(
        title: Text(Tr.t(TrKeys.confirmDeleteRewardTitle)),
        content: Text(Tr.tp(
            TrKeys.confirmDeleteRewardMessage, {'rewardName': reward.name})),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(Tr.t(TrKeys.cancel)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Cerrar diálogo
              controller.deleteReward(reward.id);
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(Tr.t(TrKeys.delete)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar el controlador si aún no está (aunque GetView debería manejarlo si está bien registrado)
    // Get.put(RewardsController(rewardRepository: Get.find(), familyChildRepository: Get.find(), sessionController: Get.find(), logger: Get.find()));
    // Es mejor asegurarse que esté registrado en el `injection_container.dart` y usar `Get.find()` o `GetView`.

    return Scaffold(
      appBar: AppBar(
        title: Text(Tr.t(TrKeys.manageRewards)),
        // Podrías añadir un botón para ir a la librería de recompensas predefinidas
        actions: [
          IconButton(
            icon: const Icon(Icons.library_add_check_outlined),
            tooltip:
                Tr.t(TrKeys.predefinedRewardsTitle), // Necesitarás esta key
            onPressed: () {
              Get.toNamed(
                  Routes.predefinedRewardsLibrary); // Necesitarás esta ruta
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.rewardsListStatus.value ==
                RewardOperationStatus.loading &&
            controller.rewardsList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.rewardsListStatus.value == RewardOperationStatus.error &&
            controller.rewardsList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.rewardsListError.value,
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppDimensions.md),
                  ElevatedButton(
                    onPressed: () {
                      final sessionController = Get.find<SessionController>();
                      final familyId = sessionController
                          .currentUser.value?.familyId; // Corregido
                      if (familyId != null) {
                        controller.fetchRewards(familyId);
                      }
                    },
                    child: Text(Tr.t(TrKeys.retry)), // Necesitarás esta key
                  )
                ],
              ),
            ),
          );
        }
        if (controller.rewardsList.isEmpty) {
          return EmptyStateWidget(
            // Reemplaza con tu widget de estado vacío
            icon: Icons.emoji_events_outlined,
            title: Tr.t(TrKeys.noRewardsAvailable),
            message: Tr.t(TrKeys.addFirstReward),
            onRetry: () =>
                Get.toNamed(Routes.createReward), // Necesitarás esta ruta
            retryButtonText: Tr.t(TrKeys.createRewardTitle),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final sessionController = Get.find<SessionController>();
            final familyId =
                sessionController.currentUser.value?.familyId; // Corregido
            if (familyId != null) {
              controller.fetchRewards(familyId);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: controller.rewardsList.length,
            itemBuilder: (context, index) {
              final reward = controller.rewardsList[index];
              return RewardCard(
                reward: reward,
                onEdit: () {
                  // Guardar la recompensa seleccionada en el controlador antes de navegar
                  // controller.selectRewardForEditing(reward); // Necesitarás este método en RewardsController
                  Get.toNamed(Routes.editReward,
                      arguments:
                          reward); // Pasamos la recompensa como argumento
                },
                onDelete: () => _showDeleteConfirmationDialog(context, reward),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // controller.selectRewardForEditing(null); // Limpiar selección para nueva recompensa
          Get.toNamed(Routes.createReward);
        },
        icon: const Icon(Icons.add),
        label: Text(Tr.t(TrKeys.createRewardTitle)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
