import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/reward.dart';
import 'package:kidsdo/presentation/controllers/rewards_controller.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Si usas SVGs para los iconos

class RewardCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback? onTap; // Para ir a la vista de detalle o edición
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RewardCard({
    super.key,
    required this.reward,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  // Helper para obtener el color del tipo de recompensa (puedes expandir esto)
  Color _getRewardTypeColor(RewardType type, BuildContext context) {
    // Podrías definir colores específicos por tipo en AppColors o en el Theme
    switch (type) {
      case RewardType.simple:
        return AppColors.primary.withValues(alpha: 0.1);
      case RewardType.product:
        return AppColors.secondary.withValues(alpha: 0.1);
      case RewardType.experience:
        return AppColors.tertiary.withValues(alpha: 0.1);
      case RewardType.digitalAccess:
        return AppColors.info.withValues(alpha: 0.1);
      case RewardType.longTermGoal:
        return Colors.purple.withValues(alpha: 0.1);
      case RewardType.surprise:
        return Colors.orange.withValues(alpha: 0.1);
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  // Helper para obtener el nombre traducido del tipo de recompensa
  String _getRewardTypeName(RewardType type) {
    switch (type) {
      case RewardType.simple:
        return Tr.t(TrKeys.rewardTypeSimple);
      case RewardType.product:
        return Tr.t(TrKeys.rewardTypeProduct);
      case RewardType.experience:
        return Tr.t(TrKeys.rewardTypeExperience);
      case RewardType.digitalAccess:
        return Tr.t(TrKeys.rewardTypeDigitalAccess);
      case RewardType.longTermGoal:
        return Tr.t(TrKeys.rewardTypeLongTermGoal);
      case RewardType.surprise:
        return Tr.t(TrKeys.rewardTypeSurprise);
      default:
        return type.name;
    }
  }

  // Helper para obtener un icono representativo (necesitarás tus assets)
  Widget _getRewardIcon(BuildContext context) {
    if (reward.icon != null && reward.icon!.isNotEmpty) {
      // Asumimos que los iconos son assets y que tienes una forma de mapearlos
      // Ejemplo simple, necesitarás mejorar esto:
      String iconPath = 'assets/icons/rewards/${reward.icon}.svg'; // o .png
      // if (reward.icon!.startsWith('http')) {
      //   return Image.network(reward.icon!, width: 40, height: 40, fit: BoxFit.cover);
      // } else if (reward.icon!.endsWith('.svg')) {
      //   return SvgPicture.asset(iconPath, width: 36, height: 36, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn));
      // } else {
      //   return Image.asset(iconPath, width: 40, height: 40);
      // }
      // Placeholder:
      IconData iconData = Icons.star; // Icono por defecto
      if (reward.icon == 'ice_cream_icon') iconData = Icons.icecream;
      if (reward.icon == 'popcorn_icon') iconData = Icons.local_movies;
      if (reward.icon == 'game_controller_icon') {
        iconData = Icons.sports_esports;
      }
      if (reward.icon == 'movie_ticket_icon') iconData = Icons.movie;
      if (reward.icon == 'gift_icon') iconData = Icons.card_giftcard;
      if (reward.icon == 'book_icon') iconData = Icons.book_online;

      return Icon(iconData,
          size: 36, color: Theme.of(context).colorScheme.primary);
    }
    return Icon(Icons.star,
        size: 36,
        color: Theme.of(context).colorScheme.primary); // Icono por defecto
  }

  @override
  Widget build(BuildContext context) {
    final RewardsController controller =
        Get.find<RewardsController>(); // Para acciones

    return Card(
      elevation: AppDimensions.elevationSm,
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      child: InkWell(
        onTap: onTap ?? onEdit, // Por defecto, al tocar se edita
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.sm),
                    decoration: BoxDecoration(
                      color: _getRewardTypeColor(reward.type, context),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusMd),
                    ),
                    child: _getRewardIcon(context),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (reward.description != null &&
                            reward.description!.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: AppDimensions.xs),
                            child: Text(
                              reward.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: const Icon(Icons.edit_outlined),
                          title: Text(Tr.t(TrKeys.edit)),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline,
                              color: Theme.of(context).colorScheme.error),
                          title: Text(Tr.t(TrKeys.delete),
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    avatar: const Icon(Icons.stars,
                        color: AppColors.tertiary, size: AppDimensions.iconSm),
                    label: Text(
                      '${reward.pointsRequired} ${Tr.t(TrKeys.pointsSuffix)}', // Necesitarás TrKeys.pointsSuffix
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    backgroundColor: AppColors.tertiary.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: AppDimensions.xs / 2),
                  ),
                  Chip(
                    label: Text(
                      _getRewardTypeName(reward.type),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                    ),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: AppDimensions.xs / 2),
                  ),
                ],
              ),
              if (!reward.isEnabled) ...[
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    Icon(Icons.visibility_off_outlined,
                        size: AppDimensions.iconSm,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: AppDimensions.xs),
                    Text(
                      Tr.t(TrKeys
                          .rewardDisabledHint), // ej: "Deshabilitada (no visible para canjear)"
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
              // Aquí podrías añadir más info, como el estado de la recompensa (RewardStatus) si es relevante para los padres
              // Por ejemplo:
              // if (reward.status != RewardStatus.available)
              //   Padding(
              //     padding: const EdgeInsets.only(top: AppDimensions.sm),
              //     child: Text('Estado: ${reward.status.name}', style: Theme.of(context).textTheme.caption),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
