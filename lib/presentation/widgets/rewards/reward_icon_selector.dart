// lib/presentation/widgets/rewards/reward_icon_selector.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart'; // Asegúrate que la ruta sea correcta
import 'package:kidsdo/core/constants/dimensions.dart'; // Asegúrate que la ruta sea correcta
import 'package:kidsdo/core/translations/app_translations.dart'; // Para títulos o tooltips

// Define una clase para representar cada opción de icono
class RewardIconOption {
  final String name; // Identificador único (ej: 'ice_cream', 'game_controller')
  final IconData
      iconData; // Icono de Material Design (o podrías usar String para path de asset)

  const RewardIconOption({required this.name, required this.iconData});
}

// Lista de iconos disponibles para recompensas (usa IconData como placeholder)
// Reemplaza esto con tus propios iconos/assets
final List<RewardIconOption> availableRewardIcons = [
  const RewardIconOption(name: 'star', iconData: Icons.star_rounded),
  const RewardIconOption(name: 'ice_cream', iconData: Icons.icecream_rounded),
  const RewardIconOption(name: 'cake', iconData: Icons.cake_rounded),
  const RewardIconOption(
      name: 'celebration', iconData: Icons.celebration_rounded),
  const RewardIconOption(
      name: 'sports_esports', iconData: Icons.sports_esports_rounded),
  const RewardIconOption(
      name: 'smart_display', iconData: Icons.smart_display_rounded),
  const RewardIconOption(name: 'movie', iconData: Icons.movie_creation_rounded),
  const RewardIconOption(
      name: 'theaters', iconData: Icons.theaters_rounded), // Cine
  const RewardIconOption(name: 'park', iconData: Icons.park_rounded), // Parque
  const RewardIconOption(
      name: 'savings', iconData: Icons.savings_rounded), // Hucha, ahorro
  const RewardIconOption(
      name: 'card_giftcard', iconData: Icons.card_giftcard_rounded),
  const RewardIconOption(name: 'book', iconData: Icons.book_rounded),
  const RewardIconOption(
      name: 'music_note', iconData: Icons.music_note_rounded),
  const RewardIconOption(
      name: 'sports_soccer', iconData: Icons.sports_soccer_rounded),
  const RewardIconOption(name: 'brush', iconData: Icons.brush_rounded), // Arte
  const RewardIconOption(name: 'pets', iconData: Icons.pets_rounded), // Mascota
  const RewardIconOption(name: 'toy', iconData: Icons.toys_rounded),
  const RewardIconOption(
      name: 'puzzle', iconData: Icons.extension_rounded), // Puzzle
  const RewardIconOption(
      name: 'rocket_launch', iconData: Icons.rocket_launch_rounded),
  const RewardIconOption(
      name: 'wallet', iconData: Icons.account_balance_wallet_rounded),
];

class RewardIconSelectorDialog extends StatelessWidget {
  final String currentlySelectedIconName;
  final Function(String) onSelectIcon;

  const RewardIconSelectorDialog({
    super.key,
    required this.currentlySelectedIconName,
    required this.onSelectIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Tr.t(
          TrKeys.selectRewardIconTitle)), // "Seleccionar Icono para Recompensa"
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm, vertical: AppDimensions.md),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: availableRewardIcons.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Ajusta según el tamaño deseado
            crossAxisSpacing: AppDimensions.sm,
            mainAxisSpacing: AppDimensions.sm,
          ),
          itemBuilder: (context, index) {
            final iconOption = availableRewardIcons[index];
            final bool isSelected =
                iconOption.name == currentlySelectedIconName;

            return InkWell(
              onTap: () {
                onSelectIcon(iconOption.name);
                Get.back(); // Cerrar el diálogo
              },
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
              child: Tooltip(
                message: iconOption.name.replaceAll('_', ' ').capitalizeFirst ??
                    iconOption.name, // Muestra un nombre legible
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight.withValues(
                            alpha: 0.5) // Color de fondo para el seleccionado
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.5),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Icon(
                    iconOption.iconData,
                    size: AppDimensions.iconLg, // Ajusta el tamaño del icono
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(Tr.t(TrKeys.cancel)),
        ),
      ],
    );
  }
}
