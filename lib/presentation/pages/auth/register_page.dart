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

// 1. Convertir a StatefulWidget
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// 2. Crear la clase State
class _RegisterPageState extends State<RegisterPage> {
  // 3. Definir la GlobalKey localmente
  final _formKey = GlobalKey<FormState>();

  // 4. Obtener la instancia del controlador
  final AuthController controller = Get.find<AuthController>();

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
                const SizedBox(height: AppDimensions.lg),
                _buildRegisterForm(context), // Pasar context
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
                controller.clearForm(); // Llamar al método del controlador
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
      // 8. Usar la _formKey local
      key: _formKey,
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
            // 9. Validar con _formKey local antes de llamar a register
            onSubmitted: (_) {
              if (_formKey.currentState?.validate() ?? false) {
                controller.register(); // Llamar al método del controlador
              }
            },
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
                ? () {
                    // 10. Validar con _formKey local antes de llamar a register
                    if (_formKey.currentState?.validate() ?? false) {
                      controller.register(); // Llamar al método del controlador
                    }
                  }
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
          ? controller.signInWithGoogle // Llamar al método del controlador
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
                  controller.clearForm(); // Llamar al método del controlador
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
