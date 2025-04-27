import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/core/utils/family_utils.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_message.dart';

class InviteCodePage extends GetView<FamilyController> {
  const InviteCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // No se puede acceder a esta página si no hay una familia
    if (controller.currentFamily.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('family_invite_code_page_title'.tr),
      ),
      // Añadido SafeArea aquí
      body: SafeArea(
        child: Obx(() {
          final family = controller.currentFamily.value;
          if (family == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final hasInviteCode =
              family.inviteCode != null && family.inviteCode!.isNotEmpty;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado con ilustración
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.share,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // Título y descripción
                  Text(
                    'family_invite_code_title'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontXl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),

                  Text(
                    'family_invite_code_description'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontMd,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),

                  // Si hay código, mostrarlo, sino, mostrar botón para generar
                  if (hasInviteCode) ...[
                    _buildCurrentCodeCard(family.inviteCode!),
                  ] else ...[
                    _buildNoCodeState(),
                  ],

                  // Mensaje de error si existe
                  if (controller.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.md),
                      child: AuthMessage(
                        message: controller.errorMessage.value,
                        type: MessageType.error,
                        onDismiss: () => controller.errorMessage.value = '',
                      ),
                    ),

                  const SizedBox(height: AppDimensions.xl),

                  // Botón para generar nuevo código (o regenerar)
                  ElevatedButton.icon(
                    onPressed: controller.isGeneratingCode.value
                        ? null
                        : () => controller.generateNewInviteCode(),
                    icon: const Icon(Icons.refresh),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.md),
                    ),
                    label: Text(
                      hasInviteCode
                          ? 'regenerate_invite_code'.tr
                          : TrKeys.generateCodeActionButton.tr,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.md),

                  // Botón para volver
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.md),
                    ),
                    child: Text(TrKeys.ok.tr),
                  ),

                  const SizedBox(height: AppDimensions.xl),

                  // Información adicional
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.borderRadiusMd),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_outlined,
                              color: AppColors.warning,
                              size: AppDimensions.iconSm,
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Text(
                              'invite_code_warning_title'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          'invite_code_warning_content'.tr,
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
  //   // No se puede acceder a esta página si no hay una familia
  //   if (controller.currentFamily.value == null) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       Get.back();
  //     });
  //     return const Scaffold(body: Center(child: CircularProgressIndicator()));
  //   }

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('family_invite_code_page_title'.tr),
  //     ),
  //     body: Obx(() {
  //       final family = controller.currentFamily.value;
  //       if (family == null) {
  //         return const Center(child: CircularProgressIndicator());
  //       }

  //       final hasInviteCode =
  //           family.inviteCode != null && family.inviteCode!.isNotEmpty;

  //       return SingleChildScrollView(
  //         child: Padding(
  //           padding: const EdgeInsets.all(AppDimensions.lg),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.stretch,
  //             children: [
  //               // Encabezado con ilustración
  //               Center(
  //                 child: Container(
  //                   width: 120,
  //                   height: 120,
  //                   decoration: BoxDecoration(
  //                     color: AppColors.primary.withValues(alpha: 0.1),
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: const Icon(
  //                     Icons.share,
  //                     size: 60,
  //                     color: AppColors.primary,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: AppDimensions.lg),

  //               // Título y descripción
  //               Text(
  //                 'family_invite_code_title'.tr,
  //                 textAlign: TextAlign.center,
  //                 style: const TextStyle(
  //                   fontSize: AppDimensions.fontXl,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: AppDimensions.md),

  //               Text(
  //                 'family_invite_code_description'.tr,
  //                 textAlign: TextAlign.center,
  //                 style: const TextStyle(
  //                   fontSize: AppDimensions.fontMd,
  //                   color: AppColors.textMedium,
  //                 ),
  //               ),
  //               const SizedBox(height: AppDimensions.xl),

  //               // Si hay código, mostrarlo, sino, mostrar botón para generar
  //               if (hasInviteCode) ...[
  //                 _buildCurrentCodeCard(family.inviteCode!),
  //               ] else ...[
  //                 _buildNoCodeState(),
  //               ],

  //               // Mensaje de error si existe
  //               if (controller.errorMessage.isNotEmpty)
  //                 Padding(
  //                   padding:
  //                       const EdgeInsets.symmetric(vertical: AppDimensions.md),
  //                   child: AuthMessage(
  //                     message: controller.errorMessage.value,
  //                     type: MessageType.error,
  //                     onDismiss: () => controller.errorMessage.value = '',
  //                   ),
  //                 ),

  //               const SizedBox(height: AppDimensions.xl),

  //               // Botón para generar nuevo código (o regenerar)
  //               ElevatedButton.icon(
  //                 onPressed: controller.isGeneratingCode.value
  //                     ? null
  //                     : () => controller.generateNewInviteCode(),
  //                 icon: const Icon(Icons.refresh),
  //                 style: ElevatedButton.styleFrom(
  //                   padding:
  //                       const EdgeInsets.symmetric(vertical: AppDimensions.md),
  //                 ),
  //                 label: Text(
  //                   hasInviteCode
  //                       ? 'regenerate_invite_code'.tr
  //                       : TrKeys.generateCodeActionButton.tr,
  //                 ),
  //               ),

  //               const SizedBox(height: AppDimensions.md),

  //               // Botón para volver
  //               OutlinedButton(
  //                 onPressed: () => Get.back(),
  //                 style: OutlinedButton.styleFrom(
  //                   padding:
  //                       const EdgeInsets.symmetric(vertical: AppDimensions.md),
  //                 ),
  //                 child: Text(TrKeys.ok.tr),
  //               ),

  //               const SizedBox(height: AppDimensions.xl),

  //               // Información adicional
  //               Container(
  //                 padding: const EdgeInsets.all(AppDimensions.md),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.warning.withValues(alpha: 0.1),
  //                   borderRadius:
  //                       BorderRadius.circular(AppDimensions.borderRadiusMd),
  //                   border: Border.all(
  //                     color: AppColors.warning.withValues(alpha: 0.3),
  //                   ),
  //                 ),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         const Icon(
  //                           Icons.warning_amber_outlined,
  //                           color: AppColors.warning,
  //                           size: AppDimensions.iconSm,
  //                         ),
  //                         const SizedBox(width: AppDimensions.sm),
  //                         Text(
  //                           'invite_code_warning_title'.tr,
  //                           style: const TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             color: AppColors.warning,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: AppDimensions.sm),
  //                     Text(
  //                       'invite_code_warning_content'.tr,
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

  Widget _buildCurrentCodeCard(String code) {
    return Card(
      elevation: AppDimensions.elevationMd,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            Text(
              'current_invite_code'.tr,
              style: const TextStyle(
                fontSize: AppDimensions.fontSm,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // Código con formato
            Text(
              FamilyUtils.formatFamilyCode(code),
              style: const TextStyle(
                fontSize: AppDimensions.fontHeading,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Botón para copiar al portapapeles
            OutlinedButton.icon(
              onPressed: () => _copyToClipboard(code),
              icon: const Icon(Icons.copy),
              label: Text('copy_to_clipboard'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.lg,
                  vertical: AppDimensions.sm,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // Fecha de generación (ejemplo)
            Text(
              'code_valid_info'.tr,
              style: const TextStyle(
                fontSize: AppDimensions.fontXs,
                color: AppColors.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCodeState() {
    return Card(
      elevation: AppDimensions.elevationMd,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            const Icon(
              Icons.code_off,
              size: 48,
              color: AppColors.textLight,
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'no_invite_code'.tr,
              style: const TextStyle(
                fontSize: AppDimensions.fontLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'generate_invite_code_message'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppDimensions.fontSm,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            if (controller.isGeneratingCode.value)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code)).then((_) {
      Get.snackbar(
        'code_copied_title'.tr,
        'code_copied_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 2),
      );
    });
  }
}
