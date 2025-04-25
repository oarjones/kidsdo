import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart';
import 'package:kidsdo/presentation/widgets/common/cached_avatar.dart';
import 'package:kidsdo/routes.dart';

class ChildProfileSelectionPage extends GetView<ChildAccessController> {
  const ChildProfileSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cargar perfiles infantiles al entrar a la página
    if (controller.availableChildren.isEmpty) {
      controller.loadAvailableChildProfiles();
    }

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          // Mostrar carga
          if (controller.status.value == ChildAccessStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Mostrar error si hay
          if (controller.status.value == ChildAccessStatus.error) {
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
                      onPressed: controller.loadAvailableChildProfiles,
                      icon: const Icon(Icons.refresh),
                      label: Text(TrKeys.retry.tr),
                    ),
                  ],
                ),
              ),
            );
          }

          // No hay perfiles infantiles
          if (controller.availableChildren.isEmpty) {
            return _buildEmptyState();
          }

          // Mostrar selección de perfiles
          return _buildProfilesSelection();
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
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
                  TrKeys.noChildProfilesAccess.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  TrKeys.noChildProfilesAccessMessage.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontMd,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Botón para volver al modo parental
        Positioned(
          top: AppDimensions.md,
          right: AppDimensions.md,
          child: _buildParentModeButton(),
        ),
      ],
    );
  }

  Widget _buildProfilesSelection() {
    return Stack(
      children: [
        Column(
          children: [
            // Encabezado
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    TrKeys.whoIsUsing.tr,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontXl,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    TrKeys.selectProfileMessage.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontMd,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),

            // Perfiles
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppDimensions.lg),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: AppDimensions.lg,
                  mainAxisSpacing: AppDimensions.lg,
                ),
                itemCount: controller.availableChildren.length,
                itemBuilder: (context, index) {
                  final child = controller.availableChildren[index];
                  return _buildProfileCard(child);
                },
              ),
            ),
          ],
        ),

        // Botón para volver al modo parental
        Positioned(
          top: AppDimensions.md,
          right: AppDimensions.md,
          child: _buildParentModeButton(),
        ),
      ],
    );
  }

  Widget _buildProfileCard(FamilyChild child) {
    // Determinar color basado en la configuración del perfil
    final Color themeColor = _getProfileColor(child.settings);

    return Card(
      elevation: AppDimensions.elevationMd,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      child: InkWell(
        onTap: () => _selectProfile(child),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Hero(
                tag: 'child_avatar_${child.id}',
                child: child.avatarUrl != null
                    ? CachedAvatar(
                        url: child.avatarUrl,
                        radius: 50,
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: themeColor.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.child_care,
                          size: 50,
                          color: themeColor,
                        ),
                      ),
              ),
              const SizedBox(height: AppDimensions.md),

              // Nombre
              Text(
                child.name,
                style: const TextStyle(
                  fontSize: AppDimensions.fontLg,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Edad
              Text(
                '${child.age} ${TrKeys.yearsOld.tr}',
                style: const TextStyle(
                  fontSize: AppDimensions.fontSm,
                  color: AppColors.textMedium,
                ),
              ),

              const SizedBox(height: AppDimensions.md),

              // Botón de acceso
              ElevatedButton(
                onPressed: () => _selectProfile(child),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                  ),
                  minimumSize: const Size(double.infinity, 36),
                ),
                child: Text(
                  TrKeys.accessProfile.tr,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParentModeButton() {
    return ElevatedButton.icon(
      onPressed: _showParentPinDialog,
      icon: const Icon(Icons.lock),
      label: Text(TrKeys.parentMode.tr),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        shadowColor: Colors.black26,
        elevation: 4,
      ),
    );
  }

  // Muestra el diálogo para introducir el PIN de control parental
  void _showParentPinDialog() {
    final TextEditingController pinController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(TrKeys.enterParentalPin.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              TrKeys.enterParentalPinMessage.tr,
              style: const TextStyle(
                fontSize: AppDimensions.fontSm,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                labelText: TrKeys.pin.tr,
                hintText: '****',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              if (controller.verifyParentalPin(pinController.text)) {
                Get.back();
                Get.offNamed(Routes.home);
              } else {
                Get.back();
                Get.snackbar(
                  TrKeys.incorrectPin.tr,
                  TrKeys.incorrectPinMessage.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  colorText: AppColors.error,
                );
              }
            },
            child: Text(TrKeys.ok.tr),
          ),
        ],
      ),
    );
  }

  // Selecciona un perfil infantil y navega a su dashboard
  void _selectProfile(FamilyChild child) {
    controller.activateChildProfile(child).then((_) {
      Get.offNamed(Routes.childDashboard);
    });
  }

  // Obtiene el color correspondiente a la configuración del perfil
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
}
