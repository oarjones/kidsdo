import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/colors.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/constants/strings.dart';
import 'package:kidsdo/routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.child_care,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.md),
              const Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppDimensions.fontTitle,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.xxl),
              const TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.email,
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.md),
              const TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.password,
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: Icon(Icons.visibility_off_outlined),
                ),
                obscureText: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navegación a pantalla de recuperación de contraseña
                  },
                  child: const Text(AppStrings.forgotPassword),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              ElevatedButton(
                onPressed: () {
                  // Lógica de inicio de sesión
                  Get.offAllNamed(Routes.HOME);
                },
                child: const Text(AppStrings.login),
              ),
              const SizedBox(height: AppDimensions.md),
              OutlinedButton.icon(
                onPressed: () {
                  // Lógica de inicio de sesión con Google
                },
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text(AppStrings.signInWithGoogle),
              ),
              const SizedBox(height: AppDimensions.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(AppStrings.dontHaveAccount),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(Routes.REGISTER);
                    },
                    child: const Text(AppStrings.register),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
