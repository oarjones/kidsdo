import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/controllers/child_profile_controller.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';
import 'package:kidsdo/routes.dart';

class ChildProfilesPage extends GetView<ChildProfileController> {
  const ChildProfilesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cargar perfiles infantiles al entrar a la página
    if (!controller.isLoadingProfiles.value &&
        controller.childProfiles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadChildProfiles();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('child_profiles'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: TrKeys.addChild.tr,
            onPressed: () => Get.toNamed(Routes.createChild),
          ),
        ],
      ),
      body: Obx(() {
        // Mostrar carga
        if (controller.isLoadingProfiles.value &&
            controller.childProfiles.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Mostrar error si hay
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  ElevatedButton.icon(
                    onPressed: controller.loadChildProfiles,
                    icon: const Icon(Icons.refresh),
                    label: Text(TrKeys.retry.tr),
                  ),
                ],
              ),
            ),
          );
        }

        // No hay perfiles infantiles
        if (controller.childProfiles.isEmpty) {
          return _buildEmptyState();
        }

        // Mostrar lista de perfiles
        return _buildChildProfiles();
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.createChild),
        tooltip: TrKeys.addChild.tr,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.child_care,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              'no_child_profiles'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'add_child_profiles_message'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppDimensions.fontMd,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(Routes.createChild),
              icon: const Icon(Icons.add),
              label: Text(TrKeys.addChild.tr),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.xl,
                  vertical: AppDimensions.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildProfiles() {
    return RefreshIndicator(
      onRefresh: controller.loadChildProfiles,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        child: ListView.builder(
          itemCount: controller.childProfiles.length,
          itemBuilder: (context, index) {
            final child = controller.childProfiles[index];
            return _buildChildProfileCard(child);
          },
        ),
      ),
    );
  }

  Widget _buildChildProfileCard(FamilyChild child) {
    // Determinar color basado en la configuración del perfil
    final Color themeColor = _getProfileColor(child.settings);

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppDimensions.sm,
        horizontal: AppDimensions.xs,
      ),
      elevation: AppDimensions.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      child: InkWell(
        onTap: () => _showChildProfileOptions(child),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Row(
            children: [
              // Avatar
              child.avatarUrl != null
                  ? CachedAvatar(
                      url: child.avatarUrl,
                      radius: 30,
                    )
                  : CircleAvatar(
                      radius: 30,
                      backgroundColor: themeColor.withAlpha(40),
                      child: Icon(
                        Icons.child_care,
                        size: 30,
                        color: themeColor,
                      ),
                    ),
              const SizedBox(width: AppDimensions.md),

              // Información del perfil
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${child.age} ${'years_old'.tr}',
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSm,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Row(
                      children: [
                        // Puntos
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withAlpha(40),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusSm),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.tertiary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${child.points} ${TrKeys.points.tr}',
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontXs,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.tertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.sm),

                        // Nivel
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor.withAlpha(40),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusSm),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 14,
                                color: themeColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${'level'.tr} ${child.level}',
                                style: TextStyle(
                                  fontSize: AppDimensions.fontXs,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Fecha de nacimiento
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.cake,
                    size: AppDimensions.iconSm,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(child.birthDate),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontXs,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProfileColor(Map<String, dynamic> settings) {
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

  void _showChildProfileOptions(FamilyChild child) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.lg,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.borderRadiusLg),
            topRight: Radius.circular(AppDimensions.borderRadiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              child: Row(
                children: [
                  child.avatarUrl != null
                      ? CachedAvatar(
                          url: child.avatarUrl,
                          radius: 25,
                        )
                      : CircleAvatar(
                          radius: 25,
                          backgroundColor:
                              _getProfileColor(child.settings).withAlpha(40),
                          child: Icon(
                            Icons.child_care,
                            size: 25,
                            color: _getProfileColor(child.settings),
                          ),
                        ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontLg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${child.age} ${'years_old'.tr}',
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSm,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(height: AppDimensions.lg),

            // Opciones
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: Text('edit_child_profile'.tr),
              onTap: () {
                Get.back();
                _editChildProfile(child);
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: AppColors.info),
              title: Text('view_child_challenges'.tr),
              onTap: () {
                Get.back();
                // Implementar en el futuro
                Get.snackbar(
                  TrKeys.comingSoon.tr,
                  TrKeys.comingSoonMessage.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.card_giftcard, color: AppColors.tertiary),
              title: Text('view_child_rewards'.tr),
              onTap: () {
                Get.back();
                // Implementar en el futuro
                Get.snackbar(
                  TrKeys.comingSoon.tr,
                  TrKeys.comingSoonMessage.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.switch_account, color: AppColors.childGreen),
              title: Text('access_child_mode'.tr),
              onTap: () {
                Get.back();
                // Implementar en el futuro
                Get.snackbar(
                  TrKeys.comingSoon.tr,
                  TrKeys.comingSoonMessage.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: Text('delete_child_profile'.tr),
              onTap: () {
                Get.back();
                _confirmDeleteProfile(child);
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDeleteProfile(FamilyChild child) {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_delete_profile'.tr),
        content: Text(
          'confirm_delete_profile_message'.trParams({'name': child.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              Get.back();
              controller.deleteChildProfile(child.id);
            },
            child: Text(TrKeys.delete.tr),
          ),
        ],
      ),
    );
  }

  void _editChildProfile(FamilyChild child) {
    // Seleccionar el perfil y preparar formulario para edición
    controller.selectChild(child);
    controller.prepareForEditChild(child);

    // Navegar a la pantalla de edición
    Get.toNamed(Routes.editChild);
  }
}
