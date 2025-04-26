import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/domain/entities/family_child.dart';
import 'package:kidsdo/domain/repositories/family_child_repository.dart';
import 'package:kidsdo/presentation/controllers/child_access_controller.dart';
import 'package:kidsdo/presentation/controllers/family_controller.dart';
import 'package:kidsdo/presentation/controllers/parental_control_controller.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_message.dart';

class ParentalControlPage extends StatefulWidget {
  const ParentalControlPage({Key? key}) : super(key: key);

  @override
  State<ParentalControlPage> createState() => _ParentalControlPageState();
}

class _ParentalControlPageState extends State<ParentalControlPage> {
  final ParentalControlController controller =
      Get.find<ParentalControlController>();
  final ChildAccessController childAccessController =
      Get.find<ChildAccessController>();

  // Lista de perfiles infantiles
  final RxList<FamilyChild> childProfiles = RxList<FamilyChild>([]);
  final RxBool isLoadingProfiles = RxBool(false);
  final RxString profilesErrorMessage = RxString('');

  @override
  void initState() {
    super.initState();
    // Cargar perfiles infantiles al iniciar
    _loadChildrenProfiles();
  }

  Future<void> _loadChildrenProfiles() async {
    isLoadingProfiles.value = true;
    try {
      // Obtener la familia actual desde el controlador de familia directamente
      final currentFamily = Get.find<FamilyController>().currentFamily.value;
      if (currentFamily != null) {
        // Obtener todos los perfiles de la familia, no solo los disponibles
        final result = await Get.find<IFamilyChildRepository>()
            .getChildrenByFamilyId(currentFamily.id);

        result.fold((failure) {
          profilesErrorMessage.value = 'error_loading_profiles'.tr;
          isLoadingProfiles.value = false;
        }, (children) {
          childProfiles.value = children;
          isLoadingProfiles.value = false;
        });
      } else {
        childProfiles.value = [];
        isLoadingProfiles.value = false;
      }
    } catch (e) {
      profilesErrorMessage.value = 'error_loading_profiles'.tr;
      isLoadingProfiles.value = false;
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(TrKeys.parentalControl.tr),
  //     ),
  //     body: Obx(() {
  //       if (controller.status.value == ParentalControlStatus.loading) {
  //         return const Center(child: CircularProgressIndicator());
  //       }

  //       return Padding(
  //         padding: const EdgeInsets.only(bottom: 16),
  //         child: Column(
  //           children: [
  //             Expanded(
  //               child: SingleChildScrollView(
  //                 padding: const EdgeInsets.all(AppDimensions.lg),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // Sección de PIN de acceso
  //                     _buildParentalPinSection(context),
  //                     const SizedBox(height: AppDimensions.xl),

  //                     // Sección de restricciones de tiempo
  //                     _buildTimeRestrictionsSection(context),
  //                     const SizedBox(height: AppDimensions.xl),

  //                     // Sección de bloqueo de perfiles
  //                     _buildProfileBlockSection(context),
  //                     const SizedBox(height: AppDimensions.xl),

  //                     // Sección de restricciones de contenido
  //                     _buildContentRestrictionsSection(context),
  //                     const SizedBox(height: AppDimensions.xl),

  //                     // Mensaje de error si existe
  //                     if (controller.errorMessage.isNotEmpty)
  //                       Padding(
  //                         padding:
  //                             const EdgeInsets.only(bottom: AppDimensions.md),
  //                         child: AuthMessage(
  //                           message: controller.errorMessage.value,
  //                           type: MessageType.error,
  //                           onDismiss: () => controller.errorMessage.value = '',
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
  //               child: ElevatedButton(
  //                 onPressed: _saveSettings,
  //                 style: ElevatedButton.styleFrom(
  //                   minimumSize: const Size(double.infinity, 48),
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: AppDimensions.lg,
  //                     vertical: AppDimensions.md,
  //                   ),
  //                 ),
  //                 child: Text(TrKeys.save.tr),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     }),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.parentalControl.tr),
      ),
      // ENVUELVE EL BODY CON SafeArea
      body: SafeArea(
        // <--- Añadido SafeArea aquí
        child: Obx(() {
          if (controller.status.value == ParentalControlStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // He quitado el Padding externo que tenías aquí (EdgeInsets.only(bottom: 16))
          // porque SafeArea ya gestiona el padding inferior necesario.
          // Si necesitas padding *adicional* al del SafeArea, puedes añadirlo dentro.
          return Column(
            // <--- Contenido principal de tu body
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección de PIN de acceso
                      _buildParentalPinSection(context),
                      const SizedBox(height: AppDimensions.xl),

                      // Sección de restricciones de tiempo
                      _buildTimeRestrictionsSection(context),
                      const SizedBox(height: AppDimensions.xl),

                      // Sección de bloqueo de perfiles
                      _buildProfileBlockSection(context),
                      const SizedBox(height: AppDimensions.xl),

                      // Sección de restricciones de contenido
                      _buildContentRestrictionsSection(context),
                      const SizedBox(height: AppDimensions.xl),

                      // Mensaje de error si existe
                      if (controller.errorMessage.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppDimensions.md),
                          child: AuthMessage(
                            message: controller.errorMessage.value,
                            type: MessageType.error,
                            onDismiss: () => controller.errorMessage.value = '',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // El botón sigue aquí, pero ahora dentro del área segura
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16,
                    8), // Puedes ajustar este padding si es necesario
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                      vertical: AppDimensions.md,
                    ),
                  ),
                  child: Text(TrKeys.save.tr),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildParentalPinSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      elevation: AppDimensions.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            Row(
              children: [
                const Icon(Icons.pin, color: AppColors.primary),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  'parental_pin_section_title'.tr,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            // Switch para activar/desactivar PIN
            SwitchListTile(
              title: Text('use_parental_pin'.tr),
              subtitle: Text('use_parental_pin_description'.tr),
              value: controller.useParentalPin.value,
              onChanged: (value) {
                controller.useParentalPin.value = value;

                // Si se activa por primera vez, mostrar un diálogo para establecer el PIN
                if (value && controller.parentalPin.value == '0000') {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showChangePinDialog(context);
                  });
                }
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Botón para cambiar PIN
            if (controller.useParentalPin.value) ...[
              const SizedBox(height: AppDimensions.sm),
              OutlinedButton.icon(
                onPressed: () => _showChangePinDialog(context),
                icon: const Icon(Icons.edit),
                label: Text('change_parental_pin'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.sm,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.md),

              // Campo para email de recuperación
              TextFormField(
                initialValue: controller.recoveryEmail.value,
                decoration: InputDecoration(
                  labelText: 'recovery_email'.tr,
                  hintText: 'recovery_email_hint'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => controller.recoveryEmail.value = value,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRestrictionsSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      elevation: AppDimensions.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            Row(
              children: [
                const Icon(Icons.timelapse, color: AppColors.primary),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  'time_restrictions_section_title'.tr,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            // Switch para activar/desactivar restricciones de tiempo
            SwitchListTile(
              title: Text('use_time_restrictions'.tr),
              subtitle: Text('use_time_restrictions_description'.tr),
              value: controller.useTimeRestrictions.value,
              onChanged: (value) =>
                  controller.useTimeRestrictions.value = value,
              contentPadding: EdgeInsets.zero,
            ),

            // Configuraciones de horario permitido
            if (controller.useTimeRestrictions.value) ...[
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('start_time'.tr),
                        const SizedBox(height: AppDimensions.xs),
                        InkWell(
                          onTap: () => _selectTimeRange(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.md,
                              vertical: AppDimensions.md,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.textLight),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusMd),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(controller.allowedStartTime.value),
                                const Icon(
                                  Icons.access_time,
                                  size: AppDimensions.iconSm,
                                  color: AppColors.textMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('end_time'.tr),
                        const SizedBox(height: AppDimensions.xs),
                        InkWell(
                          onTap: () => _selectTimeRange(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.md,
                              vertical: AppDimensions.md,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.textLight),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusMd),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(controller.allowedEndTime.value),
                                const Icon(
                                  Icons.access_time,
                                  size: AppDimensions.iconSm,
                                  color: AppColors.textMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Selector de tiempo máximo de sesión
              const SizedBox(height: AppDimensions.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'max_session_time'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    'max_session_time_description'.tr,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSm,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: controller.maxSessionTime.value.toDouble(),
                          min: 15,
                          max: 180,
                          divisions: 11,
                          label: '${controller.maxSessionTime.value} min',
                          onChanged: (value) =>
                              controller.maxSessionTime.value = value.toInt(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 30),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMd),
                        ),
                        child: Text(
                          '${controller.maxSessionTime.value} min',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBlockSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      elevation: AppDimensions.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            Row(
              children: [
                const Icon(Icons.block, color: AppColors.primary),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  'profile_block_section_title'.tr,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            // Texto explicativo
            Text(
              'profile_block_description'.tr,
              style: const TextStyle(
                fontSize: AppDimensions.fontSm,
                color: AppColors.textMedium,
              ),
            ),

            const SizedBox(height: AppDimensions.md),

            // Lista de perfiles con interruptor para bloquear/desbloquear
            Obx(() {
              if (isLoadingProfiles.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.lg),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (profilesErrorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Column(
                      children: [
                        Text(
                          profilesErrorMessage.value,
                          style: const TextStyle(color: AppColors.error),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        OutlinedButton.icon(
                          onPressed: _loadChildrenProfiles,
                          icon: const Icon(Icons.refresh),
                          label: Text(TrKeys.retry.tr),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (childProfiles.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Text('no_children_profiles'.tr),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: childProfiles.length,
                itemBuilder: (context, index) {
                  final child = childProfiles[index];
                  final isBlocked =
                      controller.blockedProfiles.contains(child.id);

                  return SwitchListTile(
                    title: Text(child.name),
                    subtitle: Text(
                      isBlocked ? 'profile_blocked'.tr : 'profile_unblocked'.tr,
                      style: TextStyle(
                        color: isBlocked ? AppColors.error : AppColors.success,
                        fontSize: AppDimensions.fontSm,
                      ),
                    ),
                    value: isBlocked,
                    onChanged: (value) async {
                      await controller.toggleProfileBlock(child.id);
                      // No necesitamos recargar los perfiles aquí, ya que solo cambiamos el estado de bloqueo
                      // Forzar la reconstrucción del switch actualizando el estado local
                      setState(() {
                        // Este setState forzará la reconstrucción con el estado actualizado
                      });
                    },
                    secondary: CircleAvatar(
                      backgroundColor: isBlocked
                          ? AppColors.textLight
                          : AppColors.childBlue.withValues(alpha: 50),
                      child: Icon(
                        Icons.child_care,
                        color: isBlocked
                            ? AppColors.textMedium
                            : AppColors.childBlue,
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildContentRestrictionsSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      elevation: AppDimensions.elevationSm,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            Row(
              children: [
                const Icon(Icons.content_cut, color: AppColors.primary),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  'content_restrictions_section_title'.tr,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            // Restricción de contenido premium
            SwitchListTile(
              title: Text('restrict_premium_content'.tr),
              subtitle: Text('restrict_premium_content_description'.tr),
              value: controller.restrictPremiumContent.value,
              onChanged: (value) =>
                  controller.restrictPremiumContent.value = value,
              contentPadding: EdgeInsets.zero,
            ),

            // Espacio para contenido futuro
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      TrKeys.comingSoon.tr,
                      TrKeys.comingSoonMessage.tr,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text('more_content_restrictions'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.sm,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Muestra el diálogo para cambiar PIN
  void _showChangePinDialog(BuildContext context) {
    controller.currentPinController.clear();
    controller.newPinController.clear();
    controller.confirmPinController.clear();

    final isFirstPin = controller.parentalPin.value == '0000';

    Get.dialog(
      AlertDialog(
        title:
            Text(isFirstPin ? 'set_parental_pin'.tr : 'change_parental_pin'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isFirstPin
                    ? 'set_parental_pin_description'.tr
                    : 'change_parental_pin_description'.tr,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSm,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: AppDimensions.md),

              // PIN actual (solo si no es el primero)
              if (!isFirstPin) ...[
                TextField(
                  controller: controller.currentPinController,
                  decoration: InputDecoration(
                    labelText: 'current_pin'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                ),
                const SizedBox(height: AppDimensions.sm),
              ],

              // Nuevo PIN
              TextField(
                controller: controller.newPinController,
                decoration: InputDecoration(
                  labelText: 'new_pin'.tr,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
              ),
              const SizedBox(height: AppDimensions.sm),

              // Confirmar nuevo PIN
              TextField(
                controller: controller.confirmPinController,
                decoration: InputDecoration(
                  labelText: 'confirm_pin'.tr,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();

              // Si es el primer PIN y el usuario cancela, desactivar el uso de PIN
              if (isFirstPin) {
                controller.useParentalPin.value = false;
              }
            },
            child: Text(TrKeys.cancel.tr),
          ),
          ElevatedButton(
            onPressed: () => _verifyAndChangePIN(isFirstPin),
            child: Text(TrKeys.ok.tr),
          ),
        ],
      ),
    );
  }

  // Verificar y cambiar PIN
  void _verifyAndChangePIN(bool isFirstPin) {
    final newPin = controller.newPinController.text;
    final confirmPin = controller.confirmPinController.text;
    final currentPin =
        isFirstPin ? '0000' : controller.currentPinController.text;

    // Verificar que el PIN tenga 4 dígitos
    if (newPin.length != 4 || !RegExp(r'^[0-9]{4}$').hasMatch(newPin)) {
      Get.snackbar(
        'invalid_pin_format_title'.tr,
        'invalid_pin_format_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 40),
        colorText: Colors.red,
      );
      return;
    }

    // Verificar que las confirmaciones coincidan
    if (newPin != confirmPin) {
      Get.snackbar(
        'pin_mismatch_title'.tr,
        'pin_mismatch_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 40),
        colorText: Colors.red,
      );
      return;
    }

    // Cambiar PIN
    controller.changeParentalPin(currentPin, newPin).then((success) {
      if (success) {
        Get.back(); // Cerrar diálogo
        Get.snackbar(
          'pin_changed_title'.tr,
          'pin_changed_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 40),
          colorText: Colors.green,
        );
      } else {
        Get.snackbar(
          'pin_change_error_title'.tr,
          controller.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 40),
          colorText: Colors.red,
        );
      }
    });
  }

  // Selecciona un horario de inicio o fin
  void _selectTimeRange(BuildContext context, bool isStartTime) {
    final initialTimeStr = isStartTime
        ? controller.allowedStartTime.value
        : controller.allowedEndTime.value;

    final parts = initialTimeStr.split(':');
    final initialHour = int.parse(parts[0]);
    final initialMinute = int.parse(parts[1]);

    final initialTime = TimeOfDay(hour: initialHour, minute: initialMinute);

    showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    ).then((pickedTime) {
      if (pickedTime != null) {
        final hour = pickedTime.hour.toString().padLeft(2, '0');
        final minute = pickedTime.minute.toString().padLeft(2, '0');
        final timeString = '$hour:$minute';

        if (isStartTime) {
          controller.allowedStartTime.value = timeString;
        } else {
          controller.allowedEndTime.value = timeString;
        }
      }
    });
  }

  // Guardar cambios de configuración
  void _saveSettings() {
    controller.saveParentalControlSettings().then((success) {
      if (success) {
        // Email de recuperación
        if (controller.recoveryEmail.value.isNotEmpty) {
          controller.setRecoveryEmail(controller.recoveryEmail.value);
        }

        // Recargar perfiles para reflejar cualquier cambio
        _loadChildrenProfiles();

        Get.snackbar(
          'settings_saved_title'.tr,
          'settings_saved_message'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 40),
          colorText: Colors.green,
        );
      } else {
        Get.snackbar(
          'settings_save_error_title'.tr,
          controller.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 40),
          colorText: Colors.red,
        );
      }
    });
  }
}
