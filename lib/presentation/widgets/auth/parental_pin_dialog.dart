import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/parental_control_controller.dart';
import 'package:kidsdo/presentation/widgets/auth/pin_code_widget.dart';

class ParentalPinDialog extends StatefulWidget {
  final Function(bool) onResult;
  final String? customTitle;
  final String? customSubtitle;

  const ParentalPinDialog({
    Key? key,
    required this.onResult,
    this.customTitle,
    this.customSubtitle,
  }) : super(key: key);

  @override
  State<ParentalPinDialog> createState() => _ParentalPinDialogState();

  static Future<bool> show({
    String? customTitle,
    String? customSubtitle,
  }) async {
    final result = await Get.dialog<bool>(
      ParentalPinDialog(
        onResult: (result) => Get.back(result: result),
        customTitle: customTitle,
        customSubtitle: customSubtitle,
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }
}

class _ParentalPinDialogState extends State<ParentalPinDialog> {
  final ParentalControlController _parentalControlController =
      Get.find<ParentalControlController>();

  RxBool isError = false.obs;
  RxString errorMessage = ''.obs;
  RxInt remainingAttempts = 3.obs;

  @override
  void initState() {
    super.initState();

    // Verificar si el control parental está bloqueado temporalmente
    if (!_parentalControlController.canUseParentalControl()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTemporaryLockMessage();
      });
    }

    // Verificar si el control parental está activo
    if (!_parentalControlController.useParentalPin.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget
            .onResult(true); // Si no está activo, permitir acceso directamente
      });
    }
  }

  void _verifyPin(String pin) {
    if (_parentalControlController.verifyParentalPin(pin)) {
      // PIN correcto
      widget.onResult(true);
    } else {
      // PIN incorrecto
      remainingAttempts--;
      isError.value = true;

      if (remainingAttempts.value <= 0) {
        // Si se agotaron los intentos, mostrar mensaje de bloqueo
        _showTemporaryLockMessage();
      } else {
        // Mostrar mensaje de error con intentos restantes
        errorMessage.value = 'parental_pin_incorrect_attempts'
            .trParams({'attempts': remainingAttempts.toString()});
      }
    }
  }

  void _showTemporaryLockMessage() {
    final remainingMinutes =
        _parentalControlController.getRemainingLockTimeMinutes();

    Get.dialog(
      AlertDialog(
        title: Text('parental_control_locked_title'.tr),
        content: Text(
          'parental_control_temporarily_locked'
              .trParams({'minutes': remainingMinutes.toString()}),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Cerrar este diálogo
              widget.onResult(false); // Rechazar acceso
            },
            child: Text(TrKeys.ok.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 480.0 : screenWidth * 0.9;

    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppDimensions.xl,
        horizontal: AppDimensions.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Obx(() => PinCodeWidget(
              pinLength: 4,
              onPinEntered: _verifyPin,
              title: widget.customTitle ?? 'enter_parental_pin'.tr,
              subtitle:
                  widget.customSubtitle ?? 'enter_parental_pin_description'.tr,
              isError: isError.value,
              errorMessage: errorMessage.value,
            )),
      ),
      actionsPadding: const EdgeInsets.only(
        bottom: AppDimensions.lg,
        right: AppDimensions.lg,
      ),
      actions: [
        TextButton(
          onPressed: () => widget.onResult(false),
          child: Text(TrKeys.cancel.tr),
        ),
      ],
    );
  }
}
