import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_message.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_text_field.dart';
import 'package:kidsdo/routes.dart';

class CreateFamilyPage extends GetView<FamilyController> {
  const CreateFamilyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Limpiar el formulario al entrar a la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearForms();
    });

    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.createFamily.tr),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ilustración o icono
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.family_restroom,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // Título y descripción
                Text(
                  TrKeys.createFamily.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontXxl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                Text(
                  'create_family_description'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontMd,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                // Campo de nombre de familia
                AuthTextField(
                  controller: controller.familyNameController,
                  hintText: TrKeys.familyName.tr,
                  prefixIcon: Icons.group,
                  textCapitalization: TextCapitalization.words,
                  validator: controller.validateFamilyName,
                  enabled: !controller.isCreatingFamily.value,
                  focusNode: controller.familyNameFocusNode,
                  autoValidate: true,
                ),
                const SizedBox(height: AppDimensions.md),

                // Mensaje de error si existe
                if (controller.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.md),
                    child: AuthMessage(
                      message: controller.errorMessage.value,
                      type: MessageType.error,
                      onDismiss: () => controller.errorMessage.value = '',
                    ),
                  ),

                const SizedBox(height: AppDimensions.lg),

                // Botón de crear
                ElevatedButton(
                  onPressed: controller.isCreatingFamily.value
                      ? null
                      : () {
                          if (formKey.currentState?.validate() ?? false) {
                            controller.createFamily().then((_) {
                              if (controller.currentFamily.value != null) {
                                Get.offAllNamed(Routes.family);
                              }
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppDimensions.md),
                  ),
                  child: controller.isCreatingFamily.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(TrKeys.createFamilyActionButton.tr),
                ),

                const SizedBox(height: AppDimensions.md),

                // Botón para cancelar
                OutlinedButton(
                  onPressed: controller.isCreatingFamily.value
                      ? null
                      : () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppDimensions.md),
                  ),
                  child: Text(TrKeys.cancel.tr),
                ),

                const SizedBox(height: AppDimensions.xl),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMd),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: AppDimensions.iconSm,
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Text(
                            'family_info_title'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        'family_creator_info'.tr,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSm,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
