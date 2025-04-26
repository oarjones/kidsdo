import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:kidsdo/presentation/controllers/child_access_controller.dart';
import 'package:kidsdo/presentation/controllers/parental_control_controller.dart';
import 'package:kidsdo/presentation/widgets/auth/parental_pin_dialog.dart';
import 'package:kidsdo/presentation/widgets/parental_control/time_restriction_widget.dart';
import 'package:kidsdo/routes.dart';

enum RestrictionType {
  timeLimit,
  blockTemporary,
  blockPermanent,
}

class RestrictedAccessPage extends StatelessWidget {
  final RestrictionType restrictionType;
  final String? customMessage;

  const RestrictedAccessPage({
    Key? key,
    required this.restrictionType,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final childAccessController = Get.find<ChildAccessController>();
    final parentalControlController = Get.find<ParentalControlController>();

    // Determinar mensaje según el tipo de restricción
    String message = '';

    switch (restrictionType) {
      case RestrictionType.timeLimit:
        message = customMessage ??
            parentalControlController.getTimeRestrictionMessage() ??
            'time_restriction_default_message'.tr;
        break;

      case RestrictionType.blockTemporary:
        final remainingMinutes =
            parentalControlController.getRemainingLockTimeMinutes();
        message = 'parental_control_temporarily_locked'
            .trParams({'minutes': remainingMinutes.toString()});
        break;

      case RestrictionType.blockPermanent:
        message = customMessage ?? 'profile_blocked_message'.tr;
        break;
    }

    // Si es tiempo límite, usar el widget específico
    if (restrictionType == RestrictionType.timeLimit) {
      return TimeRestrictionWidget(message: message);
    }

    // Para otros tipos de bloqueo, usar un diseño diferente con opción de PIN parental
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono y título
              Icon(
                restrictionType == RestrictionType.blockTemporary
                    ? Icons.lock_clock
                    : Icons.block,
                size: 80,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                restrictionType == RestrictionType.blockTemporary
                    ? 'temporary_block_title'.tr
                    : 'access_blocked_title'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Mensaje
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Botones de acción
              ElevatedButton.icon(
                onPressed: () => Get.offAllNamed(Routes.home),
                icon: const Icon(Icons.home),
                label: Text('go_to_home'.tr),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
              ),
              const SizedBox(height: 16),

              // Opción para padres para desbloquear
              OutlinedButton.icon(
                onPressed: () {
                  ParentalPinDialog.show(
                    customTitle: 'parent_unlock_title'.tr,
                    customSubtitle: 'parent_unlock_description'.tr,
                  ).then((success) {
                    if (success) {
                      // Si el PIN es correcto, desbloquear
                      parentalControlController.unlockParentalControl();
                      Get.offAllNamed(Routes.home);
                    }
                  });
                },
                icon: const Icon(Icons.lock_open),
                label: Text('parent_unlock'.tr),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método estático para mostrar esta página
  static void show({
    required RestrictionType restrictionType,
    String? customMessage,
  }) {
    Get.to(
      () => RestrictedAccessPage(
        restrictionType: restrictionType,
        customMessage: customMessage,
      ),
      fullscreenDialog: true,
    );
  }
}
