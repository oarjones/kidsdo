import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/base_user.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';

class FamilyMembersList extends StatelessWidget {
  final String familyCreatorId;

  const FamilyMembersList({
    Key? key,
    required this.familyCreatorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FamilyController>();

    return Obx(() {
      if (controller.isLoadingMembers.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.lg),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.membersErrorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                Text(
                  controller.membersErrorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: AppDimensions.fontSm,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                TextButton.icon(
                  onPressed: controller.loadFamilyMembers,
                  icon: const Icon(Icons.refresh),
                  label: Text(TrKeys.retry.tr),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.familyMembers.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Text(
              'no_family_members_found'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppDimensions.fontSm,
                color: AppColors.textMedium,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.familyMembers.length,
        itemBuilder: (context, index) {
          final member = controller.familyMembers[index];
          return _buildMemberItem(member);
        },
      );
    });
  }

  Widget _buildMemberItem(BaseUser member) {
    final isCreator = member.uid == familyCreatorId;
    final isParent = member.type == 'parent';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: ListTile(
        leading: CachedAvatar(
          url: member.avatarUrl,
          radius: 24,
        ),
        title: Text(
          member.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            // Rol en la familia (creador o miembro)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isCreator
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : isParent
                        ? AppColors.bronze.withValues(alpha: 0.1)
                        : AppColors.childBlue.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSm),
              ),
              child: Text(
                isCreator
                    ? 'family_creator_label'.tr
                    : isParent
                        ? 'family_parent_label'.tr
                        : 'family_child_label'.tr,
                style: TextStyle(
                  fontSize: AppDimensions.fontXs,
                  color: isCreator
                      ? AppColors.primary
                      : isParent
                          ? AppColors.bronze
                          : AppColors.childBlue,
                ),
              ),
            ),

            // Email si es un padre
            if (isParent &&
                member.email != null &&
                member.email!.isNotEmpty) ...[
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  member.email!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontXs,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: isCreator
            ? const Icon(
                Icons.star,
                color: AppColors.gold,
                size: AppDimensions.iconSm,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
      ),
    );
  }
}
