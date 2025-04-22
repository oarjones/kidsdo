import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/auth_controller.dart';
import 'package:kidsdo/routes.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: SingleChildScrollView(
            child: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.xxl),
                  const Icon(
                    Icons.child_care,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    TrKeys.appName.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
                  TextField(
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      hintText: TrKeys.email.tr,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: controller.status.value != AuthStatus.loading,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  TextField(
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      hintText: TrKeys.password.tr,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                    obscureText: controller.obscurePassword.value,
                    enabled: controller.status.value != AuthStatus.loading,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: controller.status.value != AuthStatus.loading
                          ? () {
                              // Mostrar diálogo para recuperar contraseña
                              _showResetPasswordDialog(context);
                            }
                          : null,
                      child: Text(TrKeys.forgotPassword.tr),
                    ),
                  ),
                  if (controller.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.md),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: AppDimensions.fontSm,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: AppDimensions.md),
                  controller.status.value == AuthStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: controller.login,
                          child: Text(TrKeys.login.tr),
                        ),
                  const SizedBox(height: AppDimensions.md),
                  OutlinedButton.icon(
                    onPressed: controller.status.value != AuthStatus.loading
                        ? controller.signInWithGoogle
                        : null,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: Text(TrKeys.signInWithGoogle.tr),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(TrKeys.dontHaveAccount.tr),
                      TextButton(
                        onPressed: controller.status.value != AuthStatus.loading
                            ? () {
                                controller.clearForm();
                                Get.toNamed(Routes.register);
                              }
                            : null,
                        child: Text(TrKeys.register.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: Text(TrKeys.resetPassword.tr),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: TrKeys.email.tr,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return TrKeys.requiredField.tr;
              }
              if (!GetUtils.isEmail(value)) {
                return TrKeys.invalidEmail.tr;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(TrKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Get.back();
                controller.resetPassword(emailController.text.trim());
              }
            },
            child: Text(TrKeys.sendResetLink.tr),
          ),
        ],
      ),
    );
  }
}
