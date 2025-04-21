import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kidsdo/core/constants/dimensions.dart';
import 'package:kidsdo/core/constants/strings.dart';
import 'package:kidsdo/routes.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createAccount),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.lg),
              const TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.name,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppDimensions.md),
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
              const SizedBox(height: AppDimensions.md),
              const TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.confirmPassword,
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: Icon(Icons.visibility_off_outlined),
                ),
                obscureText: true,
              ),
              const SizedBox(height: AppDimensions.xl),
              ElevatedButton(
                onPressed: () {
                  // Lógica de registro
                  Get.offAllNamed(Routes.HOME);
                },
                child: const Text(AppStrings.register),
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
                  const Text(AppStrings.alreadyHaveAccount),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text(AppStrings.login),
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
