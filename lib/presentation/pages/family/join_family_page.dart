import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/core/utils/family_utils.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_message.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_text_field.dart';
import 'package:kidsdo/routes.dart';

class JoinFamilyPage extends GetView<FamilyController> {
  const JoinFamilyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Limpiar el formulario al entrar a la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearForms();
    });

    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('join_family'.tr),
      ),
      // Añadido SafeArea aquí
      body: SafeArea(
        child: Obx(() {
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
                        Icons.group_add,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // Título y descripción
                  Text(
                    'join_family'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontXxl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),

                  Text(
                    'join_family_description'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontMd,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),

                  // Ejemplo de cómo se ve un código
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusMd),
                      border: Border.all(color: AppColors.textLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'invite_code_example_title'.tr,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSm,
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Center(
                          child: Text(
                            FamilyUtils.formatFamilyCode('ABC123'),
                            style: const TextStyle(
                              fontSize: AppDimensions.fontXl,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),

                  // Campo de código de invitación
                  AuthTextField(
                    controller: controller.inviteCodeController,
                    hintText: 'invite_code'.tr,
                    prefixIcon: Icons.tag,
                    textCapitalization: TextCapitalization.characters,
                    validator: controller.validateInviteCode,
                    enabled: !controller.isJoiningFamily.value,
                    focusNode: controller.inviteCodeFocusNode,
                    autoValidate: true,
                    textInputAction: TextInputAction.done,
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

                  // Botón de unirse
                  ElevatedButton(
                    onPressed: controller.isJoiningFamily.value
                        ? null
                        : () {
                            if (formKey.currentState?.validate() ?? false) {
                              controller.joinFamily().then((_) {
                                if (controller.currentFamily.value != null) {
                                  Get.offAllNamed(Routes.family);
                                }
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.md),
                    ),
                    child: controller.isJoiningFamily.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(TrKeys.joinFamilyActionButton.tr),
                  ),

                  const SizedBox(height: AppDimensions.md),

                  // Botón para cancelar
                  OutlinedButton(
                    onPressed: controller.isJoiningFamily.value
                        ? null
                        : () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.md),
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
                              'join_family_info_title'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          'join_family_info_content'.tr,
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
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // Limpiar el formulario al entrar a la página
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     controller.clearForms();
  //   });

  //   final formKey = GlobalKey<FormState>();

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('join_family'.tr),
  //     ),
  //     body: Obx(() {
  //       return SingleChildScrollView(
  //         padding: const EdgeInsets.all(AppDimensions.lg),
  //         child: Form(
  //           key: formKey,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.stretch,
  //             children: [
  //               // Ilustración o icono
  //               Center(
  //                 child: Container(
  //                   width: 120,
  //                   height: 120,
  //                   decoration: BoxDecoration(
  //                     color: AppColors.primary.withValues(alpha: 0.1),
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: const Icon(
  //                     Icons.group_add,
  //                     size: 60,
  //                     color: AppColors.primary,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: AppDimensions.lg),

  //               // Título y descripción
  //               Text(
  //                 'join_family'.tr,
  //                 textAlign: TextAlign.center,
  //                 style: const TextStyle(
  //                   fontSize: AppDimensions.fontXxl,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: AppDimensions.md),

  //               Text(
  //                 'join_family_description'.tr,
  //                 textAlign: TextAlign.center,
  //                 style: const TextStyle(
  //                   fontSize: AppDimensions.fontMd,
  //                   color: AppColors.textMedium,
  //                 ),
  //               ),
  //               const SizedBox(height: AppDimensions.xl),

  //               // Ejemplo de cómo se ve un código
  //               Container(
  //                 padding: const EdgeInsets.all(AppDimensions.md),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.background,
  //                   borderRadius:
  //                       BorderRadius.circular(AppDimensions.borderRadiusMd),
  //                   border: Border.all(color: AppColors.textLight),
  //                 ),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'invite_code_example_title'.tr,
  //                       style: const TextStyle(
  //                         fontSize: AppDimensions.fontSm,
  //                         color: AppColors.textMedium,
  //                       ),
  //                     ),
  //                     const SizedBox(height: AppDimensions.sm),
  //                     Center(
  //                       child: Text(
  //                         FamilyUtils.formatFamilyCode('ABC123'),
  //                         style: const TextStyle(
  //                           fontSize: AppDimensions.fontXl,
  //                           fontWeight: FontWeight.bold,
  //                           letterSpacing: 2,
  //                           color: AppColors.textDark,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(height: AppDimensions.xl),

  //               // Campo de código de invitación
  //               AuthTextField(
  //                 controller: controller.inviteCodeController,
  //                 hintText: 'invite_code'.tr,
  //                 prefixIcon: Icons.tag,
  //                 textCapitalization: TextCapitalization.characters,
  //                 validator: controller.validateInviteCode,
  //                 enabled: !controller.isJoiningFamily.value,
  //                 focusNode: controller.inviteCodeFocusNode,
  //                 autoValidate: true,
  //                 textInputAction: TextInputAction.done,
  //               ),
  //               const SizedBox(height: AppDimensions.md),

  //               // Mensaje de error si existe
  //               if (controller.errorMessage.isNotEmpty)
  //                 Padding(
  //                   padding: const EdgeInsets.only(bottom: AppDimensions.md),
  //                   child: AuthMessage(
  //                     message: controller.errorMessage.value,
  //                     type: MessageType.error,
  //                     onDismiss: () => controller.errorMessage.value = '',
  //                   ),
  //                 ),

  //               const SizedBox(height: AppDimensions.lg),

  //               // Botón de unirse
  //               ElevatedButton(
  //                 onPressed: controller.isJoiningFamily.value
  //                     ? null
  //                     : () {
  //                         if (formKey.currentState?.validate() ?? false) {
  //                           controller.joinFamily().then((_) {
  //                             if (controller.currentFamily.value != null) {
  //                               Get.offAllNamed(Routes.family);
  //                             }
  //                           });
  //                         }
  //                       },
  //                 style: ElevatedButton.styleFrom(
  //                   padding:
  //                       const EdgeInsets.symmetric(vertical: AppDimensions.md),
  //                 ),
  //                 child: controller.isJoiningFamily.value
  //                     ? const SizedBox(
  //                         height: 24,
  //                         width: 24,
  //                         child: CircularProgressIndicator(
  //                           valueColor:
  //                               AlwaysStoppedAnimation<Color>(Colors.white),
  //                           strokeWidth: 2,
  //                         ),
  //                       )
  //                     : Text(TrKeys.joinFamilyActionButton.tr),
  //               ),

  //               const SizedBox(height: AppDimensions.md),

  //               // Botón para cancelar
  //               OutlinedButton(
  //                 onPressed: controller.isJoiningFamily.value
  //                     ? null
  //                     : () => Get.back(),
  //                 style: OutlinedButton.styleFrom(
  //                   padding:
  //                       const EdgeInsets.symmetric(vertical: AppDimensions.md),
  //                 ),
  //                 child: Text(TrKeys.cancel.tr),
  //               ),

  //               const SizedBox(height: AppDimensions.xl),

  //               // Información adicional
  //               Container(
  //                 padding: const EdgeInsets.all(AppDimensions.md),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.info.withValues(alpha: 0.1),
  //                   borderRadius:
  //                       BorderRadius.circular(AppDimensions.borderRadiusMd),
  //                   border: Border.all(
  //                     color: AppColors.info.withValues(alpha: 0.3),
  //                   ),
  //                 ),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         const Icon(
  //                           Icons.info_outline,
  //                           color: AppColors.info,
  //                           size: AppDimensions.iconSm,
  //                         ),
  //                         const SizedBox(width: AppDimensions.sm),
  //                         Text(
  //                           'join_family_info_title'.tr,
  //                           style: const TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             color: AppColors.info,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: AppDimensions.sm),
  //                     Text(
  //                       'join_family_info_content'.tr,
  //                       style: const TextStyle(
  //                         fontSize: AppDimensions.fontSm,
  //                         color: AppColors.textMedium,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     }),
  //   );
  // }
}
