// lib/presentation/pages/rewards/predefined_rewards_library_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/data/predefined_rewards.dart'; // Para PredefinedRewardCategory
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/reward.dart';
import 'package:kidsdo/presentation/controllers/rewards_controller.dart';
import 'package:kidsdo/presentation/pages/rewards/create_edit_reward_page.dart'; // Para la navegación
import 'package:kidsdo/presentation/widgets/common/empty_state_widget.dart';
import 'package:kidsdo/presentation/widgets/rewards/reward_card.dart'; // Reutilizamos RewardCard con adaptaciones
import 'package:kidsdo/routes.dart'; // Para la navegación si se usa por nombre

class PredefinedRewardsLibraryPage extends StatefulWidget {
  const PredefinedRewardsLibraryPage({super.key});

  @override
  State<PredefinedRewardsLibraryPage> createState() =>
      _PredefinedRewardsLibraryPageState();
}

class _PredefinedRewardsLibraryPageState
    extends State<PredefinedRewardsLibraryPage> {
  final RewardsController controller = Get.find<RewardsController>();
  final Rx<PredefinedRewardCategory?> _selectedCategory =
      Rx<PredefinedRewardCategory?>(null);

  @override
  void initState() {
    super.initState();
    // Cargar las recompensas predefinidas al entrar en la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPredefinedRewards();
    });
  }

  Widget _buildCategoryFilterChip(
      PredefinedRewardCategory? category, BuildContext context) {
    final bool isSelected = _selectedCategory.value == category;
    final String label = category == null
        ? Tr.t(TrKeys.allCategories) // "Todas"
        : Tr.t(
            'reward_category_${category.name}'); // Necesitarás claves como reward_category_treats

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xs / 2),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          _selectedCategory.value = selected ? category : null;
          controller.fetchPredefinedRewards(
              category: _selectedCategory.value?.name);
        },
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).chipTheme.backgroundColor,
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        checkmarkColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).chipTheme.labelStyle?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Tr.t(TrKeys.predefinedRewardsTitle)),
      ),
      body: Column(
        children: [
          // Filtro de Categorías
          SizedBox(
            height: 60, // Altura fija para la fila de chips
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm, vertical: AppDimensions.xs),
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryFilterChip(null, context), // Chip para "Todas"
                ...PredefinedRewardCategory.values.map(
                    (category) => _buildCategoryFilterChip(category, context)),
              ],
            ),
          ),
          const Divider(height: 1),

          // Lista de Recompensas Predefinidas
          Expanded(
            child: Obx(() {
              if (controller.predefinedRewardsStatus.value ==
                  RewardOperationStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.predefinedRewardsStatus.value ==
                  RewardOperationStatus.error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(controller.predefinedRewardsError.value,
                            textAlign: TextAlign.center),
                        const SizedBox(height: AppDimensions.md),
                        ElevatedButton(
                          onPressed: () => controller.fetchPredefinedRewards(
                              category: _selectedCategory.value?.name),
                          child: Text(Tr.t(TrKeys.retry)),
                        )
                      ],
                    ),
                  ),
                );
              }
              if (controller.predefinedRewards.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.search_off_rounded,
                  title: Tr.t(TrKeys
                      .noPredefinedRewardsFound), // "No se encontraron recompensas"
                  message: Tr.t(TrKeys
                      .tryDifferentFiltersPredefined), // "Intenta con otros filtros o contacta soporte."
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.md),
                itemCount: controller.predefinedRewards.length,
                itemBuilder: (context, index) {
                  final predefinedReward = controller.predefinedRewards[index];
                  // Usamos RewardCard, pero sin opciones de editar/borrar, y con acción de "usar plantilla"
                  return RewardCard(
                    reward:
                        predefinedReward, // La entidad Reward ya tiene el nombre traducido
                    onTap: () {
                      // Navegar a CreateEditRewardPage con esta recompensa como plantilla
                      // El ID de la plantilla no se usa para crear la nueva recompensa familiar
                      Get.to(
                        () => CreateEditRewardPage(
                          isEditing: false,
                          rewardAsTemplate: predefinedReward,
                        ),
                      );
                    },
                    // No pasamos onEdit ni onDelete para las predefinidas en esta vista
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
