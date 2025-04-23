import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/theme/auth_theme.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/auth_controller.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_button.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_message.dart';
import 'package:kidsdo/presentation/widgets/auth/auth_text_field.dart';
import 'package:kidsdo/presentation/widgets/auth/language_selector_auth.dart';
import 'package:kidsdo/presentation/widgets/common/app_logo.dart';

// 1. Convertir a StatefulWidget
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

// 2. Crear la clase State
class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // 3. Definir la GlobalKey localmente
  final _formKey = GlobalKey<FormState>();

  // 4. Obtener la instancia del controlador
  final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Limpiar el estado específico de esta página al entrar, si es necesario
    // (El clearForm() del controlador puede ser suficiente si se llama al navegar)
    // controller.resetPasswordEmailController.clear(); // Opcional aquí
    // controller.status.value = AuthStatus.initial; // Opcional aquí
    // controller.errorMessage.value = ''; // Opcional aquí
  }

  @override
  void dispose() {
    // Limpiar estado al salir para evitar que se muestre en la siguiente visita
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (controller.status.value == AuthStatus.success) {
    //     controller.status.value = AuthStatus.initial;
    //   }
    // });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. Mover el método build aquí
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          // 6. Usar Obx para observar cambios en el controlador
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: AppDimensions.xxl),
                _buildResetPasswordForm(), // No necesita context
                const SizedBox(height: AppDimensions.xxl),
                _buildBackToLoginButton(),
                const SizedBox(height: AppDimensions.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 7. Mover todos los métodos _buildXXX aquí
  Widget _buildHeader() {
    return Column(
      children: [
        // Fila superior con botón atrás y selector de idioma
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botón para regresar
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Limpiar campos y estado al pulsar atrás
                controller.resetPasswordEmailController.clear();
                controller.errorMessage.value = '';
                if (controller.status.value == AuthStatus.success ||
                    controller.status.value == AuthStatus.error) {
                  controller.status.value = AuthStatus.initial;
                }
                Get.back();
              },
            ),
            // Selector de idioma
            const LanguageSelectorAuth(),
          ],
        ),
        const SizedBox(height: AppDimensions.lg),
        // Logo
        const AppLogo(
          size: 60,
          showText: false,
          showSlogan: false,
        ),
        const SizedBox(height: AppDimensions.lg),
        // Título
        Text(
          TrKeys.resetPassword.tr,
          style: AuthTheme.titleStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.md),
        // Descripción
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          child: Text(
            TrKeys.resetPasswordDescription.tr,
            textAlign: TextAlign.center,
            style: AuthTheme.subtitleStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordForm() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: AuthTheme.containerDecoration,
      child: Form(
        // 8. Usar la _formKey local
        key: _formKey,
        child: Column(
          children: [
            // Campo de email
            AuthTextField(
              controller: controller.resetPasswordEmailController,
              hintText: TrKeys.email.tr,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
              enabled: controller.status.value != AuthStatus.loading,
              autoValidate: true,
              textInputAction: TextInputAction.done,
              // 9. Validar con _formKey local antes de llamar a resetPassword
              onSubmitted: (_) {
                if (_formKey.currentState?.validate() ?? false) {
                  controller
                      .resetPassword(); // Llamar al método del controlador
                }
              },
            ),

            // Mensaje de error
            if (controller.errorMessage.isNotEmpty &&
                controller.status.value == AuthStatus.error)
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.md,
                  bottom: AppDimensions.md,
                ),
                child: AuthMessage(
                  message: controller.errorMessage.value,
                  type: MessageType.error,
                  onDismiss: () => controller.errorMessage.value = '',
                ),
              ),

            // Mensaje de éxito
            if (controller.status.value == AuthStatus.success)
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.md,
                  bottom: AppDimensions.md,
                ),
                child: AuthMessage(
                  message: TrKeys.emailSentMessage.tr,
                  type: MessageType.success,
                  // No añadir onDismiss aquí para que el mensaje persista
                ),
              ),

            const SizedBox(height: AppDimensions.lg),

            // Botón para enviar
            AuthButton(
              text: TrKeys.sendResetLink.tr,
              onPressed: controller.status.value != AuthStatus.loading &&
                      controller.status.value != AuthStatus.success
                  ? () {
                      // 10. Validar con _formKey local antes de llamar a resetPassword
                      if (_formKey.currentState?.validate() ?? false) {
                        controller
                            .resetPassword(); // Llamar al método del controlador
                      }
                    }
                  : null, // Deshabilitado si está cargando o si ya se envió con éxito
              isLoading: controller.status.value == AuthStatus.loading,
              type: AuthButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return AuthButton(
      text: TrKeys.backToLogin.tr,
      onPressed: () {
        // Limpiar campos y estado al pulsar atrás
        controller.resetPasswordEmailController.clear();
        controller.errorMessage.value = '';
        if (controller.status.value == AuthStatus.success ||
            controller.status.value == AuthStatus.error) {
          controller.status.value = AuthStatus.initial;
        }
        Get.back();
      },
      type: AuthButtonType.secondary,
    );
  }
}
