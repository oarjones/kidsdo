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
import 'package:kidsdo/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Programar la inicialización después del frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearLoginForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.md),

                // Selector de idioma en la parte superior
                const Align(
                  alignment: Alignment.topRight,
                  child: LanguageSelectorAuth(),
                ),

                const SizedBox(height: AppDimensions.xl),
                _buildHeader(),
                const SizedBox(height: AppDimensions.xxl),
                _buildLoginForm(context),
                const SizedBox(height: AppDimensions.lg),
                AuthTheme.dividerWithText(TrKeys.or.tr),
                const SizedBox(height: AppDimensions.lg),
                _buildSocialLogin(),
                const SizedBox(height: AppDimensions.xl),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        // Logo personalizado con texto y eslogan
        AppLogo(
          size: 80,
          showText: true,
          showSlogan: true,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Email field
          AuthTextField(
            controller: controller.loginEmailController,
            hintText: TrKeys.email.tr,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            enabled: controller.status.value != AuthStatus.loading,
            validator: controller.validateEmail,
            focusNode: controller.loginEmailFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context)
                .requestFocus(controller.loginPasswordFocusNode),
            autoValidate: true,
          ),
          const SizedBox(height: AppDimensions.md),

          // Password field
          Obx(() => AuthTextField(
                controller: controller.loginPasswordController,
                hintText: TrKeys.password.tr,
                prefixIcon: Icons.lock_outline,
                obscureText: !controller.loginPasswordVisible.value,
                onToggleVisibility: controller.toggleLoginPasswordVisibility,
                enabled: controller.status.value != AuthStatus.loading,
                validator: controller.validatePassword,
                focusNode: controller.loginPasswordFocusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (_formKey.currentState?.validate() ?? false) {
                    controller.login();
                  }
                },
                autoValidate: true,
              )),

          // Forgot password link
          TextButton(
            onPressed: controller.status.value != AuthStatus.loading
                ? () => _showResetPasswordDialog(context)
                : null,
            child: Text(
              TrKeys.forgotPassword.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Error message if any
          Obx(() {
            if (controller.errorMessage.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: AuthMessage(
                  message: controller.errorMessage.value,
                  type: MessageType.error,
                  onDismiss: () => controller.errorMessage.value = '',
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Login button
          Obx(() => AuthButton(
                text: TrKeys.login.tr,
                onPressed: controller.status.value != AuthStatus.loading
                    ? () {
                        if (_formKey.currentState?.validate() ?? false) {
                          controller.login();
                        }
                      }
                    : null,
                isLoading: controller.status.value == AuthStatus.loading,
                type: AuthButtonType.primary,
              )),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
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

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(TrKeys.dontHaveAccount.tr),
        Obx(() => TextButton(
              onPressed: controller.status.value != AuthStatus.loading
                  ? () {
                      controller.clearRegisterForm();
                      Get.toNamed(Routes.register);
                    }
                  : null,
              child: Text(
                TrKeys.register.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
      ],
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    // Limpiar el formulario de reset password antes de navegar
    controller.clearResetPasswordForm();
    Get.toNamed(Routes.resetPassword);
  }
}
