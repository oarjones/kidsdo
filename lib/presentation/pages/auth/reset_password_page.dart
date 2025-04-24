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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Programar la inicialización después del frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearResetPasswordForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AppDimensions.xxl),
              _buildResetPasswordForm(),
              const SizedBox(height: AppDimensions.xxl),
              _buildBackToLoginButton(),
              const SizedBox(height: AppDimensions.lg),
            ],
          ),
        ),
      ),
    );
  }

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
                // Limpiar antes de volver atrás
                controller.clearResetPasswordForm();
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
              focusNode: controller.resetPasswordEmailFocusNode,
              onSubmitted: (_) {
                if (_formKey.currentState?.validate() ?? false) {
                  controller.resetPassword();
                }
              },
            ),

            // Mensaje de error
            Obx(() {
              if (controller.errorMessage.isNotEmpty &&
                  controller.status.value == AuthStatus.error) {
                return Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.md,
                    bottom: AppDimensions.md,
                  ),
                  child: AuthMessage(
                    message: controller.errorMessage.value,
                    type: MessageType.error,
                    onDismiss: () => controller.errorMessage.value = '',
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Mensaje de éxito
            Obx(() {
              if (controller.status.value == AuthStatus.success) {
                return Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.md,
                    bottom: AppDimensions.md,
                  ),
                  child: AuthMessage(
                    message: TrKeys.emailSentMessage.tr,
                    type: MessageType.success,
                    // No añadir onDismiss aquí para que el mensaje persista
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: AppDimensions.lg),

            // Botón para enviar
            Obx(() => AuthButton(
                  text: TrKeys.sendResetLink.tr,
                  onPressed: controller.status.value != AuthStatus.loading &&
                          controller.status.value != AuthStatus.success
                      ? () {
                          if (_formKey.currentState?.validate() ?? false) {
                            controller.resetPassword();
                          }
                        }
                      : null, // Deshabilitado si está cargando o si ya se envió con éxito
                  isLoading: controller.status.value == AuthStatus.loading,
                  type: AuthButtonType.primary,
                )),
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
        controller.clearResetPasswordForm();
        Get.back();
      },
      type: AuthButtonType.secondary,
    );
  }
}
