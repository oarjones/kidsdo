import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/translations/app_translations.dart';
import 'package:kidsdo/presentation/controllers/auth_controller.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.createAccount.tr),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.lg),
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    hintText: TrKeys.name.tr,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: controller.status.value != AuthStatus.loading,
                ),
                const SizedBox(height: AppDimensions.md),
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
                const SizedBox(height: AppDimensions.md),
                TextField(
                  controller: controller.confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: TrKeys.confirmPassword.tr,
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
                if (controller.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppDimensions.md,
                      bottom: AppDimensions.md,
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: AppDimensions.fontSm,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: AppDimensions.xl),
                controller.status.value == AuthStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: controller.register,
                        child: Text(TrKeys.register.tr),
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
                    Text(TrKeys.alreadyHaveAccount.tr),
                    TextButton(
                      onPressed: controller.status.value != AuthStatus.loading
                          ? () {
                              controller.clearForm();
                              Get.back();
                            }
                          : null,
                      child: Text(TrKeys.login.tr),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
