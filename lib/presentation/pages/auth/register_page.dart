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

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: AppDimensions.lg),
                _buildRegisterForm(context),
                const SizedBox(height: AppDimensions.lg),
                AuthTheme.dividerWithText(TrKeys.or.tr),
                const SizedBox(height: AppDimensions.lg),
                _buildSocialRegister(),
                const SizedBox(height: AppDimensions.xl),
                _buildLoginLink(),
              ],
            ),
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
                controller.clearForm();
                Get.back();
              },
            ),

            // Selector de idioma
            const LanguageSelectorAuth(),
          ],
        ),

        const SizedBox(height: AppDimensions.md),

        // Título y subtítulo
        Text(
          TrKeys.createAccount.tr,
          style: AuthTheme.titleStyle,
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          TrKeys.registerSubtitle.tr,
          textAlign: TextAlign.center,
          style: AuthTheme.subtitleStyle,
        ),
        const SizedBox(height: AppDimensions.md),
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return Form(
      key: controller.registerFormKey,
      child: Column(
        children: [
          // Nombre
          AuthTextField(
            controller: controller.nameController,
            hintText: TrKeys.name.tr,
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            enabled: controller.status.value != AuthStatus.loading,
            validator: controller.validateName,
            focusNode: controller.nameFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(controller.emailFocusNode),
            autoValidate: true,
          ),
          const SizedBox(height: AppDimensions.md),

          // Email
          AuthTextField(
            controller: controller.emailController,
            hintText: TrKeys.email.tr,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            enabled: controller.status.value != AuthStatus.loading,
            validator: controller.validateEmail,
            focusNode: controller.emailFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context)
                .requestFocus(controller.passwordFocusNode),
            autoValidate: true,
          ),
          const SizedBox(height: AppDimensions.md),

          // Contraseña
          AuthTextField(
            controller: controller.passwordController,
            hintText: TrKeys.password.tr,
            prefixIcon: Icons.lock_outline,
            obscureText: controller.obscurePassword.value,
            onToggleVisibility: controller.togglePasswordVisibility,
            enabled: controller.status.value != AuthStatus.loading,
            validator: controller.validatePassword,
            focusNode: controller.passwordFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context)
                .requestFocus(controller.confirmPasswordFocusNode),
            autoValidate: true,
          ),
          const SizedBox(height: AppDimensions.md),

          // Confirmar contraseña
          AuthTextField(
            controller: controller.confirmPasswordController,
            hintText: TrKeys.confirmPassword.tr,
            prefixIcon: Icons.lock_outline,
            obscureText: controller.obscureConfirmPassword.value,
            onToggleVisibility: controller.toggleConfirmPasswordVisibility,
            enabled: controller.status.value != AuthStatus.loading,
            validator: controller.validateConfirmPassword,
            focusNode: controller.confirmPasswordFocusNode,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => controller.register(),
            autoValidate: true,
          ),

          // Mensaje de error
          if (controller.errorMessage.isNotEmpty)
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

          const SizedBox(height: AppDimensions.lg),

          // Botón de registro
          AuthButton(
            text: TrKeys.register.tr,
            onPressed: controller.status.value != AuthStatus.loading
                ? controller.register
                : null,
            isLoading: controller.status.value == AuthStatus.loading,
            type: AuthButtonType.primary,
          ),

          // Nota legal
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.md),
            child: Text(
              TrKeys.registerTermsPrivacy.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimensions.fontXs,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRegister() {
    return AuthButton(
      text: TrKeys.signInWithGoogle.tr,
      onPressed: controller.status.value != AuthStatus.loading
          ? controller.signInWithGoogle
          : null,
      type: AuthButtonType.social,
      icon: Icons.g_mobiledata,
      iconSize: 32,
      backgroundColor: Colors.red,
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(TrKeys.alreadyHaveAccount.tr),
        TextButton(
          onPressed: controller.status.value != AuthStatus.loading
              ? () {
                  controller.clearForm();
                  Get.back();
                }
              : null,
          child: Text(
            TrKeys.login.tr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
