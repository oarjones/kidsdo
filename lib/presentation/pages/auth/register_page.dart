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

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Programar la inicialización después del frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearRegisterForm();
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
                controller.clearLoginForm();
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
      key: _formKey,
      child: Column(
        children: [
          // Nombre
          AuthTextField(
            controller: controller.registerNameController,
            hintText: TrKeys.name.tr,
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            enabled: controller.status.value != AuthStatus.loading,
            validator: controller.validateName,
            focusNode: controller.registerNameFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context)
                .requestFocus(controller.registerEmailFocusNode),
            autoValidate: true,
          ),
          const SizedBox(height: AppDimensions.md),

          // Email
          AuthTextField(
            controller: controller.registerEmailController,
            hintText: TrKeys.email.tr,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            enabled: controller.status.value != AuthStatus.loading,
            validator: controller.validateEmail,
            focusNode: controller.registerEmailFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context)
                .requestFocus(controller.registerPasswordFocusNode),
            autoValidate: true,
          ),
          const SizedBox(height: AppDimensions.md),

          // Contraseña
          Obx(() => AuthTextField(
                controller: controller.registerPasswordController,
                hintText: TrKeys.password.tr,
                prefixIcon: Icons.lock_outline,
                obscureText: !controller.registerPasswordVisible.value,
                onToggleVisibility: controller.toggleRegisterPasswordVisibility,
                enabled: controller.status.value != AuthStatus.loading,
                validator: controller.validatePassword,
                focusNode: controller.registerPasswordFocusNode,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context)
                    .requestFocus(controller.registerConfirmPasswordFocusNode),
                autoValidate: true,
              )),
          const SizedBox(height: AppDimensions.md),

          // Confirmar contraseña
          Obx(() => AuthTextField(
                controller: controller.registerConfirmPasswordController,
                hintText: TrKeys.confirmPassword.tr,
                prefixIcon: Icons.lock_outline,
                obscureText: !controller.registerConfirmPasswordVisible.value,
                onToggleVisibility:
                    controller.toggleRegisterConfirmPasswordVisibility,
                enabled: controller.status.value != AuthStatus.loading,
                validator: controller.validateConfirmPassword,
                focusNode: controller.registerConfirmPasswordFocusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (_formKey.currentState?.validate() ?? false) {
                    controller.register();
                  }
                },
                autoValidate: true,
              )),

          // Mensaje de error
          Obx(() {
            if (controller.errorMessage.isNotEmpty) {
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

          const SizedBox(height: AppDimensions.lg),

          // Botón de registro
          Obx(() => AuthButton(
                text: TrKeys.register.tr,
                onPressed: controller.status.value != AuthStatus.loading
                    ? () {
                        if (_formKey.currentState?.validate() ?? false) {
                          controller.register();
                        }
                      }
                    : null,
                isLoading: controller.status.value == AuthStatus.loading,
                type: AuthButtonType.primary,
              )),

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
    return Obx(() => AuthButton(
          text: TrKeys.signInWithGoogle.tr,
          onPressed: controller.status.value != AuthStatus.loading
              ? controller.signInWithGoogle
              : null,
          type: AuthButtonType.social,
          icon: Icons.g_mobiledata,
          iconSize: 32,
          backgroundColor: Colors.red,
        ));
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(TrKeys.alreadyHaveAccount.tr),
        Obx(() => TextButton(
              onPressed: controller.status.value != AuthStatus.loading
                  ? () {
                      controller.clearLoginForm();
                      Get.back();
                    }
                  : null,
              child: Text(
                TrKeys.login.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
      ],
    );
  }
}
