import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/profile_controller.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';
import 'package:kidsdo/routes.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.profile.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed(Routes.editProfile),
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.status.value == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.status.value == ProfileStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  ElevatedButton(
                    onPressed: controller.loadProfile,
                    child: Text(TrKeys.retry.tr),
                  ),
                ],
              ),
            );
          }

          final profile = controller.profile.value;
          if (profile == null) {
            return Center(
              child: Text(TrKeys.noProfileData.tr),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                _buildAvatar(profile.avatarUrl),

                const SizedBox(height: AppDimensions.lg),

                // Nombre del usuario
                Text(
                  profile.displayName,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontHeading,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppDimensions.sm),

                // Email
                Text(
                  profile.email ?? '',
                  style: const TextStyle(
                    fontSize: AppDimensions.fontMd,
                    color: AppColors.textMedium,
                  ),
                ),

                const Divider(height: AppDimensions.xxl),

                // Información adicional
                _buildInfoItem(
                  icon: Icons.people,
                  title: TrKeys.children.tr,
                  value: '${profile.childrenIds.length}',
                  color: AppColors.childBlue,
                ),

                _buildInfoItem(
                  icon: Icons.family_restroom,
                  title: TrKeys.family.tr,
                  value: profile.familyId != null
                      ? TrKeys.familyCreated.tr
                      : TrKeys.noFamily.tr,
                  color: AppColors.childGreen,
                ),

                _buildInfoItem(
                  icon: Icons.calendar_today,
                  title: TrKeys.accountCreated.tr,
                  value: _formatDate(profile.createdAt),
                  color: AppColors.childPurple,
                ),

                const SizedBox(height: AppDimensions.xl),

                // Opciones adicionales
                _buildOptionItem(
                  icon: Icons.notifications_outlined,
                  title: TrKeys.notifications.tr,
                  onTap: () {
                    // Implementación futura
                    Get.snackbar(
                      TrKeys.comingSoon.tr,
                      TrKeys.comingSoonMessage.tr,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),

                _buildOptionItem(
                  icon: Icons.security_outlined,
                  title: TrKeys.privacy.tr,
                  onTap: () {
                    // Implementación futura
                    Get.snackbar(
                      TrKeys.comingSoon.tr,
                      TrKeys.comingSoonMessage.tr,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),

                _buildOptionItem(
                  icon: Icons.help_outline,
                  title: TrKeys.help.tr,
                  onTap: () {
                    // Implementación futura
                    Get.snackbar(
                      TrKeys.comingSoon.tr,
                      TrKeys.comingSoonMessage.tr,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    return CachedAvatar(
      url: avatarUrl,
      radius: 60,
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusCircular),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSm,
                    color: AppColors.textMedium,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontMd,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.md,
          horizontal: AppDimensions.sm,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: AppDimensions.iconMd,
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: AppDimensions.fontMd,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat.yMMMd();
    return formatter.format(date);
  }
}
