import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/core/utils/family_utils.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:kidsdo/presentation/controllers/session_controller.dart';
import 'package:kidsdo/presentation/widgets/family/family_members_list.dart';
import 'package:kidsdo/routes.dart';

class FamilyPage extends GetView<FamilyController> {
  const FamilyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Asegurarse de que la familia actual se carga
    if (controller.status.value == FamilyStatus.initial) {
      controller.loadCurrentFamily();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.family.tr),
      ),
      body: Obx(() {
        if (controller.status.value == FamilyStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.status.value == FamilyStatus.error) {
          return _buildErrorState();
        }

        // Si el usuario no pertenece a una familia, mostrar opciones para crear o unirse
        if (controller.currentFamily.value == null) {
          return _buildNoFamilyState();
        }

        // Si el usuario pertenece a una familia, mostrar detalles de la familia
        return _buildFamilyDetails();
      }),
      floatingActionButton: Obx(() {
        // Solo mostrar el botón de acción flotante si hay una familia
        if (controller.currentFamily.value != null) {
          return FloatingActionButton(
            onPressed: () => Get.toNamed(Routes.childProfiles),
            tooltip: 'child_profiles'.tr,
            child: const Icon(Icons.child_care),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
          const SizedBox(height: AppDimensions.lg),
          ElevatedButton(
            onPressed: controller.loadCurrentFamily,
            child: Text(TrKeys.retry.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildNoFamilyState() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen o ilustración
              Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.family_restroom,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.lg),

              // Título
              Text(
                TrKeys.noFamily.tr,
                style: const TextStyle(
                  fontSize: AppDimensions.fontHeading,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.md),

              // Descripción
              Text(
                'family_info_text'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppDimensions.fontMd,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Botón para crear familia
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.createFamily),
                icon: const Icon(Icons.add),
                label: Text(TrKeys.createFamilyActionButton.tr),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.lg,
                    vertical: AppDimensions.md,
                  ),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
              const SizedBox(height: AppDimensions.md),

              // Botón para unirse a una familia
              OutlinedButton.icon(
                onPressed: () => Get.toNamed(Routes.joinFamily),
                icon: const Icon(Icons.group_add),
                label: Text(TrKeys.joinFamilyActionButton.tr),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.lg,
                    vertical: AppDimensions.md,
                  ),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyDetails() {
    final family = controller.currentFamily.value!;
    final userId = Get.find<SessionController>().currentUser.value?.uid ?? '';
    final isCreator = family.createdBy == userId;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta principal con información de la familia
            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusLg),
              ),
              elevation: AppDimensions.elevationSm,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre de la familia y rol del usuario
                    Row(
                      children: [
                        // Ícono de familia
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.md),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusCircular),
                          ),
                          child: const Icon(
                            Icons.family_restroom,
                            color: AppColors.primary,
                            size: AppDimensions.iconLg,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        // Nombre y rol
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                family.name,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontXl,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isCreator
                                    ? 'family_role_creator'.tr
                                    : 'family_role_member'.tr,
                                style: TextStyle(
                                  fontSize: AppDimensions.fontSm,
                                  color: isCreator
                                      ? AppColors.primary
                                      : AppColors.textMedium,
                                  fontWeight: isCreator
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.lg),

                    // Fecha de creación
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: AppDimensions.iconSm,
                          color: AppColors.textMedium,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          '${'family_created_on'.tr} ${_formatDate(family.createdAt)}',
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSm,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // Número de miembros
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: AppDimensions.iconSm,
                          color: AppColors.textMedium,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          'family_members_count'.trParams(
                              {'count': family.members.length.toString()}),
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSm,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.lg),

                    // Código de invitación
                    if (isCreator) ...[
                      const Divider(),
                      const SizedBox(height: AppDimensions.md),
                      Text(
                        'family_invite_code'.tr,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontMd,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sm),

                      // Si hay un código, mostrarlo, sino mostrar botón para generar
                      if (family.inviteCode != null &&
                          family.inviteCode!.isNotEmpty)
                        InkWell(
                          onTap: () => Get.toNamed(Routes.inviteCode),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.md,
                              vertical: AppDimensions.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusMd),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  FamilyUtils.formatFamilyCode(
                                      family.inviteCode!),
                                  style: const TextStyle(
                                    fontSize: AppDimensions.fontLg,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.sm),
                                const Icon(
                                  Icons.visibility,
                                  size: AppDimensions.iconSm,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () => Get.toNamed(Routes.inviteCode),
                          icon: const Icon(Icons.add_link),
                          label: Text(TrKeys.generateCodeActionButton.tr),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Sección de miembros
            Text(
              'family_members'.tr,
              style: const TextStyle(
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // Lista de miembros
            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusLg),
              ),
              elevation: AppDimensions.elevationSm,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Column(
                  children: [
                    // Lista de miembros
                    FamilyMembersList(familyCreatorId: family.createdBy),

                    // Sección de niños
                    const Divider(height: AppDimensions.xl),

                    // Botón para gestionar perfiles infantiles
                    ElevatedButton.icon(
                      onPressed: () => Get.toNamed(Routes.childProfiles),
                      icon: const Icon(Icons.child_care),
                      label: Text('manage_child_profiles'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.childBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    // Si no es el creador, mostrar botón para salir
                    if (!isCreator) ...[
                      const Divider(height: AppDimensions.xl),
                      OutlinedButton.icon(
                        onPressed: _confirmLeaveFamily,
                        icon: const Icon(Icons.exit_to_app,
                            color: AppColors.error),
                        label: Text(
                          TrKeys.leaveFamilyActionButton.tr,
                          style: const TextStyle(color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formatea la fecha para mostrar
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Muestra un diálogo de confirmación para salir de la familia
  void _confirmLeaveFamily() {
    Get.dialog(
      AlertDialog(
        title: Text('leave_family_title'.tr),
        content: Text('leave_family_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.leaveFamily();
            },
            child: Text(
              'leave_family_confirm'.tr,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
